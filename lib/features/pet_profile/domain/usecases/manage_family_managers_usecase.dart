import '../exceptions/pet_profile_exceptions.dart';
import '../repositories/pet_profile_repository.dart';
import '../services/pet_profile_domain_service.dart';

/// Manage Family Managers UseCase
///
/// 패밀리 매니저 관리 비즈니스 로직을 캡슐화
class ManageFamilyManagersUseCase {
  final PetProfileRepository _repository;
  final PetProfileDomainService _domainService;

  ManageFamilyManagersUseCase(
    this._repository,
    this._domainService,
  );

  /// 패밀리 매니저 추가
  ///
  /// [petId] 펫 ID
  /// [ownerId] 펫 소유자 ID
  /// [newManagerId] 추가할 매니저 ID
  Future<ManageFamilyManagerResult> addFamilyManager({
    required String petId,
    required String ownerId,
    required String newManagerId,
  }) async {
    try {
      // 1. 프로필 조회
      final profile = await _repository.getPetProfile(petId);

      // 2. 권한 및 비즈니스 규칙 확인
      if (!_domainService.canAddFamilyManager(profile, ownerId, newManagerId)) {
        return const ManageFamilyManagerResult.accessDenied(
          'Cannot add family manager: insufficient permissions or invalid request',
        );
      }

      // 3. 매니저 추가 실행
      await _repository.addFamilyManager(petId, newManagerId);

      return const ManageFamilyManagerResult.success('Family manager added successfully');
    } on ProfileNotFoundException {
      return const ManageFamilyManagerResult.notFound('Pet profile not found');
    } catch (error) {
      return ManageFamilyManagerResult.error('Failed to add family manager: $error');
    }
  }

  /// 패밀리 매니저 제거
  ///
  /// [petId] 펫 ID
  /// [ownerId] 펫 소유자 ID
  /// [managerIdToRemove] 제거할 매니저 ID
  Future<ManageFamilyManagerResult> removeFamilyManager({
    required String petId,
    required String ownerId,
    required String managerIdToRemove,
  }) async {
    try {
      // 1. 프로필 조회
      final profile = await _repository.getPetProfile(petId);

      // 2. 소유자 권한 확인
      if (profile.ownerId != ownerId) {
        return const ManageFamilyManagerResult.accessDenied(
          'Only the pet owner can remove family managers',
        );
      }

      // 3. 매니저 존재 확인
      if (!profile.familyManagerIds.contains(managerIdToRemove)) {
        return const ManageFamilyManagerResult.validationError(
          'User is not a family manager for this pet',
        );
      }

      // 4. 매니저 제거 실행
      await _repository.removeFamilyManager(petId, managerIdToRemove);

      return const ManageFamilyManagerResult.success('Family manager removed successfully');
    } on ProfileNotFoundException {
      return const ManageFamilyManagerResult.notFound('Pet profile not found');
    } catch (error) {
      return ManageFamilyManagerResult.error('Failed to remove family manager: $error');
    }
  }

  /// 패밀리 매니저 목록 조회
  ///
  /// [petId] 펫 ID
  /// [requesterId] 조회 요청자 ID
  Future<GetFamilyManagersResult> getFamilyManagers({
    required String petId,
    required String requesterId,
  }) async {
    try {
      // 1. 프로필 조회
      final profile = await _repository.getPetProfile(petId);

      // 2. 조회 권한 확인
      if (!_domainService.canEditProfile(profile, requesterId)) {
        return const GetFamilyManagersResult.accessDenied(
          'Access denied: user cannot view family managers',
        );
      }

      // 3. 매니저 목록 반환
      return GetFamilyManagersResult.success(profile.familyManagerIds);
    } on ProfileNotFoundException {
      return const GetFamilyManagersResult.notFound('Pet profile not found');
    } catch (error) {
      return GetFamilyManagersResult.error('Failed to get family managers: $error');
    }
  }
}

/// Manage Family Manager 결과
sealed class ManageFamilyManagerResult {
  const ManageFamilyManagerResult();

  const factory ManageFamilyManagerResult.success(String message) = ManageFamilyManagerSuccess;
  const factory ManageFamilyManagerResult.notFound(String message) = ManageFamilyManagerNotFound;
  const factory ManageFamilyManagerResult.accessDenied(String message) = ManageFamilyManagerAccessDenied;
  const factory ManageFamilyManagerResult.validationError(String message) = ManageFamilyManagerValidationError;
  const factory ManageFamilyManagerResult.error(String message) = ManageFamilyManagerError;
}

class ManageFamilyManagerSuccess extends ManageFamilyManagerResult {
  final String message;
  const ManageFamilyManagerSuccess(this.message);
}

class ManageFamilyManagerNotFound extends ManageFamilyManagerResult {
  final String message;
  const ManageFamilyManagerNotFound(this.message);
}

class ManageFamilyManagerAccessDenied extends ManageFamilyManagerResult {
  final String message;
  const ManageFamilyManagerAccessDenied(this.message);
}

class ManageFamilyManagerValidationError extends ManageFamilyManagerResult {
  final String message;
  const ManageFamilyManagerValidationError(this.message);
}

class ManageFamilyManagerError extends ManageFamilyManagerResult {
  final String message;
  const ManageFamilyManagerError(this.message);
}

/// Get Family Managers 결과
sealed class GetFamilyManagersResult {
  const GetFamilyManagersResult();

  const factory GetFamilyManagersResult.success(List<String> managerIds) = GetFamilyManagersSuccess;
  const factory GetFamilyManagersResult.notFound(String message) = GetFamilyManagersNotFound;
  const factory GetFamilyManagersResult.accessDenied(String message) = GetFamilyManagersAccessDenied;
  const factory GetFamilyManagersResult.error(String message) = GetFamilyManagersError;
}

class GetFamilyManagersSuccess extends GetFamilyManagersResult {
  final List<String> managerIds;
  const GetFamilyManagersSuccess(this.managerIds);
}

class GetFamilyManagersNotFound extends GetFamilyManagersResult {
  final String message;
  const GetFamilyManagersNotFound(this.message);
}

class GetFamilyManagersAccessDenied extends GetFamilyManagersResult {
  final String message;
  const GetFamilyManagersAccessDenied(this.message);
}

class GetFamilyManagersError extends GetFamilyManagersResult {
  final String message;
  const GetFamilyManagersError(this.message);
}