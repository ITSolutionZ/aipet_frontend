import 'package:aipet_frontend/app/services/local_storage_service.dart';
import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';

class PetProfileRepositoryImpl implements PetProfileRepository {
  final LocalStorageService _localStorageService;

  PetProfileRepositoryImpl({LocalStorageService? localStorageService})
    : _localStorageService =
          localStorageService ?? LocalStorageService.instance;

  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      debugPrint('=== getAllPets called ===');

      // 로컬 저장소 초기화
      await _localStorageService.initialize();

      // 로컬 저장소에서 펫 데이터 로드
      final localPets = await _localStorageService.pet.getAllPets();
      debugPrint('Loaded ${localPets.length} pets from local storage');

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

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      debugPrint('=== getPetById called with id: $id ===');

      // 먼저 모든 펫 목록을 확인해보자
      final allPets = await _localStorageService.pet.getAllPets();
      debugPrint(
        'Available pets: ${allPets.map((p) => '${p['petId']}: ${p['name']}').toList()}',
      );

      // 로컬 저장소에서 펫 데이터 로드
      final petData = await _localStorageService.pet.getPetById(id);

      if (petData == null) {
        debugPrint('Pet not found with id: $id');
        debugPrint(
          'Available pet IDs: ${allPets.map((p) => p['petId']).toList()}',
        );
        return Result.success('해당 ID의 펫을 찾을 수 없습니다', null);
      }

      debugPrint('Found pet data: ${petData.keys.toList()}');
      debugPrint('📋 === 펫 데이터 로드 로그 ===');
      debugPrint('📋 펫 ID: ${petData['petId']}');
      debugPrint('📋 펫 이름: ${petData['name']}');
      debugPrint('📋 펫 타입: ${petData['type']}');
      debugPrint('📋 펫 품종: ${petData['breed']}');
      debugPrint('📋 펫 성별: ${petData['gender']}');
      debugPrint('📋 펫 체중: ${petData['weight']}');
      debugPrint('📋 펫 이미지: ${petData['imagePath']}');
      debugPrint('📋 보호자 이름: ${petData['guardianName']}');
      debugPrint('📋 기관 이름: ${petData['institutionName']}');
      debugPrint('📋 등록번호: ${petData['registrationNumber']}');
      debugPrint('📋 중성화 여부: ${petData['neutered']}');
      debugPrint('📋 추가 정보: ${petData['additionalInfo']}');
      debugPrint('📋 ================================');

      final pet = _safeCreatePetEntity(petData);
      debugPrint('Created PetProfileEntity: ${pet.name}');
      debugPrint('📋 === PetProfileEntity 생성 후 ===');
      debugPrint('📋 엔티티 이름: ${pet.name}');
      debugPrint('📋 엔티티 이미지: ${pet.imagePath}');
      debugPrint('📋 엔티티 추가정보: ${pet.additionalInfo}');
      debugPrint('📋 ================================');
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

      // 로컬 저장소에 저장
      final petId = await _localStorageService.pet.addPet(newPet.toJson());
      final createdPet = newPet.copyWith(id: petId);

      return Result.success('펫이 성공적으로 생성되었습니다', createdPet);
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

      // 로컬 저장소에 저장
      final success = await _localStorageService.pet.updatePet(
        pet.id,
        updatedPet.toJson(),
      );

