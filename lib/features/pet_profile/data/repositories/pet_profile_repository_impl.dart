import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/services/http_client_service.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet/pet_mock_service.dart';
import 'package:flutter/foundation.dart';

class PetProfileRepositoryImpl implements PetProfileRepository {
  final HttpClientService _httpClient;

  PetProfileRepositoryImpl({HttpClientService? httpClient})
    : _httpClient = httpClient ?? HttpClientService.instance;

  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      // Mock 모드 또는 테스트 환경에서는 Mock 데이터 사용
      if (AppConfig.current.isMockMode ||
          AppConfig.current.environment == 'test') {
        return _getMockPets();
      }

      // 실제 API 호출
      final response = await _httpClient.get<List<Map<String, dynamic>>>(
        '/pets',
        fromJson: (data) => (data['pets'] as List<dynamic>)
            .map((pet) => pet as Map<String, dynamic>)
            .toList(),
      );

      if (response.isSuccess && response.data != null) {
        final pets = response.dataOrThrow
            .map((petData) => PetProfileEntity.fromJson(petData))
            .toList();
        return Success(pets, '펫 목록을 성공적으로 조회했습니다');
      } else {
        return Result.failure(response.error ?? '펫 목록 조회에 실패했습니다');
      }
    } catch (error) {
      debugPrint('getAllPets error: $error');
      return Result.failure('펫 목록 조회에 실패했습니다: ${error.toString()}');
    }
  }

  /// Mock 데이터 반환 (기존 로직 유지)
  Future<Result<List<PetProfileEntity>>> _getMockPets() async {
    try {
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
      return Success(pets, '펫 목록을 성공적으로 조회했습니다');
    } catch (error) {
      return Result.failure('펫 목록 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      // Mock 모드 또는 테스트 환경에서는 getAllPets에서 찾기
      if (AppConfig.current.isMockMode ||
          AppConfig.current.environment == 'test') {
        final result = await getAllPets();
        if (result.isSuccess) {
          final pets = result.dataOrNull!;
          try {
            final pet = pets.firstWhere((pet) => pet.id == id);
            return Success(pet, '펫 정보를 성공적으로 조회했습니다');
          } catch (e) {
            return const Success(null, '해당 ID의 펫을 찾을 수 없습니다');
          }
        } else {
          return Result.failure(result.errorOrNull!);
        }
      }

      // 실제 API 호출
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/pets/$id',
        fromJson: (data) => data['pet'] as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final pet = PetProfileEntity.fromJson(response.dataOrThrow);
        return Success(pet, '펫 정보를 성공적으로 조회했습니다');
      } else {
        return Result.failure(response.error ?? '펫 조회에 실패했습니다');
      }
    } catch (error) {
      debugPrint('getPetById error: $error');
      return Result.failure('펫 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    try {
      // Mock 모드 또는 테스트 환경에서는 Mock 생성
      if (AppConfig.current.isMockMode ||
          AppConfig.current.environment == 'test') {
        if (AppConfig.current.environment == 'test') {
          await Future.delayed(const Duration(milliseconds: 1));
        } else {
          await Future.delayed(const Duration(milliseconds: 300));
        }

        final newPet = pet.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return Success(newPet, '펫이 성공적으로 생성되었습니다');
      }

      // 실제 API 호출
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/pets',
        data: pet.toJson(),
        fromJson: (data) => data['pet'] as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final createdPet = PetProfileEntity.fromJson(response.dataOrThrow);
        return Success(createdPet, '펫이 성공적으로 생성되었습니다');
      } else {
        return Result.failure(response.error ?? '펫 생성에 실패했습니다');
      }
    } catch (error) {
      debugPrint('createPet error: $error');
      return Result.failure('펫 생성에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    try {
      // Mock 모드 또는 테스트 환경에서는 Mock 업데이트
      if (AppConfig.current.isMockMode ||
          AppConfig.current.environment == 'test') {
        if (AppConfig.current.environment == 'test') {
          await Future.delayed(const Duration(milliseconds: 1));
        } else {
          await Future.delayed(const Duration(milliseconds: 200));
        }

        final updatedPet = pet.copyWith(updatedAt: DateTime.now());
        return Success(updatedPet, '펫 정보가 성공적으로 업데이트되었습니다');
      }

      // 실제 API 호출
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/pets/${pet.id}',
        data: pet.toJson(),
        fromJson: (data) => data['pet'] as Map<String, dynamic>,
      );

      if (response.isSuccess && response.data != null) {
        final updatedPet = PetProfileEntity.fromJson(response.dataOrThrow);
        return Success(updatedPet, '펫 정보가 성공적으로 업데이트되었습니다');
      } else {
        return Result.failure(response.error ?? '펫 업데이트에 실패했습니다');
      }
    } catch (error) {
      debugPrint('updatePet error: $error');
      return Result.failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    try {
      // Mock 모드 또는 테스트 환경에서는 Mock 삭제
      if (AppConfig.current.isMockMode ||
          AppConfig.current.environment == 'test') {
        if (AppConfig.current.environment == 'test') {
          await Future.delayed(const Duration(milliseconds: 1));
        } else {
          await Future.delayed(const Duration(milliseconds: 200));
        }
        return const Success(null, '펫이 성공적으로 삭제되었습니다');
      }

      // 실제 API 호출
      final response = await _httpClient.delete('/pets/$id');

      if (response.isSuccess) {
        return const Success(null, '펫이 성공적으로 삭제되었습니다');
      } else {
        return Result.failure(response.error ?? '펫 삭제에 실패했습니다');
      }
    } catch (error) {
      debugPrint('deletePet error: $error');
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    try {
      // Mock 모드 또는 테스트 환경에서는 Mock 업로드
      if (AppConfig.current.isMockMode ||
          AppConfig.current.environment == 'test') {
        await Future.delayed(const Duration(milliseconds: 500));
        final imageUrl = 'https://example.com/images/$petId.jpg';
        return Success(imageUrl, '이미지가 성공적으로 업로드되었습니다');
      }

      // 실제 이미지 업로드 API 호출
      // TODO: FormData를 사용한 실제 파일 업로드 구현 필요
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/pets/$petId/image',
        data: {'imagePath': imagePath},
        fromJson: (data) => data,
      );

      if (response.isSuccess && response.data != null) {
        final imageUrl = response.dataOrThrow['imageUrl'] as String;
        return Success(imageUrl, '이미지가 성공적으로 업로드되었습니다');
      } else {
        return Result.failure(response.error ?? '이미지 업로드에 실패했습니다');
      }
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
      // 시뮬레이션된 공유 설정 업데이트
      await Future.delayed(const Duration(milliseconds: 200));
      return const Success(null, '공유 설정이 성공적으로 업데이트되었습니다');
    } catch (error) {
      return Result.failure('공유 설정 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    try {
      // 시뮬레이션된 가족 관리자 추가
      await Future.delayed(const Duration(milliseconds: 300));
      return const Success(null, '가족 관리자가 성공적으로 추가되었습니다');
    } catch (error) {
      return Result.failure('가족 관리자 추가에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    try {
      // 시뮬레이션된 가족 관리자 제거
      await Future.delayed(const Duration(milliseconds: 300));
      return const Success(null, '가족 관리자가 성공적으로 제거되었습니다');
    } catch (error) {
      return Result.failure('가족 관리자 제거에 실패했습니다: ${error.toString()}');
    }
  }
}
