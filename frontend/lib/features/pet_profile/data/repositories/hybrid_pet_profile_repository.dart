import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:connectivity_plus/connectivity_plus.dart';


import '../../../../shared/shared.dart';
import '../../../../shared/core/data/result_types.dart' as api;
import '../../../../shared/core/domain/result.dart';
import '../../../../shared/services/cache_service.dart';
import '../../domain/repositories/pet_profile_repository.dart';
import '../models/pet_profile_api_model.dart';
import '../services/pet_api_service.dart';
import '../services/pet_image_upload_service.dart';
import '../services/pet_sync_service.dart';
import 'pet_profile_repository_impl.dart';



class HybridPetProfileRepository implements PetProfileRepository {
  final PetApiService _petApiService;
  final PetImageUploadService _imageUploadService;
  final PetSyncService _syncService;
  final PetProfileRepositoryImpl _localRepository;
  final Connectivity _connectivity;

  HybridPetProfileRepository(
    this._petApiService,
    this._imageUploadService,
    this._syncService,
    this._localRepository,
    this._connectivity,
  );

  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        final syncResult = await _syncService.syncAllData(
          SyncDirection.remoteToLocal,
        );
        if (syncResult.isSuccess && syncResult.dataOrNull != null) {
          return Result.success('ペットリストを同期しました', syncResult.dataOrNull);
        }
      }

      final cachedResult = await _syncService.getCachedPets();
      if (cachedResult.isSuccess &&
          cachedResult.dataOrNull != null &&
          cachedResult.dataOrNull!.isNotEmpty) {
        return Result.success('キャッシュされたペットリストを取得しました', cachedResult.dataOrNull);
      }

      return await _localRepository.getAllPets();
    } catch (e) {
      return Result.failure('ペットリストの取得に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        final apiResult = await _petApiService.getPetById(id);
        if (apiResult.isSuccess && apiResult.dataOrNull != null) {
          final PetProfileEntity petEntity = apiResult.dataOrNull!.toDomain();
          // await _syncService.cacheSinglePet(petEntity);
          return Result.success('ペット情報を取得しました', petEntity);
        }
      }

      final cachedPetsResult = await _syncService.getCachedPets();
      if (cachedPetsResult.isSuccess && cachedPetsResult.dataOrNull != null) {
        final pets = cachedPetsResult.dataOrNull!;
        try {
          final PetProfileEntity pet = pets.firstWhere((pet) => pet.id == id);
          return Result.success('キャッシュされたペット情報を取得しました', pet);
        } catch (e) {
          // 캐시에 없으면 로컬 리포지토리로 폴백
        }
      }

      return await _localRepository.getPetById(id);
    } catch (e) {
      return Result.failure('ペットの取得に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        // PetProfileApiModel의 fromDomain은 shared entity를 사용
        final request = PetProfileCreateRequest.fromDomain(pet);
        final apiResult = await _petApiService.createPet(request);
        if (apiResult.isSuccess && apiResult.dataOrNull != null) {
          final PetProfileEntity createdPet = apiResult.dataOrNull!.toDomain();
          await _invalidateCache();
          return Result.success('ペットが作成されました', createdPet);
        }
      }

      // 오프라인 시 로컬에 저장하고 pending으로 표시
      final localResult = await _localRepository.createPet(pet);
      if (localResult.isSuccess) {
        await _updateLocalCache();
      }

      return localResult;
    } catch (e) {
      return Result.failure('ペットの作成に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        final updateData = _createUpdateRequest(pet);
        final apiResult = await _petApiService.updatePet(pet.id, updateData);
        if (apiResult.isSuccess && apiResult.dataOrNull != null) {
          final PetProfileEntity updatedPet = apiResult.dataOrNull!.toDomain();
          await _invalidateCache();
          return Result.success('ペット情報が更新されました', updatedPet);
        }
      }

      // 오프라인 시 로컬에 저장하고 pending으로 표시
      final localResult = await _localRepository.updatePet(pet);
      if (localResult.isSuccess) {
        await _updateLocalCache();
      }

      return localResult;
    } catch (e) {
      return Result.failure('ペット情報の更新に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        final apiResult = await _petApiService.deletePet(id);
        if (apiResult.isSuccess) {
          await _invalidateCache();
          return Result.success('ペットが削除されました', null);
        }
      }

      // 오프라인 시 로컬에서 삭제하고 pending으로 표시
      final localResult = await _localRepository.deletePet(id);
      if (localResult.isSuccess) {
        await _updateLocalCache();
      }

      return localResult;
    } catch (e) {
      return Result.failure('ペットの削除に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        final imageFile = File(imagePath);
        final uploadResult = await _imageUploadService.uploadPetImage(
          petId: petId,
          imageFile: imageFile,
          quality: ImageQuality.high,
        );

        if (uploadResult.isSuccess && uploadResult.dataOrNull != null) {
          return Result.success('画像がアップロードされました', uploadResult.dataOrNull!);
        }
      }

      return await _localRepository.uploadPetImage(petId, imagePath);
    } catch (e) {
      return Result.failure('画像のアップロードに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> updateSharingSettings(
    String petId,
    bool isPublic,
  ) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        final settings = PetSharingSettings(petId: petId, isPublic: isPublic);
        final apiResult = await _petApiService.updateSharingSettings(
          petId,
          settings,
        );
        if (apiResult.isSuccess) {
          return Result.success('共有設定が更新されました', null);
        }
      }

      return await _localRepository.updateSharingSettings(petId, isPublic);
    } catch (e) {
      return Result.failure('共有設定の更新に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        final apiResult = await _petApiService.addFamilyManager(petId, userId);
        if (apiResult.isSuccess) {
          return Result.success('家族管理者が追加されました', null);
        }
      }

      return await _localRepository.addFamilyManager(petId, userId);
    } catch (e) {
      return Result.failure('家族管理者の追加に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (hasInternet) {
        final apiResult = await _petApiService.removeFamilyManager(
          petId,
          userId,
        );
        if (apiResult.isSuccess) {
          return Result.success('家族管理者が削除されました', null);
        }
      }

      return await _localRepository.removeFamilyManager(petId, userId);
    } catch (e) {
      return Result.failure('家族管理者の削除に失敗しました: ${e.toString()}');
    }
  }

  PetProfileUpdateRequest _createUpdateRequest(PetProfileEntity pet) {
    return PetProfileUpdateRequest(
      name: pet.name,
      breed: pet.breed,
      birthDate: pet.birthDate.toIso8601String(),
      gender: pet.gender,
      weight: pet.weight,
      size: pet.size,
      microchipNumber: pet.microchipNumber,
      arrivalDate: pet.arrivalDate?.toIso8601String(),
      neutered: pet.neutered,
      imageUrl: pet.imagePath,
      isActive: pet.isActive,
      additionalInfo: pet.additionalInfo,
    );
  }

  Future<void> _invalidateCache() async {
    try {
      final cacheService = CacheService();
      await cacheService.removeKey('synced_pet_profiles');
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<void> _updateLocalCache() async {
    try {
      final allPetsResult = await _localRepository.getAllPets();
      if (allPetsResult.isSuccess) {
        final cacheService = CacheService();
        final cacheData = {
          'pets': allPetsResult.dataOrNull!.map((pet) => pet.toJson()).toList(),
          'last_sync': DateTime.now().toIso8601String(),
        };
        await cacheService.setString(
          'synced_pet_profiles',
          jsonEncode(cacheData),
        );
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<api.ResultState<void>> forceSyncAllData() async {
    return _syncService.syncAllData(SyncDirection.bidirectional);
  }

  Future<api.ResultState<bool>> needsSync() async {
    return _syncService.needsSync();
  }

  Future<api.ResultState<DateTime?>> getLastSyncTime() async {
    return _syncService.getLastSyncTime();
  }

  Stream<SyncStatus> get syncStatusStream => _syncService.syncStatusStream;
  Stream<List<PetProfileEntity>> get syncedPetsStream =>
      _syncService.syncedPetsStream;
}

final hybridPetProfileRepositoryProvider = Provider<HybridPetProfileRepository>(
  (ref) {
    final petApiService = ref.read(petApiServiceProvider);
    final imageUploadService = ref.read(petImageUploadServiceProvider);
    final syncService = ref.read(petSyncServiceProvider);
    final localRepository = PetProfileRepositoryImpl();
    final connectivity = Connectivity();

    return HybridPetProfileRepository(
      petApiService,
      imageUploadService,
      syncService,
      localRepository,
      connectivity,
    );
  },
);
