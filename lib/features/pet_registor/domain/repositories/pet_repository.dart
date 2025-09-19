import '../../../../shared/shared.dart';
import '../entities/pet_profile_entity.dart';
import '../entities/temporary_pet_data_entity.dart';

abstract class PetRepository {
  /// 모든 펫 목록 가져오기
  Future<Result<List<PetProfileEntity>>> getAllPets();

  /// ID로 펫 가져오기
  Future<Result<PetProfileEntity?>> getPetById(String id);

  /// 펫 생성
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet);

  /// 펫 업데이트
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet);

  /// 펫 삭제
  Future<Result<void>> deletePet(String id);

  /// 임시 펫 데이터 저장
  Future<void> saveTemporaryPetData(TemporaryPetDataEntity data);

  /// 임시 펫 데이터 가져오기
  Future<TemporaryPetDataEntity?> getTemporaryPetData();

  /// 임시 펫 데이터 삭제
  Future<void> clearTemporaryPetData();
}
