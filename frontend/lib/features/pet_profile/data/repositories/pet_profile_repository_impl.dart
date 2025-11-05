import '../../../../shared/shared.dart';

import '../../../../app/services/local_storage_service.dart';
import '../../../../../features/pet_profile/domain/repositories/pet_profile_repository.dart';

class PetProfileRepositoryImpl implements PetProfileRepository {
  final LocalStorageService _localStorageService;

  PetProfileRepositoryImpl({LocalStorageService? localStorageService})
    : _localStorageService =
          localStorageService ?? LocalStorageService.instance;

  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      LoggerService.debug('=== getAllPets called ===');

      // 로컬 저장소 초기화
      await _localStorageService.initialize();

      // 로컬 저장소에서 펫 데이터 로드
      final localPets = await _localStorageService.pet.getAllPets();
      LoggerService.debug('Loaded ${localPets.length} pets from local storage');

      // 로컬 데이터를 엔티티로 변환
      final pets = localPets
          .map((petData) => _safeCreatePetEntity(petData))
          .toList();
      LoggerService.debug('Converted ${pets.length} pets to entities');
      return Result.success('펫 목록을 성공적으로 조회했습니다', pets);
    } catch (error) {
      LoggerService.debug('getAllPets error: $error');
      return Result.failure('펫 목록 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      LoggerService.debug('=== getPetById called with id: $id ===');

      // 먼저 모든 펫 목록을 확인해보자
      final allPets = await _localStorageService.pet.getAllPets();
      LoggerService.debug(
        'Available pets: ${allPets.map((p) => '${p['petId']}: ${p['name']}').toList()}',
      );

      // 로컬 저장소에서 펫 데이터 로드
      final petData = await _localStorageService.pet.getPetById(id);

      if (petData == null) {
        LoggerService.debug('Pet not found with id: $id');
        LoggerService.debug(
          'Available pet IDs: ${allPets.map((p) => p['petId']).toList()}',
        );
        return Result.success('해당 ID의 펫을 찾을 수 없습니다', null);
      }

      LoggerService.debug('Found pet data: ${petData.keys.toList()}');
      LoggerService.debug('📋 === 펫 데이터 로드 로그 ===');
      LoggerService.debug('📋 펫 ID: ${petData['petId']}');
      LoggerService.debug('📋 펫 이름: ${petData['name']}');
      LoggerService.debug('📋 펫 타입: ${petData['type']}');
      LoggerService.debug('📋 펫 품종: ${petData['breed']}');
      LoggerService.debug('📋 펫 성별: ${petData['gender']}');
      LoggerService.debug('📋 펫 체중: ${petData['weight']}');
      LoggerService.debug('📋 펫 이미지: ${petData['imagePath']}');
      LoggerService.debug('📋 보호자 이름: ${petData['guardianName']}');
      LoggerService.debug('📋 기관 이름: ${petData['institutionName']}');
      LoggerService.debug('📋 등록번호: ${petData['registrationNumber']}');
      LoggerService.debug('📋 중성화 여부: ${petData['neutered']}');
      LoggerService.debug('📋 추가 정보: ${petData['additionalInfo']}');
      LoggerService.debug('📋 ================================');

      final pet = _safeCreatePetEntity(petData);
      LoggerService.debug('Created PetProfileEntity: ${pet.name}');
      LoggerService.debug('📋 === PetProfileEntity 생성 후 ===');
      LoggerService.debug('📋 엔티티 이름: ${pet.name}');
      LoggerService.debug('📋 엔티티 이미지: ${pet.imagePath}');
      LoggerService.debug('📋 엔티티 추가정보: ${pet.additionalInfo}');
      LoggerService.debug('📋 ================================');
      return Result.success('펫 정보를 성공적으로 조회했습니다', pet);
    } catch (error) {
      LoggerService.debug('getPetById error: $error');
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
      LoggerService.debug('createPet error: $error');
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
      LoggerService.debug('updatePet error: $error');
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
      LoggerService.debug('deletePet error: $error');
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    try {
      LoggerService.debug(
        '💾 uploadPetImage - petId: $petId, imagePath: $imagePath',
      );

      // 로컬 저장소에서 펫 정보 가져오기
      final petData = await _localStorageService.pet.getPetById(petId);

      if (petData == null) {
        LoggerService.debug('💾 Pet not found: $petId');
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      LoggerService.debug('💾 Current pet data: ${petData['imagePath']}');

      // 이미지 경로 업데이트
      petData['imagePath'] = imagePath;
      petData['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await _localStorageService.pet.updatePet(petId, petData);

      LoggerService.debug('💾 Image path saved successfully: $imagePath');
      return Result.success('이미지가 성공적으로 업로드되었습니다', imagePath);
    } catch (error) {
      LoggerService.debug('uploadPetImage error: $error');
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
    // 통일된 필드명으로 PetProfileEntity 생성
    LoggerService.debug('📋 === _safeCreatePetEntity 통일된 필드명 로그 ===');
    LoggerService.debug('📋 펫 ID (id): ${petData['id']}');
    LoggerService.debug('📋 펫 ID (petId): ${petData['petId']}');
    LoggerService.debug('📋 펫 이름: ${petData['name']}');
    LoggerService.debug('📋 펫 타입: ${petData['type']}');
    LoggerService.debug('📋 펫 품종: ${petData['breed']}');
    LoggerService.debug('📋 펫 성별: ${petData['gender']}');
    LoggerService.debug('📋 펫 체중: ${petData['weight']}');
    LoggerService.debug('📋 펫 이미지 (imagePath): ${petData['imagePath']}');
    LoggerService.debug(
      '📋 펫 이미지 (profile_image): ${petData['profile_image']}',
    );
    LoggerService.debug('📋 펫 생일 (birthDate): ${petData['birthDate']}');
    LoggerService.debug('📋 펫 생일 (birth_date): ${petData['birth_date']}');
    LoggerService.debug('📋 펫 상태: ${petData['petStatus']}');
    LoggerService.debug('📋 중성화 (neutered): ${petData['neutered']}');
    LoggerService.debug('📋 중성화 (is_neutered): ${petData['is_neutered']}');
    LoggerService.debug('📋 추가 정보: ${petData['additionalInfo']}');
    LoggerService.debug('📋 ===========================================');

    // additionalInfo 정리 (필요한 필드만 유지)
    final additionalInfo = <String, dynamic>{};

    // 필요한 추가 정보만 포함
    if (petData['additionalInfo'] is Map<String, dynamic>) {
      final info = petData['additionalInfo'] as Map<String, dynamic>;
      // 유효한 값만 추가
      if (info['isNeutered'] != null) {
        additionalInfo['isNeutered'] = info['isNeutered'];
      }
      if (info['guardianName'] != null &&
          info['guardianName'].toString().isNotEmpty) {
        additionalInfo['guardianName'] = info['guardianName'];
      }
      if (info['institutionName'] != null &&
          info['institutionName'].toString().isNotEmpty) {
        additionalInfo['institutionName'] = info['institutionName'];
      }
      if (info['registrationNumber'] != null &&
          info['registrationNumber'].toString().isNotEmpty) {
        additionalInfo['registrationNumber'] = info['registrationNumber'];
      }
      if (info['adoptionDate'] != null) {
        additionalInfo['adoptionDate'] = info['adoptionDate'];
      }
      if (info['forbiddenIngredients'] != null) {
        additionalInfo['forbiddenIngredients'] = info['forbiddenIngredients'];
      }
      if (info['bodyPartsToManage'] != null) {
        additionalInfo['bodyPartsToManage'] = info['bodyPartsToManage'];
      }
      if (info['appearance'] != null) {
        additionalInfo['appearance'] = info['appearance'];
      }
      if (info['food'] != null) {
        additionalInfo['food'] = info['food'];
      }
      if (info['supplement'] != null) {
        additionalInfo['supplement'] = info['supplement'];
      }
      if (info['treat'] != null) {
        additionalInfo['treat'] = info['treat'];
      }
    }

    // petStatus 파싱 (기본값: PetStatus.active)
    final petStatus = _parsePetStatus(petData['petStatus']);

    // isActive 안전 파싱 (bool 또는 int)
    bool isActive = true;
    if (petData['isActive'] is bool) {
      isActive = petData['isActive'] as bool;
    } else if (petData['is_active'] is int) {
      isActive = petData['is_active'] == 1;
    } else if (petData['is_active'] is bool) {
      isActive = petData['is_active'] as bool;
    }

    // neutered 안전 파싱 (bool 또는 int)
    bool neutered = false;
    if (petData['neutered'] is bool) {
      neutered = petData['neutered'] as bool;
    } else if (petData['is_neutered'] is int) {
      neutered = petData['is_neutered'] == 1;
    } else if (petData['is_neutered'] is bool) {
      neutered = petData['is_neutered'] as bool;
    }

    // microchipNumber 파싱 (Entity 필드 또는 additionalInfo)
    String? microchipNumber;
    if (petData['microchipNumber'] != null) {
      microchipNumber = petData['microchipNumber'].toString();
    } else if (petData['microchip_number'] != null) {
      microchipNumber = petData['microchip_number'].toString();
    } else if (additionalInfo['microchipId'] != null) {
      microchipNumber = additionalInfo['microchipId'].toString();
    }

    return PetProfileEntity(
      id: (petData['id'] ?? petData['petId'])?.toString() ?? '',
      name: petData['name']?.toString() ?? '',
      type: petData['type']?.toString() ?? 'dog',
      breed: petData['breed']?.toString(),
      birthDate:
          _parseDate(petData['birthDate'] ?? petData['birth_date']) ??
          DateTime.now(),
      gender: petData['gender']?.toString() ?? 'unknown',
      weight: _parseDouble(petData['weight']) ?? 0.0,
      microchipNumber: microchipNumber,
      size: petData['size']?.toString(),
      arrivalDate: _parseDate(
        petData['arrivalDate'] ?? petData['arrival_date'],
      ),
      imagePath: (petData['imagePath'] ?? petData['profile_image'])?.toString(),
      ownerId: petData['ownerId']?.toString() ?? 'unknown',
      createdAt:
          _parseDate(petData['createdAt'] ?? petData['created_at']) ??
          DateTime.now(),
      updatedAt:
          _parseDate(petData['updatedAt'] ?? petData['updated_at']) ??
          DateTime.now(),
      isActive: isActive,
      petStatus: petStatus,
      additionalInfo: additionalInfo,
      neutered: neutered,
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
