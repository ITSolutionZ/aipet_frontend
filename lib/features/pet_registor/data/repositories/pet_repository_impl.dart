import '../../../../app/config/app_config.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/pet_profile_entity.dart';
import '../../domain/entities/temporary_pet_data_entity.dart';
import '../../domain/repositories/pet_repository.dart';

class PetRepositoryImpl implements PetRepository {
  // TODO: 실제 데이터 소스 구현 (API, 로컬 DB 등)

  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      // 시뮬레이션된 데이터
      if (AppConfig.current.environment == 'test') {
        // 테스트 환경에서는 즉시 실행
        await Future.delayed(const Duration(milliseconds: 1));
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final pets = PetMockData.getMockPets();
      return Result.success('펫 목록을 성공적으로 조회했습니다', pets);
    } catch (error) {
      return Result.failure('펫 목록 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      final result = await getAllPets();
      if (result.isSuccess) {
        final pets = result.data!;
        try {
          final pet = pets.firstWhere((pet) => pet.id == id);
          return Result.success('펫 정보를 성공적으로 조회했습니다', pet);
        } catch (e) {
          return Result.success('펫 정보를 성공적으로 조회했습니다', null);
        }
      } else {
        return Result.failure(result.message);
      }
    } catch (error) {
      return Result.failure('펫 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    try {
      // 시뮬레이션된 생성 로직
      if (AppConfig.current.environment == 'test') {
        await Future.delayed(const Duration(milliseconds: 1));
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      final newPet = pet.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Mock 데이터에 실제로 추가
      final createdPet = PetMockData.addPet(newPet);
      return Result.success('펫이 성공적으로 생성되었습니다', createdPet);
    } catch (error) {
      return Result.failure('펫 생성에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    try {
      // 시뮬레이션된 업데이트 로직
      if (AppConfig.current.environment == 'test') {
        await Future.delayed(const Duration(milliseconds: 1));
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final updatedPet = pet.copyWith(updatedAt: DateTime.now());

      // Mock 데이터에서 실제로 업데이트
      final result = PetMockData.updatePet(updatedPet);
      if (result == null) {
        return Result.failure('펫을 찾을 수 없습니다: ${pet.id}');
      }

      return Result.success('펫 정보가 성공적으로 업데이트되었습니다', result);
    } catch (error) {
      return Result.failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    try {
      // 시뮬레이션된 삭제 로직
      if (AppConfig.current.environment == 'test') {
        await Future.delayed(const Duration(milliseconds: 1));
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Mock 데이터에서 실제로 삭제
      final success = PetMockData.deletePet(id);
      if (!success) {
        return Result.failure('펫을 찾을 수 없습니다: $id');
      }

      return Result.success('펫이 성공적으로 삭제되었습니다', null);
    } catch (error) {
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<void> saveTemporaryPetData(TemporaryPetDataEntity data) async {
    // 시뮬레이션된 임시 데이터 저장
    await Future.delayed(const Duration(milliseconds: 100));
    // 실제로는 SharedPreferences나 로컬 DB에 저장
  }

  @override
  Future<TemporaryPetDataEntity?> getTemporaryPetData() async {
    // 시뮬레이션된 임시 데이터 로드
    await Future.delayed(const Duration(milliseconds: 100));
    // 실제로는 SharedPreferences나 로컬 DB에서 로드
    return null;
  }

  @override
  Future<void> clearTemporaryPetData() async {
    // 시뮬레이션된 임시 데이터 삭제
    await Future.delayed(const Duration(milliseconds: 100));
    // 실제로는 SharedPreferences나 로컬 DB에서 삭제
  }
}
