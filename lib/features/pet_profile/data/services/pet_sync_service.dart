import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/core/data/result_types.dart';
import '../../../../shared/core/domain/common_errors.dart';
import '../../../../shared/core/services/secure_storage_service.dart';
import '../../../../shared/domain/entities/pet_profile_entity.dart';
import '../../../../shared/services/cache_service.dart';
import '../models/pet_profile_api_model.dart';
import 'pet_api_service.dart';
import 'pet_image_upload_service.dart';

enum SyncStatus {
  idle,
  syncing,
  completed,
  failed,
}

enum SyncDirection {
  localToRemote,
  remoteToLocal,
  bidirectional,
}

class PetSyncService {
  final PetApiService _petApiService;
  final CacheService _cacheService;
  final Connectivity _connectivity;

  SyncStatus _currentStatus = SyncStatus.idle;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final StreamController<SyncStatus> _syncStatusController = StreamController.broadcast();
  final StreamController<List<PetProfileEntity>> _syncedPetsController = StreamController.broadcast();

  PetSyncService(
    this._petApiService,
    this._cacheService,
    this._connectivity,
  ) {
    _initializeConnectivityListener();
  }

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<List<PetProfileEntity>> get syncedPetsStream => _syncedPetsController.stream;
  SyncStatus get currentStatus => _currentStatus;

