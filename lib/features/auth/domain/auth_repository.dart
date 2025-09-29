/// 인증 관련 비즈니스 로직을 정의하는 추상 클래스
abstract class AuthRepository {
  /// Firebase 로그인을 통해 획득한 idToken을 서버 JWT로 교환
  ///
  /// [idToken] Firebase Auth에서 획득한 ID 토큰
  ///
  /// Returns: 서버에서 발급한 JWT 토큰
  /// Throws: 교환 실패 시 Exception
  Future<String> exchangeServerToken(String idToken);

  /// 현재 Firebase 사용자의 최신 idToken 획득
  ///
  /// Returns: Firebase ID 토큰 또는 null (로그인되지 않은 경우)
  /// Throws: 토큰 획득 실패 시 Exception
  Future<String?> getCurrentUserIdToken();

  /// 저장된 서버 JWT 토큰 확인
  ///
  /// Returns: 서버 JWT 토큰 또는 null
  Future<String?> getStoredServerToken();

  /// 서버 JWT 토큰 저장
  ///
  /// [token] 저장할 서버 JWT 토큰
  Future<void> saveServerToken(String token);

  /// 저장된 서버 JWT 토큰 삭제
  Future<void> clearServerToken();

  /// 사용자 인증 상태 확인
  ///
  /// Returns: 인증 여부 (Firebase + 서버 JWT 모두 유효)
  Future<bool> isAuthenticated();
}
