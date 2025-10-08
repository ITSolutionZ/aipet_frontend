import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/local_data_manager.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet/pet_mock_service.dart';
import 'package:flutter/foundation.dart';

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
        if (!_localDataManager.isInitialized) {
          debugPrint('LocalDataManager not initialized, initializing now...');
          await _localDataManager.initialize();
          debugPrint('LocalDataManager initialization completed');
        }
      } catch (e) {
        debugPrint('LocalDataManager initialization failed: $e');
        // 초기화 실패시에도 계속 진행 (빈 리스트 반환)
        return Result.success('펫 목록을 조회했습니다', []);
      }

      // 로컬 저장소에서 펫 데이터 로드
      final localPets = await _localDataManager.loadPetProfiles();
      debugPrint('Loaded ${localPets.length} pets from local storage');

      // 로컬 데이터가 없거나 마이그레이션이 완료되지 않았으면 목업 데이터로 초기화
      if (localPets.isEmpty ||
          !_localDataManager.isMigrationCompleted('pet_profiles')) {
        debugPrint('Initializing with mock data...');
        await _initializeWithMockData();
        final initializedPets = await _localDataManager.loadPetProfiles();
        debugPrint('Initialized ${initializedPets.length} pets');

        final pets = initializedPets
            .map((petData) => _safeCreatePetEntity(petData))
            .toList();
        debugPrint('Created ${pets.length} PetProfileEntity objects');
        return Result.success('펫 목록을 성공적으로 조회했습니다', pets);
      }

      // 로컬 데이터를 엔티티로 변환
      final pets = localPets
          .map((petData) => _safeCreatePetEntity(petData))
          .toList();
      debugPrint('Converted ${pets.length} pets to entities');
      return Result.success('펫 목록을 성공적으로 조회했습니다', pets);
    } catch (error) {
      debugPrint('getAllPets error: $error');
      return Result.failure('펫 목록 조회에 실패했습니다: ${error.toString()}');
    }
  }

  /// 목업 데이터로 로컬 저장소 초기화
  Future<void> _initializeWithMockData() async {
    try {
      // 기존 데이터 완전 클리어
      await _localDataManager.clearDataByPattern('pet_profiles');
      await _localDataManager.clearDataByPattern('pet_registration_');
      await _localDataManager.clearDataByPattern('pet_');

      // 마이그레이션 상태 리셋 (기존 마이그레이션 플래그 삭제)
      await _localDataManager.clearDataByPattern(
        'migration_completed_pet_profiles',
      );

      final mockPets = PetMockService.getMockPets(); // getMockPets() 사용

      // 데이터 구조를 안전하게 변환하여 저장
      final safePets = mockPets
          .map(
            (pet) => {
              'id': pet['id'] ?? '',
              'name': pet['name'] ?? '',
              'type': pet['type'] ?? 'dog',
              'breed': pet['breed'] ?? '',
              'birthDate': pet['birthDate'] ?? DateTime.now().toIso8601String(),
              'gender': pet['gender'] ?? 'unknown',
              'weight': pet['weight'] ?? 0.0,
              'imagePath': pet['imagePath'] ?? '',
              'ownerId': pet['ownerId'] ?? 'unknown',
              'createdAt': pet['createdAt'] ?? DateTime.now().toIso8601String(),
              'updatedAt': pet['updatedAt'] ?? DateTime.now().toIso8601String(),
              'isActive': pet['isActive'] ?? true,
              'additionalInfo': pet['additionalInfo'] ?? {},
              'neutered': pet['neutered'] ?? false,
            },
          )
          .toList();

      await _localDataManager.savePetProfiles(safePets);
      await _localDataManager.setMigrationCompleted('pet_profiles');
      debugPrint(
        'Pet profiles initialized with mock data: ${safePets.length} pets',
      );
    } catch (error) {
      debugPrint('Failed to initialize with mock data: $error');
    }
  }

  /// 로컬 저장소 강제 초기화 (디버깅용)
  Future<void> forceReinitializeWithMockData() async {
    await _localDataManager.clearDataByPattern(
      'migration_completed_pet_profiles',
    );
    await _initializeWithMockData();
  }

  /// 디버깅용: 로컬 저장소 데이터 상태 확인
  Future<void> debugLocalStorageStatus() async {
    final localPets = await _localDataManager.loadPetProfiles();
    final isMigrationCompleted = _localDataManager.isMigrationCompleted(
      'pet_profiles',
    );

    debugPrint('=== Local Storage Debug Info ===');
    debugPrint('Pet count: ${localPets.length}');
    debugPrint('Migration completed: $isMigrationCompleted');

    if (localPets.isNotEmpty) {
      debugPrint('First pet keys: ${localPets.first.keys.toList()}');
      debugPrint('First pet data: ${localPets.first}');
    }
    debugPrint('===============================');
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      debugPrint('=== getPetById called with id: $id ===');

      // LocalDataManager 초기화 확인
      if (!_localDataManager.isInitialized) {
        debugPrint(
          'LocalDataManager not initialized in getPetById, initializing...',
        );
        await _localDataManager.initialize();
      }

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
      final pet = _safeCreatePetEntity(petData);
      debugPrint('Created PetProfileEntity: ${pet.name}');
      return Result.success('펫 정보를 성공적으로 조회했습니다', pet);
    } catch (error) {
      debugPrint('getPetById error: $error');
      return Result.failure('펫 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    try {
      // 새로운 ID 생성 및 시간 설정
      final newPet = pet.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await _localDataManager.loadPetProfiles();

      // 새 펫 추가
      localPets.add(newPet.toJson());

      // 로컬 저장소에 저장
      await _localDataManager.savePetProfiles(localPets);

      return Result.success('펫이 성공적으로 생성되었습니다', newPet);
    } catch (error) {
      debugPrint('createPet error: $error');
      return Result.failure('펫 생성에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    try {
      // 업데이트 시간 설정
      final updatedPet = pet.copyWith(updatedAt: DateTime.now());

      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await _localDataManager.loadPetProfiles();

      // 해당 펫 찾아서 업데이트
      final petIndex = localPets.indexWhere((p) => p['id'] == pet.id);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      localPets[petIndex] = updatedPet.toJson();

      // 로컬 저장소에 저장
      await _localDataManager.savePetProfiles(localPets);

      return Result.success('펫 정보가 성공적으로 업데이트되었습니다', updatedPet);
    } catch (error) {
      debugPrint('updatePet error: $error');
      return Result.failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await _localDataManager.loadPetProfiles();

      // 해당 펫 찾아서 삭제
      final petIndex = localPets.indexWhere((p) => p['id'] == id);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      localPets.removeAt(petIndex);

      // 로컬 저장소에 저장
      await _localDataManager.savePetProfiles(localPets);

      return Result.success('펫이 성공적으로 삭제되었습니다', null);
    } catch (error) {
      debugPrint('deletePet error: $error');
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await _localDataManager.loadPetProfiles();

      // 해당 펫 찾기
      final petIndex = localPets.indexWhere((p) => p['id'] == petId);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 이미지 경로 업데이트
      localPets[petIndex]['imagePath'] = imagePath;
      localPets[petIndex]['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await _localDataManager.savePetProfiles(localPets);

      return Result.success('이미지가 성공적으로 업로드되었습니다', imagePath);
    } catch (error) {
      debugPrint('uploadPetImage error: $error');
      return Result.failure('이미지 업로드에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> updateSharingSettings(
    String petId,
    bool isPublic,
  ) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await _localDataManager.loadPetProfiles();

      // 해당 펫 찾기
      final petIndex = localPets.indexWhere((p) => p['id'] == petId);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 공유 설정 업데이트
      localPets[petIndex]['isPublic'] = isPublic;
      localPets[petIndex]['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await _localDataManager.savePetProfiles(localPets);

      return Result.success('공유 설정이 성공적으로 업데이트되었습니다', null);
    } catch (error) {
      return Result.failure('공유 설정 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await _localDataManager.loadPetProfiles();

      // 해당 펫 찾기
      final petIndex = localPets.indexWhere((p) => p['id'] == petId);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 가족 관리자 목록 가져오기
      final familyManagers = List<String>.from(
        localPets[petIndex]['familyManagers'] ?? [],
      );
      if (!familyManagers.contains(userId)) {
        familyManagers.add(userId);
        localPets[petIndex]['familyManagers'] = familyManagers;
        localPets[petIndex]['updatedAt'] = DateTime.now().toIso8601String();

        // 로컬 저장소에 저장
        await _localDataManager.savePetProfiles(localPets);
      }

      return Result.success('가족 관리자가 성공적으로 추가되었습니다', null);
    } catch (error) {
      return Result.failure('가족 관리자 추가에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await _localDataManager.loadPetProfiles();

      // 해당 펫 찾기
      final petIndex = localPets.indexWhere((p) => p['id'] == petId);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 가족 관리자 목록에서 제거
      final familyManagers = List<String>.from(
        localPets[petIndex]['familyManagers'] ?? [],
      );
      familyManagers.remove(userId);
      localPets[petIndex]['familyManagers'] = familyManagers;
      localPets[petIndex]['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await _localDataManager.savePetProfiles(localPets);

      return Result.success('가족 관리자가 성공적으로 제거되었습니다', null);
    } catch (error) {
      return Result.failure('가족 관리자 제거에 실패했습니다: ${error.toString()}');
    }
  }

  /// 안전한 PetProfileEntity 생성 (필드가 없거나 잘못된 형식일 때 대응)
  PetProfileEntity _safeCreatePetEntity(Map<String, dynamic> petData) {
    try {
      // fromJson을 먼저 시도해보고, 실패하면 수동으로 생성
      return PetProfileEntity.fromJson(petData);
    } catch (e) {
      debugPrint('PetProfileEntity.fromJson failed, creating manually: $e');
      debugPrint('Pet data keys: ${petData.keys.toList()}');
      debugPrint('Pet data: $petData');

      // 수동으로 안전하게 PetProfileEntity 생성
      return PetProfileEntity(
        id: petData['id']?.toString() ?? '',
        name: petData['name']?.toString() ?? '',
        type:
            petData['typeName']?.toString() ??
            petData['type']?.toString() ??
            'dog',
        breed: petData['breed']?.toString(),
        birthDate: _parseDate(petData['birthDate']) ?? DateTime.now(),
        gender: petData['gender']?.toString() ?? 'unknown',
        weight: _parseDouble(petData['weight']) ?? 0.0,
        imagePath: petData['imagePath']?.toString(),
        ownerId: petData['ownerId']?.toString() ?? 'unknown',
        createdAt: _parseDate(petData['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDate(petData['updatedAt']) ?? DateTime.now(),
        isActive: petData['isActive'] as bool? ?? true,
        additionalInfo:
            petData['additionalInfo'] as Map<String, dynamic>? ?? {},
        neutered: petData['neutered'] as bool? ?? false,
      );
    }
  }

  /// 안전한 DateTime 파싱
  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;

    if (dateValue is DateTime) return dateValue;

    if (dateValue is String) {
      return DateTime.tryParse(dateValue);
    }

    return null;
  }

  /// 안전한 double 파싱
  double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    if (value is String) {
      return double.tryParse(value);
    }

    return null;
  }
}