  void _initializeConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      if (_hasInternetConnection(results) && _currentStatus == SyncStatus.idle) {
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

  Future<ResultState<List<PetProfileEntity>>> syncAllData(SyncDirection direction) async {
    if (_currentStatus == SyncStatus.syncing) {
      return Failure(SyncError('동기화가 이미 진행 중입니다.'));
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
      return Failure(SyncError('동기화 실패', details: e.toString()));
    }
  }

  Future<ResultState<List<PetProfileEntity>>> _syncLocalToRemote() async {
    try {
      final pendingChanges = await _getPendingLocalChanges();
      final syncedPets = <PetProfileEntity>[];

      for (final change in pendingChanges) {
        final result = await _applySyncChange(change);
        if (result.isSuccess && result.dataOrNull != null) {
          syncedPets.add(result.dataOrNull!);
        }
      }

      await _clearPendingChanges();
      _updateSyncStatus(SyncStatus.completed);
      _syncedPetsController.add(syncedPets);

      return Success(syncedPets);
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      return Failure(SyncError('로컬에서 원격으로 동기화 실패', details: e.toString()));
    }
  }

  Future<ResultState<List<PetProfileEntity>>> _syncRemoteToLocal() async {
    try {
      final remotePetsResult = await _petApiService.getAllPets();
      if (remotePetsResult.isFailure) {
        _updateSyncStatus(SyncStatus.failed);
        return Failure(remotePetsResult.errorOrNull!);
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

      await _updateSyncMetadata();
      _updateSyncStatus(SyncStatus.completed);
      _syncedPetsController.add(domainPets);

      return Success(domainPets);
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      return Failure(SyncError('원격에서 로컬로 동기화 실패', details: e.toString()));
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

      await _resolveConflicts(allSyncedPets);
      return Success(allSyncedPets);
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);
      return Failure(SyncError('양방향 동기화 실패', details: e.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingLocalChanges() async {
    try {
      final changesJson = await SecureStorageService.getJson('pending_pet_changes');
      if (changesJson != null && changesJson['changes'] is List) {
        return List<Map<String, dynamic>>.from(changesJson['changes']);
      }
    } catch (e) {
      // 로그만 남기고 빈 리스트 반환
    }
    return [];
  }

  Future<ResultState<PetProfileEntity?>> _applySyncChange(Map<String, dynamic> change) async {
    try {
      final type = change['type'] as String;
      final data = change['data'] as Map<String, dynamic>;

      switch (type) {
        case 'create':
          final petData = PetProfileEntity.fromJson(data);
          final request = PetProfileCreateRequest.fromDomain(petData);
          final result = await _petApiService.createPet(request);
          if (result.isSuccess) {
            return Success(result.dataOrNull!.toDomain());
          }
          return Failure(result.errorOrNull!);

        case 'update':
          final petId = data['id'] as String;
          final updateData = Map<String, dynamic>.from(data);
          updateData.remove('id');
          final request = PetProfileUpdateRequest.fromJson(updateData);
          final result = await _petApiService.updatePet(petId, request);
          if (result.isSuccess) {
            return Success(result.dataOrNull!.toDomain());
          }
          return Failure(result.errorOrNull!);

        case 'delete':
          final petId = data['id'] as String;
          final result = await _petApiService.deletePet(petId);
          if (result.isSuccess) {
            return const Success(null);
          }
          return Failure(result.errorOrNull!);

        default:
          return Failure(ValidationError(
            field: 'sync_type',
            reason: '알 수 없는 동기화 타입: $type',
          ));
      }
    } catch (e) {
      return Failure(SyncError('동기화 변경사항 적용 실패', details: e.toString()));
    }
  }

  Future<void> _resolveConflicts(List<PetProfileEntity> pets) async {
    final conflictResolutionStrategy = await _getConflictResolutionStrategy();

    switch (conflictResolutionStrategy) {
      case ConflictResolution.remoteWins:
        break;
      case ConflictResolution.localWins:
        break;
      case ConflictResolution.lastModifiedWins:
        pets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
  }

  Future<ConflictResolution> _getConflictResolutionStrategy() async {
    try {
      final strategy = await SecureStorageService.getString('conflict_resolution_strategy');
      switch (strategy) {
        case 'remote_wins':
          return ConflictResolution.remoteWins;
        case 'local_wins':
          return ConflictResolution.localWins;
        case 'last_modified_wins':
        default:
          return ConflictResolution.lastModifiedWins;
      }
    } catch (e) {
      return ConflictResolution.lastModifiedWins;
    }
  }

  Future<void> addPendingChange(String type, PetProfileEntity pet) async {
    try {
      final existingChanges = await _getPendingLocalChanges();
      existingChanges.add({
        'type': type,
        'data': pet.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await SecureStorageService.setJson('pending_pet_changes', {
        'changes': existingChanges,
      });
    } catch (e) {
      // 로그만 남기고 계속 진행
    }
  }

  Future<void> _clearPendingChanges() async {
    try {
      await SecureStorageService.remove('pending_pet_changes');
    } catch (e) {
      // 로그만 남기고 계속 진행
    }
  }

  Future<void> _updateSyncMetadata() async {
    try {
      await SecureStorageService.setJson('pet_sync_metadata', {
        'last_sync': DateTime.now().toIso8601String(),
        'sync_version': 1,
        'status': 'completed',
      });
    } catch (e) {
      // 로그만 남기고 계속 진행
    }
  }

  void _updateSyncStatus(SyncStatus status) {
    _currentStatus = status;
    _syncStatusController.add(status);
  }

  Future<ResultState<List<PetProfileEntity>>> getCachedPets() async {
    try {
      final cachedData = await _cacheService.getPersistentCache('synced_pet_profiles');
      if (cachedData == null) {
        return const Success([]);
      }

      final petsData = cachedData['pets'] as List<dynamic>;
      final pets = petsData
          .map((petData) => PetProfileEntity.fromJson(Map<String, dynamic>.from(petData)))
          .toList();

      return Success(pets);
    } catch (e) {
      return Failure(CacheError('캐시된 펫 데이터 로드 실패', details: e.toString()));
    }
  }

  Future<ResultState<DateTime?>> getLastSyncTime() async {
    try {
      final metadata = await SecureStorageService.getJson('pet_sync_metadata');
      if (metadata != null && metadata['last_sync'] is String) {
        final lastSync = DateTime.parse(metadata['last_sync']);
        return Success(lastSync);
      }
      return const Success(null);
    } catch (e) {
      return Failure(CacheError('마지막 동기화 시간 조회 실패', details: e.toString()));
    }
  }

  Future<ResultState<bool>> needsSync() async {
    try {
      final lastSyncResult = await getLastSyncTime();
      if (lastSyncResult.isFailure || lastSyncResult.dataOrNull == null) {
        return const Success(true);
      }

      final lastSync = lastSyncResult.dataOrNull!;
      final timeSinceSync = DateTime.now().difference(lastSync);

      return Success(timeSinceSync.inHours > 1);
    } catch (e) {
      return const Success(true);
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
    _syncedPetsController.close();
  }
}

enum ConflictResolution {
  remoteWins,
  localWins,
  lastModifiedWins,
}

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