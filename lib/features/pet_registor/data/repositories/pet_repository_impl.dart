import 'dart:convert';

import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/temporary_pet_data_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/repositories/pet_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/services/database_service.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet/pet_mock_service.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetRepositoryImpl implements PetRepository {
  final DatabaseService _databaseService = DatabaseService();
  final Logger _logger = Logger();

  /// Mock 모드 여부 확인
  bool get _isMockMode =>
      AppConfig.current.isMockMode || AppConfig.current.environment == 'test';

  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      if (_isMockMode) {
        return _getMockPets();
      }

      // 실제 데이터베이스에서 조회
      return await _databaseService.getAllPetProfiles();
    } catch (error) {
      return Result.failure('펫 목록 조회에 실패했습니다: ${error.toString()}');
    }
  }

  /// Mock 데이터 반환
  Future<Result<List<PetProfileEntity>>> _getMockPets() async {
    if (AppConfig.current.environment == 'test') {
      await Future.delayed(const Duration(milliseconds: 1));
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final petsData = PetMockService.getMockPetProfiles();
    final pets = petsData
        .map(
          (petData) => PetProfileEntity(
            id: petData['id']?.toString() ?? '',
            name: petData['name']?.toString() ?? '',
            type: petData['typeName']?.toString() ?? 'dog',
            breed: petData['breed']?.toString(),
            birthDate: petData['birthDate'] != null
                ? DateTime.tryParse(petData['birthDate'].toString()) ??
                      DateTime.now()
                : DateTime.now(),
            gender: petData['gender']?.toString() ?? 'unknown',
            weight: (petData['weight'] as num?)?.toDouble() ?? 0.0,
            imagePath: petData['imagePath']?.toString(),
            ownerId: petData['ownerId']?.toString() ?? 'unknown',
            createdAt: petData['createdAt'] != null
                ? DateTime.tryParse(petData['createdAt'].toString()) ??
                      DateTime.now()
                : DateTime.now(),
            updatedAt: DateTime.now(),
            additionalInfo:
                petData['additionalInfo'] as Map<String, dynamic>? ?? {},
          ),
        )
        .toList();
    return Result.success('펫 목록을 성공적으로 조회했습니다', pets);
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      if (_isMockMode) {
        final result = await _getMockPets();
        if (result.isSuccess) {
          final pets = result.dataOrNull!;
          try {
            final pet = pets.firstWhere((pet) => pet.id == id);
            return Result.success('펫 정보를 성공적으로 조회했습니다', pet);
          } catch (e) {
            return Result.success('펫을 찾을 수 없습니다', null);
          }
        } else {
          return Result.failure(result.error as String ?? '펫 조회에 실패했습니다');
        }
      }

      // 실제 데이터베이스에서 조회
      return await _databaseService.getPetProfileById(id);
    } catch (error) {
      return Result.failure('펫 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    try {
      final newPet = pet.copyWith(
        id: pet.id.isEmpty
            ? DateTime.now().millisecondsSinceEpoch.toString()
            : pet.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isMockMode) {
        if (AppConfig.current.environment == 'test') {
          await Future.delayed(const Duration(milliseconds: 1));
        } else {
          await Future.delayed(const Duration(milliseconds: 300));
        }
        return Result.success('펫이 성공적으로 생성되었습니다', newPet);
      }

      // 실제 데이터베이스에 저장
      final saveResult = await _databaseService.savePetProfile(newPet);
      if (saveResult.isSuccess) {
        return Result.success('펫이 성공적으로 생성되었습니다', newPet);
      } else {
        return Result.failure(saveResult.error as String ?? '펫 생성에 실패했습니다');
      }
    } catch (error) {
      return Result.failure('펫 생성에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    try {
      final updatedPet = pet.copyWith(updatedAt: DateTime.now());

      if (_isMockMode) {
        if (AppConfig.current.environment == 'test') {
          await Future.delayed(const Duration(milliseconds: 1));
        } else {
          await Future.delayed(const Duration(milliseconds: 200));
        }
        return Result.success('펫 정보가 성공적으로 업데이트되었습니다', updatedPet);
      }

      // 실제 데이터베이스에서 업데이트
      final updateResult = await _databaseService.updatePetProfile(updatedPet);
      if (updateResult.isSuccess) {
        return Result.success('펫 정보가 성공적으로 업데이트되었습니다', updatedPet);
      } else {
        return Result.failure(updateResult.error as String ?? '펫 업데이트에 실패했습니다');
      }
    } catch (error) {
      return Result.failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    try {
      if (_isMockMode) {
        if (AppConfig.current.environment == 'test') {
          await Future.delayed(const Duration(milliseconds: 1));
        } else {
          await Future.delayed(const Duration(milliseconds: 200));
        }
        return Result.success('펫이 성공적으로 삭제되었습니다', null);
      }

      // 실제 데이터베이스에서 삭제
      return await _databaseService.deletePetProfile(id);
    } catch (error) {
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<void> saveTemporaryPetData(TemporaryPetDataEntity data) async {
    try {
      if (_isMockMode) {
        await Future.delayed(const Duration(milliseconds: 100));
        return;
      }

      // SharedPreferences에 임시 데이터 저장
      final prefs = await SharedPreferences.getInstance();
      final jsonData = {
        'id': data.id,
        'name': data.name,
        'type': data.type,
        'breed': data.breed,
        'birthDate': data.birthDate?.toIso8601String(),
        'imagePath': data.imagePath,
        'ownerId': data.ownerId,
        'currentStep': data.currentStep.name,
        'stepData': data.stepData,
        'additionalInfo': data.additionalInfo,
        'createdAt': data.createdAt?.toIso8601String(),
        'updatedAt': data.updatedAt?.toIso8601String(),
        'isActive': data.isActive,
      };
      await prefs.setString('temp_pet_data', jsonEncode(jsonData));
    } catch (error) {
      // 에러 발생 시 로그만 기록하고 진행
      _logger.e('임시 데이터 저장 실패', error: error);
    }
  }

  @override
  Future<TemporaryPetDataEntity?> getTemporaryPetData() async {
    try {
      if (_isMockMode) {
        await Future.delayed(const Duration(milliseconds: 100));
        return null;
      }

      // SharedPreferences에서 임시 데이터 로드
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('temp_pet_data');

      if (jsonString == null) return null;

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return TemporaryPetDataEntity(
        id: jsonData['id'] as String?,
        name: jsonData['name'] as String?,
        type: jsonData['type'] as String?,
        breed: jsonData['breed'] as String?,
        birthDate: jsonData['birthDate'] != null
            ? DateTime.tryParse(jsonData['birthDate'] as String)
            : null,
        imagePath: jsonData['imagePath'] as String?,
        ownerId: jsonData['ownerId'] as String?,
        currentStep: PetRegistrationStep.values.firstWhere(
          (step) => step.name == jsonData['currentStep'],
          orElse: () => PetRegistrationStep.typeSelection,
        ),
        stepData: jsonData['stepData'] as Map<String, dynamic>?,
        additionalInfo: jsonData['additionalInfo'] as Map<String, dynamic>?,
        createdAt: jsonData['createdAt'] != null
            ? DateTime.tryParse(jsonData['createdAt'] as String)
            : null,
        updatedAt: jsonData['updatedAt'] != null
            ? DateTime.tryParse(jsonData['updatedAt'] as String)
            : null,
        isActive: jsonData['isActive'] as bool? ?? true,
      );
    } catch (error) {
      _logger.e('임시 데이터 로드 실패', error: error);
      return null;
    }
  }

  @override
  Future<void> clearTemporaryPetData() async {
    try {
      if (_isMockMode) {
        await Future.delayed(const Duration(milliseconds: 100));
        return;
      }

      // SharedPreferences에서 임시 데이터 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_pet_data');
    } catch (error) {
      _logger.e('임시 데이터 삭제 실패', error: error);
    }
  }
}
