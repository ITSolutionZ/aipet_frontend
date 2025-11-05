import '../../../../shared/shared.dart';

import '../entities/auth_entities.dart';


/// 인증 리포지토리 인터페이스
///
/// Firebase Auth 구현을 위한 추상화된 인터페이스입니다.
/// 추후 Mockito를 사용한 테스트와 실제 Firebase Auth 구현을 쉽게 전환할 수 있습니다.
abstract class AuthRepository {
  /// 이메일/비밀번호로 로그인
  Future<Result<AuthUser>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// 이메일/비밀번호로 회원가입
  Future<Result<AuthUser>> createUserWithEmailAndPassword(
    String email,
    String password,
  );

  /// 소셜 로그인 (Google)
  Future<Result<AuthUser>> signInWithGoogle();

  /// 소셜 로그인 (Apple)
  Future<Result<AuthUser>> signInWithApple();

  /// 소셜 로그인 (LINE)
  Future<Result<AuthUser>> signInWithLine();

  /// 로그아웃
  Future<void> signOut();

  /// 현재 사용자 상태 확인
  Future<AuthUser?> getCurrentUser();

  /// 비밀번호 재설정 이메일 발송
  Future<void> sendPasswordResetEmail(String email);

  /// 이메일 인증 메일 발송
  Future<void> sendEmailVerification();

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile({String? displayName, String? photoURL});

  /// 계정 삭제
  Future<void> deleteAccount();

  /// Firebase 로그인을 통해 획득한 idToken을 서버 JWT로 교환
  Future<String> exchangeServerToken(String idToken);

  /// 현재 Firebase 사용자의 최신 idToken 획득
  Future<String?> getCurrentUserIdToken();

  /// 저장된 서버 JWT 토큰 확인
  Future<String?> getStoredServerToken();

  /// 서버 JWT 토큰 저장
  Future<void> saveServerToken(String token);

  /// 저장된 서버 JWT 토큰 삭제
  Future<void> clearServerToken();

  /// 사용자 인증 상태 확인 (Firebase + 서버 JWT 모두 유효)
  Future<bool> isAuthenticated();
}

// ✅ AuthResult 클래스 제거 완료
// 모든 auth 기능은 공통 Result<AuthUser> 패턴을 사용합니다.
