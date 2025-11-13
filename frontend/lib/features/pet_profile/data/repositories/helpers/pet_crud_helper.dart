import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/local_data_manager.dart';

/// Pet CRUD 연산 헬퍼
class PetCrudHelper {
  /// 펫 생성
  static Future<Result<PetProfileEntity>> createPet(
    LocalDataManager localDataManager,
    PetProfileEntity pet,
  ) async {
    try {
      // 새로운 ID 생성 및 시간 설정
      final newPet = pet.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await localDataManager.loadPetProfiles();

      // 새 펫 추가
      localPets.add(newPet.toJson());

      // 로컬 저장소에 저장
      await localDataManager.savePetProfiles(localPets);

      return Result.success('펫이 성공적으로 생성되었습니다', newPet);
    } catch (error) {
      LoggerService.debug('createPet error: $error');
      return Result.failure('펫 생성에 실패했습니다: ${error.toString()}');
    }
  }

  /// 펫 업데이트
  static Future<Result<PetProfileEntity>> updatePet(
    LocalDataManager localDataManager,
    PetProfileEntity pet,
  ) async {
    try {
      // 업데이트 시간 설정
      final updatedPet = pet.copyWith(updatedAt: DateTime.now());

      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await localDataManager.loadPetProfiles();

      // 해당 펫 찾아서 업데이트
      final petIndex = localPets.indexWhere((p) => p['id'] == pet.id);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      localPets[petIndex] = updatedPet.toJson();

      // 로컬 저장소에 저장
      await localDataManager.savePetProfiles(localPets);

      return Result.success('펫 정보가 성공적으로 업데이트되었습니다', updatedPet);
    } catch (error) {
      LoggerService.debug('updatePet error: $error');
      return Result.failure('펫 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  /// 펫 삭제
  static Future<Result<void>> deletePet(
    LocalDataManager localDataManager,
    String id,
  ) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await localDataManager.loadPetProfiles();

      // 해당 펫 찾아서 삭제
      final petIndex = localPets.indexWhere((p) => p['id'] == id);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      localPets.removeAt(petIndex);

      // 로컬 저장소에 저장
      await localDataManager.savePetProfiles(localPets);

      return Result.success('펫이 성공적으로 삭제되었습니다', null);
    } catch (error) {
      LoggerService.debug('deletePet error: $error');
      return Result.failure('펫 삭제에 실패했습니다: ${error.toString()}');
    }
  }

  /// 펫 이미지 업로드
  static Future<Result<String>> uploadPetImage(
    LocalDataManager localDataManager,
    String petId,
    String imagePath,
  ) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await localDataManager.loadPetProfiles();

      // 해당 펫 찾기
      final petIndex = localPets.indexWhere((p) => p['id'] == petId);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 이미지 경로 업데이트
      localPets[petIndex]['imagePath'] = imagePath;
      localPets[petIndex]['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await localDataManager.savePetProfiles(localPets);

      return Result.success('이미지가 성공적으로 업로드되었습니다', imagePath);
    } catch (error) {
      LoggerService.debug('uploadPetImage error: $error');
      return Result.failure('이미지 업로드에 실패했습니다: ${error.toString()}');
    }
  }

  /// 공유 설정 업데이트
  static Future<Result<void>> updateSharingSettings(
    LocalDataManager localDataManager,
    String petId,
    bool isPublic,
  ) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await localDataManager.loadPetProfiles();

      // 해당 펫 찾기
      final petIndex = localPets.indexWhere((p) => p['id'] == petId);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 공유 설정 업데이트
      localPets[petIndex]['isPublic'] = isPublic;
      localPets[petIndex]['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await localDataManager.savePetProfiles(localPets);

      return Result.success('공유 설정이 성공적으로 업데이트되었습니다', null);
    } catch (error) {
      return Result.failure('공유 설정 업데이트에 실패했습니다: ${error.toString()}');
    }
  }

  /// 가족 관리자 추가
  static Future<Result<void>> addFamilyManager(
    LocalDataManager localDataManager,
    String petId,
    String userId,
  ) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await localDataManager.loadPetProfiles();

      // 해당 펫 찾기
      final petIndex = localPets.indexWhere((p) => p['id'] == petId);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 가족 관리자 목록 가져오기
      final familyManagers = List<String>.from(
        localPets[petIndex]['familyManagers'] ?? [],
      );
      if (!familyManagers.contains(userId)) {
        familyManagers.add(userId);
        localPets[petIndex]['familyManagers'] = familyManagers;
        localPets[petIndex]['updatedAt'] = DateTime.now().toIso8601String();

        // 로컬 저장소에 저장
        await localDataManager.savePetProfiles(localPets);
      }

      return Result.success('가족 관리자가 성공적으로 추가되었습니다', null);
    } catch (error) {
      return Result.failure('가족 관리자 추가에 실패했습니다: ${error.toString()}');
    }
  }

  /// 가족 관리자 제거
  static Future<Result<void>> removeFamilyManager(
    LocalDataManager localDataManager,
    String petId,
    String userId,
  ) async {
    try {
      // 로컬 저장소에서 기존 펫 목록 로드
      final localPets = await localDataManager.loadPetProfiles();

      // 해당 펫 찾기
      final petIndex = localPets.indexWhere((p) => p['id'] == petId);
      if (petIndex == -1) {
        return Result.failure('해당 펫을 찾을 수 없습니다');
      }

      // 가족 관리자 목록에서 제거
      final familyManagers = List<String>.from(
        localPets[petIndex]['familyManagers'] ?? [],
      );
      familyManagers.remove(userId);
      localPets[petIndex]['familyManagers'] = familyManagers;
      localPets[petIndex]['updatedAt'] = DateTime.now().toIso8601String();

      // 로컬 저장소에 저장
      await localDataManager.savePetProfiles(localPets);

      return Result.success('가족 관리자가 성공적으로 제거되었습니다', null);
    } catch (error) {
      return Result.failure('가족 관리자 제거에 실패했습니다: ${error.toString()}');
    }
  }
}
