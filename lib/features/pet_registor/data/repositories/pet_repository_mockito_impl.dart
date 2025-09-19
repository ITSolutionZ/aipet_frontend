import '../../../../shared/shared.dart';
import '../../domain/entities/pet_profile_entity.dart';
import '../../domain/entities/temporary_pet_data_entity.dart';
import '../../domain/repositories/pet_repository.dart';
import '../mock_data/pet_mock_data.dart' as pet_mock_data;

/// Pet Repository Mockito 구현체
///
/// Mock 데이터를 사용하되, Mockito를 통해 테스트 가능하도록 구현
class PetRepositoryMockitoImpl implements PetRepository {
  final List<PetProfileEntity> _pets = [];
  TemporaryPetDataEntity? _temporaryData;

  PetRepositoryMockitoImpl() {
    // 초기 Mock 데이터 로드
    _initializeMockData();
  }

  void _initializeMockData() {
    final mockData = pet_mock_data.PetMockData.getMockPets();
    _pets.addAll(
      mockData
          .map(
            (data) => PetProfileEntity(
              id: data['id'] as String,
              name: data['name'] as String,
              type: data['type'] as String,
              breed: data['breed'] as String?,
              weight: (data['weight'] as num).toDouble(),
              gender: data['gender'] as String,
              birthDate: DateTime.parse(data['birthDate'] as String),
              imagePath: data['imagePath'] as String?,
              ownerId: data['ownerId'] as String,
              createdAt: DateTime.parse(data['createdAt'] as String),
              updatedAt: DateTime.parse(data['updatedAt'] as String),
              isActive: data['isActive'] as bool? ?? true,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    try {
      // API 지연 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 300));

      return Result.success('펫 목록을 성공적으로 조회했습니다', List.from(_pets));
    } catch (error) {
      return Result.failure('펫 목록 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final pet = _pets.where((pet) => pet.id == id).firstOrNull;
      return Result.success('펫 정보를 성공적으로 조회했습니다', pet);
    } catch (error) {
      return Result.failure('펫 조회에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      // 새 펫 추가
      final newPet = pet.copyWith(
        id: _generateId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _pets.add(newPet);

      return Result.success('펫이 성공적으로 생성되었습니다', newPet);
    } catch (error) {
      return Result.failure('펫 생성에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    try {
      await Future.delayed(const Duration(milliseconds: 350));

      final index = _pets.indexWhere((p) => p.id == pet.id);
      if (index == -1) {
        return Result.failure('펫을 찾을 수 없습니다');
      }

      final updatedPet = pet.copyWith(updatedAt: DateTime.now());
      _pets[index] = updatedPet;

      return Result.success('펫 정보가 성공적으로 업데이트되었습니다', updatedPet);
    } catch (error) {
      return Result.failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 250));

      final index = _pets.indexWhere((pet) => pet.id == id);
      if (index == -1) {
        return Result.failure('펫을 찾을 수 없습니다');
      }

      _pets.removeAt(index);

      return Result.success('펫이 성공적으로 삭제되었습니다');
    } catch (error) {
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<void> saveTemporaryPetData(TemporaryPetDataEntity data) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _temporaryData = data;
  }

  @override
  Future<TemporaryPetDataEntity?> getTemporaryPetData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _temporaryData;
  }

  @override
  Future<void> clearTemporaryPetData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _temporaryData = null;
  }

  // Helper method
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Test helper methods for Mockito
  void addPet(PetProfileEntity pet) {
    _pets.add(pet);
  }

  void removePet(String id) {
    _pets.removeWhere((pet) => pet.id == id);
  }

  void clearPets() {
    _pets.clear();
  }

  List<PetProfileEntity> get pets => List.from(_pets);
}
