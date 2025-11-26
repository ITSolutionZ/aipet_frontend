import '../../../../shared/core/domain/result.dart';
import '../../../../shared/core/services/firebase_storage_service.dart';
import '../../../../shared/core/services/firestore_pet_service.dart';
import '../../../../shared/core/services/logger_service.dart';
import '../../../../shared/domain/entities/pet_profile_entity.dart';
import '../../domain/repositories/pet_profile_repository.dart';

/// Firebase Firestore를 사용하는 Pet Profile Repository
///
/// 모든 펫 데이터는 Firebase Firestore에서 관리됩니다.
/// 로컬 저장소는 사용하지 않습니다.
class FirestorePetRepository implements PetProfileRepository {
  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    LoggerService.debug('📡 FirestorePetRepository.getAllPets() 호출');
    final result = await FirestorePetService.getAllPets();
    LoggerService.debug(
      '📡 getAllPets 결과: ${result.isSuccess ? "성공 (${result.dataOrNull?.length}개)" : "실패 - ${result.error}"}',
    );
    return result;
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    LoggerService.debug('📡 FirestorePetRepository.getPetById($id) 호출');
    final result = await FirestorePetService.getPetById(id);
    LoggerService.debug(
      '📡 getPetById 결과: ${result.isSuccess ? "성공" : "실패 - ${result.error}"}',
    );
    return result;
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    LoggerService.debug('📡 FirestorePetRepository.createPet() 호출');
    LoggerService.debug('   펫 이름: ${pet.name}');
    LoggerService.debug('   펫 타입: ${pet.type}');
    final result = await FirestorePetService.createPet(pet);
    LoggerService.debug(
      '📡 createPet 결과: ${result.isSuccess ? "성공 - ID: ${result.dataOrNull?.id}" : "실패 - ${result.error}"}',
    );
    return result;
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    LoggerService.debug('📡 FirestorePetRepository.updatePet() 호출');
    final result = await FirestorePetService.updatePet(pet);
    LoggerService.debug(
      '📡 updatePet 결과: ${result.isSuccess ? "성공" : "실패 - ${result.error}"}',
    );
    return result;
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    LoggerService.debug('📡 FirestorePetRepository.deletePet() 호출');
    final result = await FirestorePetService.deletePet(id);
    LoggerService.debug(
      '📡 deletePet 결과: ${result.isSuccess ? "성공" : "실패 - ${result.error}"}',
    );
    return result;
  }

  @override
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    LoggerService.debug('📡 FirestorePetRepository.uploadPetImage() 호출');
    LoggerService.debug('   Pet ID: $petId');
    LoggerService.debug('   Image Path: $imagePath');

    // Firebase Storage를 사용한 이미지 업로드
    final result = await FirebaseStorageService.uploadPetImage(petId, imagePath);

    if (result.isSuccess && result.dataOrNull != null) {
      // 이미지 URL을 Firestore Pet 문서에 업데이트
      try {
        final imageUrl = result.dataOrNull!;
        await FirestorePetService.updatePet(
          PetProfileEntity(
            id: petId,
            name: '', // 업데이트 시 name은 무시됨
            type: '', // 업데이트 시 type은 무시됨
            birthDate: DateTime.now(), // 업데이트 시 birthDate는 무시됨
            gender: '', // 업데이트 시 gender는 무시됨
            weight: 0.0, // 업데이트 시 weight는 무시됨
            imagePath: imageUrl, // ✅ imageUrl만 업데이트
            ownerId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        LoggerService.debug('✅ uploadPetImage 성공 - URL: $imageUrl');
      } catch (e) {
        LoggerService.debug('⚠️ Firestore 업데이트 실패 (이미지는 업로드됨): $e');
        // 이미지는 업로드되었으므로 성공으로 간주
      }
    } else {
      LoggerService.debug('❌ uploadPetImage 실패: ${result.error}');
    }

    return result;
  }

  @override
  Future<Result<void>> updateSharingSettings(
    String petId,
    bool isPublic,
  ) async {
    // TODO: Firestore를 사용한 공유 설정 구현
    return Result.failure('共有設定機能は開発中です');
  }

  @override
  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    // TODO: Firestore를 사용한 가족 관리자 추가 구현
    return Result.failure('家族管理機能は開発中です');
  }

  @override
  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    // TODO: Firestore를 사용한 가족 관리자 제거 구현
    return Result.failure('家族管理機能は開発中です');
  }
}
