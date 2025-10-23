import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/core/data/result_types.dart';
import '../../../../shared/core/domain/common_errors.dart';
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/domain/entities/pet_profile_entity.dart';
import '../../../../shared/services/cache_service.dart';
import 'helpers/helpers.dart';
import 'pet_api_service.dart';
import 'pet_image_upload_service.dart';

enum SyncStatus { idle, syncing, completed, failed }

enum SyncDirection { localToRemote, remoteToLocal, bidirectional }

class PetSyncService {
  final PetApiService _petApiService;
  final CacheService _cacheService;
  final Connectivity _connectivity;

  SyncStatus _currentStatus = SyncStatus.idle;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final StreamController<SyncStatus> _syncStatusController =
      StreamController.broadcast();
  final StreamController<List<PetProfileEntity>> _syncedPetsController =
      StreamController.broadcast();

  PetSyncService(this._petApiService, this._cacheService, this._connectivity) {
    _initializeConnectivityListener();
  }

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<List<PetProfileEntity>> get syncedPetsStream =>
      _syncedPetsController.stream;
  SyncStatus get currentStatus => _currentStatus;

  void _initializeConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (_hasInternetConnection(results) &&
          _currentStatus == SyncStatus.idle) {
        _triggerAutoSync();
      }
    });
  }

  bool _hasInternetConnection(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet);
  }

  void _triggerAutoSync() {
    Timer(const Duration(seconds: 2), () {
      syncAllData(SyncDirection.bidirectional);
    });
  }

  Future<ResultState<List<PetProfileEntity>>> syncAllData(
    SyncDirection direction,
  ) async {
    if (_currentStatus == SyncStatus.syncing) {
      return Result.failure(SyncError.toString());
    }

    _updateSyncStatus(SyncStatus.syncing);

    try {
      switch (direction) {
        case SyncDirection.localToRemote:
          return await _syncLocalToRemote();
        case SyncDirection.remoteToLocal:
          return await _syncRemoteToLocal();
        case SyncDirection.bidirectional:
          return await _syncBidirectional();
      }
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      return Result.failure(SyncError.toString()));
    }
  }

  Future<ResultState<List<PetProfileEntity>>> _syncLocalToRemote() async {
    try {
      final pendingChanges = await SyncStorageHelper.getPendingLocalChanges();
      final syncedPets = <PetProfileEntity>[];

      for (final change in pendingChanges) {
        final result = await SyncStorageHelper.applySyncChange(
          change,
          _petApiService,
        );
        if (result.isSuccess && result.dataOrNull != null) {
          syncedPets.add(result.dataOrNull!);
        }
      }

      await SyncStorageHelper.clearPendingChanges();
      _updateSyncStatus(SyncStatus.completed);
      _syncedPetsController.add(syncedPets);

      return Success(syncedPets);
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      return Result.failure(
        SyncError('로컬에서 원격으로 동기화 실패', details: e.toString()),
      );
    }
  }

  Future<ResultState<List<PetProfileEntity>>> _syncRemoteToLocal() async {
    try {
      final remotePetsResult = await _petApiService.getAllPets();
      if (remotePetsResult.isFailure) {
        _updateSyncStatus(SyncStatus.failed);
        return Result.failure(remotePetsResult.errorOrNull!);
      }

      final remotePets = remotePetsResult.dataOrNull!;
      final domainPets = remotePets.map((pet) => pet.toDomain()).toList();

      await _cacheService.setPersistentCacheObject(
        'synced_pet_profiles',
        domainPets,
        ttl: const Duration(hours: 24),
        toJson: (pets) => {
          'pets': pets.map((pet) => pet.toJson()).toList(),
          'last_sync': DateTime.now().toIso8601String(),
        },
      );

      await SyncStorageHelper.updateSyncMetadata();
      _updateSyncStatus(SyncStatus.completed);
      _syncedPetsController.add(domainPets);

      return Success(domainPets);
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      return Result.failure(
        SyncError('원격에서 로컬로 동기화 실패', details: e.toString()),
      );
    }
  }

  Future<ResultState<List<PetProfileEntity>>> _syncBidirectional() async {
    try {
      final localToRemoteResult = await _syncLocalToRemote();
      if (localToRemoteResult.isFailure) {
        return localToRemoteResult;
      }

      final remoteToLocalResult = await _syncRemoteToLocal();
      if (remoteToLocalResult.isFailure) {
        return remoteToLocalResult;
      }

      final allSyncedPets = [
        ...localToRemoteResult.dataOrNull!,
        ...remoteToLocalResult.dataOrNull!,
      ];

      await SyncConflictHelper.resolveConflicts(allSyncedPets);
      return Success(allSyncedPets);
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      return Result.failure(SyncError.toString()));
    }
  }

  Future<void> addPendingChange(String type, PetProfileEntity pet) async {
    await SyncStorageHelper.addPendingChange(type, pet);
  }

  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  Future<ResultState<List<PetProfileEntity>>> getCachedPets() async {
    return SyncStorageHelper.getCachedPets(_cacheService);
  }

  Future<ResultState<DateTime?>> getLastSyncTime() async {
    return SyncStorageHelper.getLastSyncTime();
  }

  Future<ResultState<bool>> needsSync() async {
    return SyncStorageHelper.needsSync();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
    _syncedPetsController.close();
  }
}

enum ConflictResolution { remoteWins, localWins, lastModifiedWins }

class SyncError extends AppError {
  @override
  final String message;
  final String? details;

  SyncError(this.message, {this.details});

  @override
  String get code => 'SYNC_ERROR';

  @override
  ErrorSeverity get severity => ErrorSeverity.high;
}

final petSyncServiceProvider = Provider<PetSyncService>((ref) {
  final petApiService = ref.read(petApiServiceProvider);
  final cacheService = CacheService();
  final connectivity = Connectivity();
  final syncService = PetSyncService(petApiService, cacheService, connectivity);
  ref.onDispose(() => syncService.dispose());
  return syncService;
});
