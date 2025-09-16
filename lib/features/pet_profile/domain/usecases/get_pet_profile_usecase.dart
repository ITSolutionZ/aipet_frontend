import '../entities/pet_profile_entity.dart';
import '../exceptions/pet_profile_exceptions.dart';
import '../repositories/pet_profile_repository.dart';

/// Get Pet Profile UseCase
///
/// 펫 프로필 조회 비즈니스 로직을 캡슐화
class GetPetProfileUseCase {
  final PetProfileRepository _repository;

  GetPetProfileUseCase(
    this._repository,
  );

  /// 펫 프로필 조회
  ///
  /// [petId] 조회할 펫 ID
  /// [requesterId] 조회 요청자 ID (권한 확인용)
  Future<GetPetProfileResult> execute({
    required String petId,
    required String requesterId,
  }) async {
    try {
      // 1. 프로필 조회
      final profile = await _repository.getPetProfile(petId);

      // 2. 조회 권한 확인
      if (!_canViewProfile(profile, requesterId)) {
        return GetPetProfileResult.accessDenied(
          'Profile access denied for user: $requesterId',
        );
      }

      // 3. 성공 결과 반환
      return GetPetProfileResult.success(profile);
    } on ProfileNotFoundException {
      return GetPetProfileResult.notFound('Pet profile not found: $petId');
    } catch (error) {
      return GetPetProfileResult.error('Failed to get pet profile: $error');
    }
  }

  /// 프로필 조회 권한 확인
  bool _canViewProfile(PetProfileEntity profile, String requesterId) {
    // 소유자나 패밀리 매니저는 항상 조회 가능
    if (profile.canBeEditedBy(requesterId)) {
      return true;
    }

    // 공개 프로필인 경우 모든 사용자가 조회 가능
    if (profile.visibilityLevel == ProfileVisibilityLevel.public) {
      return true;
    }

    // 그 외에는 조회 불가
    return false;
  }
}

/// Get Pet Profile 결과
sealed class GetPetProfileResult {
  const GetPetProfileResult();

  const factory GetPetProfileResult.success(PetProfileEntity profile) = GetPetProfileSuccess;
  const factory GetPetProfileResult.notFound(String message) = GetPetProfileNotFound;
  const factory GetPetProfileResult.accessDenied(String message) = GetPetProfileAccessDenied;
  const factory GetPetProfileResult.error(String message) = GetPetProfileError;
}

class GetPetProfileSuccess extends GetPetProfileResult {
  final PetProfileEntity profile;
  const GetPetProfileSuccess(this.profile);
}

class GetPetProfileNotFound extends GetPetProfileResult {
  final String message;
  const GetPetProfileNotFound(this.message);
}

class GetPetProfileAccessDenied extends GetPetProfileResult {
  final String message;
  const GetPetProfileAccessDenied(this.message);
}

class GetPetProfileError extends GetPetProfileResult {
  final String message;
  const GetPetProfileError(this.message);
}

// ProfileNotFoundException는 ../exceptions/pet_profile_exceptions.dart에서 import