import 'package:aipet_frontend/shared/shared.dart';


/// Pet Profile Domain Service
///
/// Pet Profile 도메인의 복잡한 비즈니스 규칙과 정책을 처리하는 서비스
abstract class PetProfileDomainService {
  /// 프로필 편집 권한 검증
  bool canEditProfile(PetProfileEntity profile, String userId);

  /// 프로필 삭제 권한 검증
  bool canDeleteProfile(PetProfileEntity profile, String userId);

  /// 프로필 조회 권한 검증
  bool canViewProfile(PetProfileEntity profile, String userId);
}

/// Pet Profile Domain Service 구현체
class PetProfileDomainServiceImpl implements PetProfileDomainService {
  @override
  bool canEditProfile(PetProfileEntity profile, String userId) {
    // 소유자만 편집 가능
    return profile.ownerId == userId;
  }

  @override
  bool canDeleteProfile(PetProfileEntity profile, String userId) {
    // 소유자만 삭제 가능
    return profile.ownerId == userId;
  }

  @override
  bool canViewProfile(PetProfileEntity profile, String userId) {
    // 소유자만 조회 가능 (기본적으로 private)
    return profile.ownerId == userId;
  }
}
