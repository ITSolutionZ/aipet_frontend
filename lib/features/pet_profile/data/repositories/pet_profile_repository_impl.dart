import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/local_storage_service.dart';
import 'package:flutter/foundation.dart';

class PetProfileRepositoryImpl implements PetProfileRepository {
  final LocalStorageService _localStorageService;

  PetProfileRepositoryImpl({LocalStorageService? localStorageService})
    : _localStorageService = localStorageService ?? LocalStorageService.instance;

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

      // 로컬 저장소에서 펫 데이터 로드
      final petData = await _localStorageService.pet.getPetById(id);

      if (petData == null) {
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
      final success = await _localStorageService.pet.updatePet(pet.id, updatedPet.toJson());
      
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
      // 로컬 저장소에서 펫 정보 가져오기
      final petData = await _localStorageService.pet.getPetById(petId);
      
      if (petData == null) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 이미지 경로 업데이트
      petData['imagePath'] = imagePath;
      petData['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await _localStorageService.pet.updatePet(petId, petData);

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
      final familyManagers = List<String>.from(
        petData['familyManagers'] ?? [],
      );
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
      final familyManagers = List<String>.from(
        petData['familyManagers'] ?? [],
      );
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
