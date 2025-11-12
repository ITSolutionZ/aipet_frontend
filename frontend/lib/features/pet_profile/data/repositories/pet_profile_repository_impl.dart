import '../../../../shared/shared.dart';

import '../../../../../features/pet_profile/domain/repositories/pet_profile_repository.dart';
import '../services/backend_pet_api_service.dart';

class PetProfileRepositoryImpl implements PetProfileRepository {
  // Backend API를 사용하도록 변경
  // LocalStorage는 더 이상 사용하지 않음

  @override
  Future<Result<List<PetProfileEntity>>> getAllPets() async {
    LoggerService.debug('=== getAllPets (Backend API) called ===');
    return await BackendPetApiService.getAllPets();
  }

  @override
  Future<Result<PetProfileEntity?>> getPetById(String id) async {
    LoggerService.debug('=== getPetById (Backend API) called with id: $id ===');
    return await BackendPetApiService.getPetById(id);
  }

  @override
  Future<Result<PetProfileEntity>> createPet(PetProfileEntity pet) async {
    LoggerService.debug('=== createPet (Backend API) called ===');
    return await BackendPetApiService.createPet(pet);
  }

  @override
  Future<Result<PetProfileEntity>> updatePet(PetProfileEntity pet) async {
    LoggerService.debug('=== updatePet (Backend API) called for pet: ${pet.id} ===');
    return await BackendPetApiService.updatePet(pet);
  }

  @override
  Future<Result<void>> deletePet(String id) async {
    LoggerService.debug('=== deletePet (Backend API) called for id: $id ===');
    return await BackendPetApiService.deletePet(id);
  }

  @override
  Future<Result<String>> uploadPetImage(String petId, String imagePath) async {
    LoggerService.debug('💾 uploadPetImage - petId: $petId, imagePath: $imagePath');

    // TODO: Backend에 이미지 업로드 API 구현 필요
    // 현재는 pet 업데이트로 이미지 경로만 저장
    final petResult = await BackendPetApiService.getPetById(petId);

    if (!petResult.isSuccess || petResult.data == null) {
      return Result.failure('펫을 찾을 수 없습니다');
    }

    final pet = petResult.data!;
    final updatedPet = pet.copyWith(imagePath: imagePath);
    final updateResult = await BackendPetApiService.updatePet(updatedPet);

    if (updateResult.isSuccess) {
      return Result.success('이미지가 업로드되었습니다', imagePath);
    } else {
      return Result.failure(updateResult.message);
    }
  }

  @override
  Future<Result<void>> updateSharingSettings(
    String petId,
    bool isPublic,
  ) async {
    LoggerService.debug('updateSharingSettings - petId: $petId, isPublic: $isPublic');

    // TODO: Backend에 공유 설정 API 구현 필요
    // 현재는 additionalInfo에 저장
    final petResult = await BackendPetApiService.getPetById(petId);

    if (!petResult.isSuccess || petResult.data == null) {
      return Result.failure('펫을 찾을 수 없습니다');
    }

    final pet = petResult.data!;
    final updatedAdditionalInfo = {...pet.additionalInfo, 'isPublic': isPublic};
    final updatedPet = pet.copyWith(additionalInfo: updatedAdditionalInfo);
    final updateResult = await BackendPetApiService.updatePet(updatedPet);

    if (updateResult.isSuccess) {
      return Result.success('공유 설정이 업데이트되었습니다');
    } else {
      return Result.failure(updateResult.message);
    }
  }

  @override
  Future<Result<void>> addFamilyManager(String petId, String userId) async {
    LoggerService.debug('addFamilyManager - petId: $petId, userId: $userId');

    // TODO: Backend에 가족 관리자 API 구현 필요
    return Result.success('가족 관리자 기능은 추후 구현 예정입니다');
  }

  @override
  Future<Result<void>> removeFamilyManager(String petId, String userId) async {
    LoggerService.debug('removeFamilyManager - petId: $petId, userId: $userId');

    // TODO: Backend에 가족 관리자 API 구현 필요
    return Result.success('가족 관리자 기능은 추후 구현 예정입니다');
  }
}