      if (!success) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      return Result.success('펫 정보가 성공적으로 업데이트되었습니다', updatedPet);
    } catch (error) {
      debugPrint('updatePet error: $error');
      return Result.failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    try {
      // 로컬 저장소에서 삭제
      final success = await _localStorageService.pet.deletePet(id);

      if (!success) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      return Result.success('펫이 성공적으로 삭제되었습니다', null);
    } catch (error) {
      debugPrint('deletePet error: $error');
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    try {
      debugPrint('💾 uploadPetImage - petId: $petId, imagePath: $imagePath');

      // 로컬 저장소에서 펫 정보 가져오기
      final petData = await _localStorageService.pet.getPetById(petId);

      if (petData == null) {
        debugPrint('💾 Pet not found: $petId');
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      debugPrint('💾 Current pet data: ${petData['imagePath']}');

      // 이미지 경로 업데이트
      petData['imagePath'] = imagePath;
      petData['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await _localStorageService.pet.updatePet(petId, petData);

      debugPrint('💾 Image path saved successfully: $imagePath');
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
      // 로컬 저장소에서 펫 정보 가져오기
      final petData = await _localStorageService.pet.getPetById(petId);

      if (petData == null) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 공유 설정 업데이트
      petData['isPublic'] = isPublic;
      petData['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await _localStorageService.pet.updatePet(petId, petData);

      return Result.success('공유 설정이 성공적으로 업데이트되었습니다', null);
    } catch (error) {
      return Result.failure('공유 설정 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    try {
      // 로컬 저장소에서 펫 정보 가져오기
      final petData = await _localStorageService.pet.getPetById(petId);

      if (petData == null) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 가족 관리자 목록 가져오기
      final familyManagers = List<String>.from(petData['familyManagers'] ?? []);
      if (!familyManagers.contains(userId)) {
        familyManagers.add(userId);
        petData['familyManagers'] = familyManagers;
        petData['updatedAt'] = DateTime.now().toIso8601String();

        // 로컬 저장소에 저장
        await _localStorageService.pet.updatePet(petId, petData);
      }

      return Result.success('가족 관리자가 성공적으로 추가되었습니다', null);
    } catch (error) {
      return Result.failure('가족 관리자 추가에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    try {
      // 로컬 저장소에서 펫 정보 가져오기
      final petData = await _localStorageService.pet.getPetById(petId);

      if (petData == null) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 가족 관리자 목록에서 제거
      final familyManagers = List<String>.from(petData['familyManagers'] ?? []);
      familyManagers.remove(userId);
      petData['familyManagers'] = familyManagers;
      petData['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await _localStorageService.pet.updatePet(petId, petData);

      return Result.success('가족 관리자가 성공적으로 제거되었습니다', null);
    } catch (error) {
      return Result.failure('가족 관리자 제거에 실패했습니다: ${error.toString()}');
    }
  }

  /// 안전한 PetProfileEntity 생성 (필드가 없거나 잘못된 형식일 때 대응)
  PetProfileEntity _safeCreatePetEntity(Map<String, dynamic> petData) {
    // fromJson을 시도하지 않고 바로 수동으로 생성 (데이터베이스 필드명이 다름)
    // 수동으로 안전하게 PetProfileEntity 생성
    debugPrint('📋 === _safeCreatePetEntity 수동 생성 로그 ===');
    debugPrint('📋 마이크로칩 ID (camelCase): ${petData['microchipId']}');
    debugPrint('📋 마이크로칩 ID (snake_case): ${petData['microchip_id']}');
    debugPrint('📋 등록번호 (camelCase): ${petData['registrationNumber']}');
    debugPrint('📋 등록번호 (snake_case): ${petData['registration_number']}');
    debugPrint('📋 보호자 이름 (camelCase): ${petData['guardianName']}');
    debugPrint('📋 보호자 이름 (snake_case): ${petData['guardian_name']}');
    debugPrint('📋 기관 이름 (camelCase): ${petData['institutionName']}');
    debugPrint('📋 기관 이름 (snake_case): ${petData['institution_name']}');
    debugPrint('📋 추가 정보 키들: ${petData['additionalInfo']?.keys.toList()}');
    debugPrint('📋 펫 상태: ${petData['petStatus']}');
    debugPrint('📋 ===========================================');

    // snake_case 필드를 additionalInfo에 포함
    final additionalInfo = Map<String, dynamic>.from(
      petData['additionalInfo'] as Map<String, dynamic>? ?? {},
    );

    // 데이터베이스의 snake_case 필드들을 additionalInfo에 추가
    if (petData['registration_number'] != null) {
      additionalInfo['registrationNumber'] = petData['registration_number'];
    }
    if (petData['guardian_name'] != null) {
      additionalInfo['guardianName'] = petData['guardian_name'];
    }
    if (petData['institution_name'] != null) {
      additionalInfo['institutionName'] = petData['institution_name'];
    }
    if (petData['is_neutered'] != null) {
      additionalInfo['isNeutered'] = petData['is_neutered'] == 1;
    }

    // petStatus 파싱 (기본값: PetStatus.active)
    final petStatus = _parsePetStatus(petData['petStatus']);

    return PetProfileEntity(
      id:
          petData['petId']?.toString() ??
          petData['id']?.toString() ??
          petData['data']?['id']?.toString() ??
          '',
      name: petData['name']?.toString() ?? '',
      type:
          petData['typeName']?.toString() ??
          petData['type']?.toString() ??
          'dog',
      breed: petData['breed']?.toString(),
      // ✅ birth_date (snake_case) 필드도 확인
      birthDate:
          _parseDate(petData['birthDate']) ??
          _parseDate(petData['birth_date']) ??
          DateTime.now(),
      gender: petData['gender']?.toString() ?? 'unknown',
      weight: _parseDouble(petData['weight']) ?? 0.0,
      imagePath:
          petData['profile_image']?.toString() ??
          petData['imagePath']?.toString(),
      ownerId: petData['ownerId']?.toString() ?? 'unknown',
      createdAt:
          _parseDate(petData['createdAt']) ??
          _parseDate(petData['created_at']) ??
          DateTime.now(),
      updatedAt:
          _parseDate(petData['updatedAt']) ??
          _parseDate(petData['updated_at']) ??
          DateTime.now(),
      isActive: petData['isActive'] as bool? ?? true,
      petStatus: petStatus,
      additionalInfo: additionalInfo,
      neutered: petData['is_neutered'] == 1 || petData['neutered'] == true,
    );
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

  /// PetStatus 파싱
  PetStatus _parsePetStatus(dynamic statusValue) {
    if (statusValue == null) return PetStatus.active;

    // 이미 PetStatus enum이면 그대로 반환
    if (statusValue is PetStatus) return statusValue;

    // 문자열인 경우
    if (statusValue is String) {
      switch (statusValue.toLowerCase()) {
        case 'active':
          return PetStatus.active;
        case 'deceased':
          return PetStatus.deceased;
        case 'hidden':
          return PetStatus.hidden;
        case 'missing':
          return PetStatus.missing;
        default:
          return PetStatus.active;
      }
    }

    // 기본값
    return PetStatus.active;
  }
}
