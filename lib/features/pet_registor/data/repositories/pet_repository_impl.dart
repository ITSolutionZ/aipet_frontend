import '../../domain/entities/pet_profile_entity.dart';
import '../../domain/entities/temporary_pet_data_entity.dart';
import '../../domain/repositories/pet_repository.dart';

class PetRepositoryImpl implements PetRepository {
  // TODO: 실제 데이터 소스 구현 (API, 로컬 DB 등)

  @override
  Future<List<PetProfileEntity>> getAllPets() async {
    // 시뮬레이션된 데이터
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      PetProfileEntity(
        id: '1',
        name: '멍멍이',
        type: 'dog',
        breed: '골든 리트리버',
        birthDate: DateTime(2020, 3, 15),
        imagePath: 'assets/images/dogs/golden.jpg',
        ownerId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      PetProfileEntity(
        id: '2',
        name: '냥냥이',
        type: 'cat',
        breed: '페르시안',
        birthDate: DateTime(2021, 7, 22),
        imagePath: 'assets/images/cats/persian.jpg',
        ownerId: 'user1',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return newPet;
  }

  @override
  Future<PetProfileEntity> updatePet(PetProfileEntity pet) async {
    // 시뮬레이션된 업데이트 로직
    await Future.delayed(const Duration(milliseconds: 200));

    final updatedPet = pet.copyWith(updatedAt: DateTime.now());

    return updatedPet;
  }

  @override
  Future<void> deletePet(String id) async {
    // 시뮬레이션된 삭제 로직
    await Future.delayed(const Duration(milliseconds: 200));
    // 실제로는 데이터베이스에서 삭제
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
