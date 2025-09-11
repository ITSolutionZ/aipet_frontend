import '../../../../shared/mock_data/features/pet/pet_mock_data.dart';
import '../../domain/entities/pet_profile_entity.dart';
import '../../domain/entities/temporary_pet_data_entity.dart';
import '../../domain/repositories/pet_repository.dart';

class PetRepositoryImpl implements PetRepository {
  // TODO: 실제 데이터 소스 구현 (API, 로컬 DB 등)

  @override
  Future<List<PetProfileEntity>> getAllPets() async {
    // 시뮬레이션된 데이터
    await Future.delayed(const Duration(milliseconds: 500));

    return PetMockData.getMockPets();
  }

  @override
  Future<PetProfileEntity?> getPetById(String id) async {
    final pets = await getAllPets();
    try {
      return pets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PetProfileEntity> createPet(PetProfileEntity pet) async {
    // 시뮬레이션된 생성 로직
    await Future.delayed(const Duration(milliseconds: 300));

    final newPet = pet.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Mock 데이터에 실제로 추가
    return PetMockData.addPet(newPet);
  }

  @override
  Future<PetProfileEntity> updatePet(PetProfileEntity pet) async {
    // 시뮬레이션된 업데이트 로직
    await Future.delayed(const Duration(milliseconds: 200));

    final updatedPet = pet.copyWith(updatedAt: DateTime.now());

    // Mock 데이터에서 실제로 업데이트
    final result = PetMockData.updatePet(updatedPet);
    if (result == null) {
      throw Exception('펫을 찾을 수 없습니다: ${pet.id}');
    }

    return result;
  }

  @override
  Future<void> deletePet(String id) async {
    // 시뮬레이션된 삭제 로직
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Mock 데이터에서 실제로 삭제
    final success = PetMockData.deletePet(id);
    if (!success) {
      throw Exception('펫을 찾을 수 없습니다: $id');
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
