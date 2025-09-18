import '../entities/pet_profile_entity.dart';

/// Pet Profile Domain Service
///
/// Pet Profile 도메인의 복잡한 비즈니스 규칙과 정책을 처리하는 서비스
abstract class PetProfileDomainService {
  /// 프로필 공유 권한 검증
  bool canShareProfile(PetProfileEntity profile, String requesterId);

  /// 프로필 편집 권한 검증
  bool canEditProfile(PetProfileEntity profile, String userId);

  /// 공유 링크 생성 가능 여부 확인
  bool canGenerateShareLink(PetProfileEntity profile);

  /// 건강 정보 업데이트 권한 확인
  bool canUpdateHealthInfo(PetProfileEntity profile, String userId);

  /// 패밀리 매니저 추가 가능 여부 확인
  bool canAddFamilyManager(PetProfileEntity profile, String ownerId, String newManagerId);
}

/// Pet Profile Domain Service 구현체
class PetProfileDomainServiceImpl implements PetProfileDomainService {
  @override
  bool canShareProfile(PetProfileEntity profile, String requesterId) {
    // 프로필 소유자이거나 패밀리 매니저인 경우만 공유 가능
    if (!profile.canBeEditedBy(requesterId)) {
      return false;
    }

    // 공유 설정이 활성화되어 있는지 확인
    if (!profile.sharingSettings.allowSharing) {
      return false;
    }

    // 프로필 공개 수준 확인
    if (profile.visibilityLevel == ProfileVisibilityLevel.private) {
      return false;
    }

    return true;
  }

  @override
  bool canEditProfile(PetProfileEntity profile, String userId) {
    return profile.canBeEditedBy(userId);
  }

  @override
  bool canGenerateShareLink(PetProfileEntity profile) {
    return profile.sharingSettings.allowSharing &&
           profile.sharingSettings.allowDirectLink &&
           profile.visibilityLevel != ProfileVisibilityLevel.private;
  }

  @override
  bool canUpdateHealthInfo(PetProfileEntity profile, String userId) {
    // 건강 정보는 소유자와 패밀리 매니저만 수정 가능
    return profile.canBeEditedBy(userId);
  }

  @override
  bool canAddFamilyManager(PetProfileEntity profile, String ownerId, String newManagerId) {
    // 소유자만 패밀리 매니저를 추가할 수 있음
    if (profile.ownerId != ownerId) {
      return false;
    }

    // 이미 패밀리 매니저인 경우 추가 불가
    if (profile.familyManagerIds.contains(newManagerId)) {
      return false;
    }

    // 소유자 자신을 패밀리 매니저로 추가하는 것은 불필요
    if (profile.ownerId == newManagerId) {
      return false;
    }

    return true;
  }
}