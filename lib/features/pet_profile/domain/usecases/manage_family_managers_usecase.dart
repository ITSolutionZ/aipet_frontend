import '../../../../shared/shared.dart';
import '../exceptions/pet_profile_exceptions.dart';
import '../repositories/pet_profile_repository.dart';
import '../services/pet_profile_domain_service.dart';

/// Manage Family Managers UseCase
///
/// 패밀리 매니저 관리 비즈니스 로직을 캡슐화
class ManageFamilyManagersUseCase {
  final PetProfileRepository _repository;
  final PetProfileDomainService _domainService;

  ManageFamilyManagersUseCase(this._repository, this._domainService);

  /// 패밀리 매니저 추가
  ///
  /// [petId] 펫 ID
  /// [ownerId] 펫 소유자 ID
  /// [newManagerId] 추가할 매니저 ID
  Future<Result<void>> addFamilyManager({
    required String petId,
    required String ownerId,
    required String newManagerId,
  }) async {
    try {
      // 1. 프로필 조회
      final profile = await _repository.getPetProfile(petId);

      // 2. 권한 및 비즈니스 규칙 확인
      if (!_domainService.canAddFamilyManager(profile, ownerId, newManagerId)) {
        return Result.failure(
          'Cannot add family manager: insufficient permissions or invalid request',
        );
      }

      // 3. 매니저 추가 실행
      await _repository.addFamilyManager(petId, newManagerId);

      return Result.success('Family manager added successfully');
    } on ProfileNotFoundException {
      return Result.failure('Pet profile not found');
    } catch (error) {
      return Result.failure('Failed to add family manager: $error');
    }
  }

  /// 패밀리 매니저 제거
  ///
  /// [petId] 펫 ID
  /// [ownerId] 펫 소유자 ID
  /// [managerIdToRemove] 제거할 매니저 ID
  Future<Result<void>> removeFamilyManager({
    required String petId,
    required String ownerId,
    required String managerIdToRemove,
  }) async {
    try {
      // 1. 프로필 조회
      final profile = await _repository.getPetProfile(petId);

      // 2. 소유자 권한 확인
      if (profile.ownerId != ownerId) {
        return Result.failure('Only the pet owner can remove family managers');
      }

      // 3. 매니저 존재 확인
      if (!profile.familyManagerIds.contains(managerIdToRemove)) {
        return Result.failure('User is not a family manager for this pet');
      }

      // 4. 매니저 제거 실행
      await _repository.removeFamilyManager(petId, managerIdToRemove);

      return Result.success('Family manager removed successfully');
    } on ProfileNotFoundException {
      return Result.failure('Pet profile not found');
    } catch (error) {
      return Result.failure('Failed to remove family manager: $error');
    }
  }

  /// 패밀리 매니저 목록 조회
  ///
  /// [petId] 펫 ID
  /// [requesterId] 조회 요청자 ID
  Future<Result<List<String>>> getFamilyManagers({
    required String petId,
    required String requesterId,
  }) async {
    try {
      // 1. 프로필 조회
      final profile = await _repository.getPetProfile(petId);

      // 2. 조회 권한 확인
      if (!_domainService.canEditProfile(profile, requesterId)) {
        return Result.failure(
          'Access denied: user cannot view family managers',
        );
      }

      // 3. 매니저 목록 반환
      return Result.success(
        'Family managers loaded successfully',
        profile.familyManagerIds,
      );
    } on ProfileNotFoundException {
      return Result.failure('Pet profile not found');
    } catch (error) {
      return Result.failure('Failed to get family managers: $error');
    }
  }
}
