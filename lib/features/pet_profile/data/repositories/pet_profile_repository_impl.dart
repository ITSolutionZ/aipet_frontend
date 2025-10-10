import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/local_data_manager.dart';
import 'package:flutter/foundation.dart';

import 'helpers/helpers.dart';

class PetProfileRepositoryImpl implements PetProfileRepository {
  final LocalDataManager _localDataManager;

  PetProfileRepositoryImpl({LocalDataManager? localDataManager})
    : _localDataManager = localDataManager ?? LocalDataManager.instance;

  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      debugPrint('=== getAllPets called ===');

      // LocalDataManager가 초기화되었는지 확인하고 필요시 초기화
      try {
        await PetDataInitHelper.ensureInitialized(_localDataManager);
      } catch (e) {
        debugPrint('LocalDataManager initialization failed: $e');
        // 초기화 실패시에도 계속 진행 (빈 리스트 반환)
        return Result.success('펫 목록을 조회했습니다', []);
      }

      // 로컬 저장소에서 펫 데이터 로드
      final localPets = await _localDataManager.loadPetProfiles();
      debugPrint('Loaded ${localPets.length} pets from local storage');

      // 로컬 데이터가 없거나 마이그레이션이 완료되지 않았으면 빈 상태로 초기화
      if (localPets.isEmpty ||
          !_localDataManager.isMigrationCompleted('pet_profiles')) {
        debugPrint('Initializing with empty data...');
        await PetDataInitHelper.initializeWithMockData(_localDataManager);
        final initializedPets = await _localDataManager.loadPetProfiles();
        debugPrint('Initialized ${initializedPets.length} pets');

        final pets = initializedPets
            .map((petData) => PetDataParserHelper.safeCreatePetEntity(petData))
            .toList();
        debugPrint('Created ${pets.length} PetProfileEntity objects');
        return Result.success('펫 목록을 성공적으로 조회했습니다', pets);
      }

      // 로컬 데이터를 엔티티로 변환
      final pets = localPets
          .map((petData) => PetDataParserHelper.safeCreatePetEntity(petData))
          .toList();
      debugPrint('Converted ${pets.length} pets to entities');
      return Result.success('펫 목록을 성공적으로 조회했습니다', pets);
    } catch (error) {
      debugPrint('getAllPets error: $error');
      return Result.failure('펫 목록 조회에 실패했습니다: ${error.toString()}');
    }
  }

  /// 로컬 저장소 강제 초기화 (디버깅용)
  Future<void> forceReinitializeWithMockData() async {
    await _localDataManager.clearDataByPattern(
      'migration_completed_pet_profiles',
    );
    await PetDataInitHelper.initializeWithMockData(_localDataManager);
  }

  /// 디버깅용: 로컬 저장소 데이터 상태 확인
  Future<void> debugLocalStorageStatus() async {
    await PetDataInitHelper.debugLocalStorageStatus(_localDataManager);
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      debugPrint('=== getPetById called with id: $id ===');

      // LocalDataManager 초기화 확인
      await PetDataInitHelper.ensureInitialized(_localDataManager);

      // 로컬 저장소에서 펫 데이터 로드
      final localPets = await _localDataManager.loadPetProfiles();
      debugPrint(
        'Loaded ${localPets.length} pets from local storage for getPetById',
      );

      // 해당 ID의 펫 찾기
      final petData = localPets.firstWhere(
        (pet) => pet['id'] == id,
        orElse: () => <String, dynamic>{},
      );

      if (petData.isEmpty) {
        debugPrint('Pet not found with id: $id');
        return Result.success('해당 ID의 펫을 찾을 수 없습니다', null);
      }

      debugPrint('Found pet data: ${petData.keys.toList()}');
      final pet = PetDataParserHelper.safeCreatePetEntity(petData);
      debugPrint('Created PetProfileEntity: ${pet.name}');
      return Result.success('펫 정보를 성공적으로 조회했습니다', pet);
    } catch (error) {
      debugPrint('getPetById error: $error');
      return Result.failure('펫 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    return PetCrudHelper.createPet(_localDataManager, pet);
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    return PetCrudHelper.updatePet(_localDataManager, pet);
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    return PetCrudHelper.deletePet(_localDataManager, id);
  }

  @override
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    return PetCrudHelper.uploadPetImage(_localDataManager, petId, imagePath);
  }

  @override
  Future<Result<void>> updateSharingSettings(
    String petId,
    bool isPublic,
  ) async {
    return PetCrudHelper.updateSharingSettings(
      _localDataManager,
      petId,
      isPublic,
    );
  }

  @override
  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    return PetCrudHelper.addFamilyManager(_localDataManager, petId, userId);
  }

  @override
  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    return PetCrudHelper.removeFamilyManager(_localDataManager, petId, userId);
  }
}
