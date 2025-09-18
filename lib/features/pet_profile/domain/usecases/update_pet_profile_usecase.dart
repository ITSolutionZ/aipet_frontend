import '../entities/pet_profile_entity.dart';
import '../exceptions/pet_profile_exceptions.dart';
import '../repositories/pet_profile_repository.dart';
import '../services/pet_profile_domain_service.dart';

/// Update Pet Profile UseCase
///
/// 펫 프로필 업데이트 비즈니스 로직을 캡슐화
class UpdatePetProfileUseCase {
  final PetProfileRepository _repository;
  final PetProfileDomainService _domainService;

  UpdatePetProfileUseCase(
    this._repository,
    this._domainService,
  );

  /// 펫 프로필 업데이트
  ///
  /// [profile] 업데이트할 프로필 정보
  /// [userId] 업데이트 요청자 ID
  Future<UpdatePetProfileResult> execute({
    required PetProfileEntity profile,
    required String userId,
  }) async {
    try {
      // 1. 기존 프로필 조회
      final existingProfile = await _repository.getPetProfile(profile.id);

      // 2. 업데이트 권한 확인
      if (!_domainService.canEditProfile(existingProfile, userId)) {
        return UpdatePetProfileResult.accessDenied(
          'User $userId does not have permission to edit this profile',
        );
      }

      // 3. 비즈니스 규칙 검증
      final validationResult = _validateProfileUpdate(existingProfile, profile);
      if (validationResult != null) {
        return UpdatePetProfileResult.validationError(validationResult);
      }

      // 4. 프로필 업데이트 실행
      final updatedProfile = await _repository.updatePetProfile(profile);

      return UpdatePetProfileResult.success(updatedProfile);
    } on ProfileNotFoundException {
      return UpdatePetProfileResult.notFound('Pet profile not found: ${profile.id}');
    } catch (error) {
      return UpdatePetProfileResult.error('Failed to update pet profile: $error');
    }
  }

  /// 프로필 업데이트 유효성 검증
  String? _validateProfileUpdate(PetProfileEntity existing, PetProfileEntity updated) {
    // 기본 정보 검증
    if (updated.name.trim().isEmpty) {
      return 'Pet name cannot be empty';
    }

    if (updated.name.length > 50) {
      return 'Pet name must be 50 characters or less';
    }

    // 소유자 변경 불가
    if (existing.ownerId != updated.ownerId) {
      return 'Pet owner cannot be changed';
    }

    // 생성일 변경 불가
    if (existing.createdAt != updated.createdAt) {
      return 'Creation date cannot be modified';
    }

    // 생년월일 유효성 검증
    if (updated.birthDate.isAfter(DateTime.now())) {
      return 'Birth date cannot be in the future';
    }

    // 건강 정보 검증 (있는 경우)
    if (updated.healthInfo != null) {
      final healthValidation = _validateHealthInfo(updated.healthInfo!);
      if (healthValidation != null) return healthValidation;
    }

    return null;
  }

  /// 건강 정보 유효성 검증
  String? _validateHealthInfo(HealthInfo healthInfo) {
    if (healthInfo.weight != null && healthInfo.weight! <= 0) {
      return 'Pet weight must be positive';
    }

    if (healthInfo.weight != null && healthInfo.weight! > 200) {
      return 'Pet weight seems unrealistic (over 200kg)';
    }

    return null;
  }
}

/// Update Pet Profile 결과
sealed class UpdatePetProfileResult {
  const UpdatePetProfileResult();

  const factory UpdatePetProfileResult.success(PetProfileEntity profile) = UpdatePetProfileSuccess;
  const factory UpdatePetProfileResult.notFound(String message) = UpdatePetProfileNotFound;
  const factory UpdatePetProfileResult.accessDenied(String message) = UpdatePetProfileAccessDenied;
  const factory UpdatePetProfileResult.validationError(String message) = UpdatePetProfileValidationError;
  const factory UpdatePetProfileResult.error(String message) = UpdatePetProfileError;
}

class UpdatePetProfileSuccess extends UpdatePetProfileResult {
  final PetProfileEntity profile;
  const UpdatePetProfileSuccess(this.profile);
}

class UpdatePetProfileNotFound extends UpdatePetProfileResult {
  final String message;
  const UpdatePetProfileNotFound(this.message);
}

class UpdatePetProfileAccessDenied extends UpdatePetProfileResult {
  final String message;
  const UpdatePetProfileAccessDenied(this.message);
}

class UpdatePetProfileValidationError extends UpdatePetProfileResult {
  final String message;
  const UpdatePetProfileValidationError(this.message);
}

class UpdatePetProfileError extends UpdatePetProfileResult {
  final String message;
  const UpdatePetProfileError(this.message);
}

