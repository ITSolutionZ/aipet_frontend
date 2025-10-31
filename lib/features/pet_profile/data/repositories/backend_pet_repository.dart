import '../../../../shared/core/domain/result.dart';
import '../../../../shared/domain/entities/pet_profile_entity.dart';
import '../../domain/repositories/pet_profile_repository.dart';
import '../services/backend_pet_api_service.dart';

/// 백엔드 API를 사용하는 Pet Profile Repository
///
/// 모든 펫 데이터는 백엔드 서버에서 관리됩니다.
/// 로컬 저장소는 사용하지 않습니다.
class BackendPetRepository implements PetProfileRepository {
  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    return BackendPetApiService.getAllPets();
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    return BackendPetApiService.getPetById(id);
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    return BackendPetApiService.createPet(pet);
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    return BackendPetApiService.updatePet(pet);
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    return BackendPetApiService.deletePet(id);
  }

  @override
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    // TODO: 이미지 업로드 API 구현
    return Result.failure('画像アップロード機能は開発中です');
  }

  @override
  Future<Result<void>> updateSharingSettings(
    String petId,
    bool isPublic,
  ) async {
    // TODO: 공유 설정 API 구현
    return Result.failure('共有設定機能は開発中です');
  }

  @override
  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    // TODO: 가족 관리자 추가 API 구현
    return Result.failure('家族管理機能は開発中です');
  }

  @override
  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    // TODO: 가족 관리자 제거 API 구현
    return Result.failure('家族管理機能は開発中です');
  }
}
