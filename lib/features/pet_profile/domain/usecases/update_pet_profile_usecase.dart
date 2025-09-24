import 'package:aipet_frontend/features/pet_profile/domain/exceptions/pet_profile_exceptions.dart';
import 'package:aipet_frontend/features/pet_profile/domain/repositories/pet_profile_repository.dart';
import 'package:aipet_frontend/features/pet_profile/domain/services/pet_profile_domain_service.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// Update Pet Profile UseCase
///
/// 펫 프로필 업데이트 비즈니스 로직을 캡슐화
class UpdatePetProfileUseCase {
  final PetProfileRepository _repository;
  final PetProfileDomainService _domainService;

  UpdatePetProfileUseCase(this._repository, this._domainService);

  /// 펫 프로필 업데이트
  ///
  /// [profile] 업데이트할 프로필 정보
  /// [userId] 업데이트 요청자 ID
  Future<Result<PetProfileEntity>> execute({
    required PetProfileEntity profile,
    required String userId,
  }) async {
    try {
      // 1. 기존 프로필 조회
      final existingProfile = await _repository.getPetProfile(profile.id);

      // 2. 업데이트 권한 확인
      if (!_domainService.canEditProfile(existingProfile, userId)) {
        return Result.failure(
          'User $userId does not have permission to edit this profile',
        );
      }

      // 3. 비즈니스 규칙 검증
      final validationResult = _validateProfileUpdate(existingProfile, profile);
      if (validationResult != null) {
        return Result.failure(validationResult);
      }

      // 4. 프로필 업데이트 실행
      final updatedProfile = await _repository.updatePetProfile(profile);

      return Result.success('Pet profile updated successfully', updatedProfile);
    } on ProfileNotFoundException {
      return Result.failure('Pet profile not found: ${profile.id}');
    } catch (error) {
      return Result.failure('Failed to update pet profile: $error');
    }
  }

  /// 프로필 업데이트 유효성 검증
  String? _validateProfileUpdate(
    PetProfileEntity existing,
    PetProfileEntity updated,
  ) {
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
