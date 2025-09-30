import 'package:aipet_frontend/app/config/app_config.dart';

/// Auth 기능 환경별 설정 서비스
///
/// Mock 모드와 Firebase Auth 모드를 구분하여 적절한 인증 방식을 선택합니다.
class AuthConfigService {
  /// 현재 Mock 모드 여부
  static bool get isMockMode => AppConfig.current.isMockMode;

  /// Firebase Auth 사용 여부
  static bool get useFirebaseAuth => !isMockMode;

  /// Mock 데이터 사용 여부
  static bool get useMockData => isMockMode;

  /// 인증 방식 선택
  static AuthMode get authMode => isMockMode ? AuthMode.mock : AuthMode.firebase;

  /// 토큰 만료 시간 (Mock 모드용)
  static Duration get mockTokenExpiry => const Duration(hours: 24);

  /// 토큰 갱신 임계값
  static Duration get tokenRefreshThreshold => const Duration(minutes: 5);

  /// API 타임아웃
  static Duration get apiTimeout => const Duration(seconds: 30);

  /// 재시도 횟수
  static int get maxRetryAttempts => 3;

  /// 재시도 지연 시간
  static Duration get retryDelay => const Duration(seconds: 1);

  /// 로그인 성공 후 리다이렉트 지연 시간
  static Duration get loginRedirectDelay => const Duration(milliseconds: 500);

  /// 에러 메시지 표시 시간
  static Duration get errorDisplayDuration => const Duration(seconds: 5);

  /// 로딩 상태 디바운스 시간
  static Duration get loadingDebounce => const Duration(milliseconds: 300);
}

/// 인증 모드
enum AuthMode {
  /// Mock 데이터 사용 (개발 환경)
  mock,

  /// Firebase Auth 사용 (프로덕션 환경)
  firebase,
}

/// Auth 설정 상수
class AuthConfigConstants {
  // 저장소 키
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiresAtKey = 'token_expires_at';
  static const String tokenTypeKey = 'token_type';
  static const String savedEmailKey = 'saved_email';
  static const String rememberMeKey = 'remember_me';
  static const String firebaseIdTokenKey = 'firebase_id_token';
  static const String firebaseIdTokenExpiresKey = 'firebase_id_token_expires';

  // Firebase 관련
  static const String firebaseAuthDomain = 'firebase_auth_domain';
  static const String firebaseProjectId = 'firebase_project_id';
  static const String firebaseApiKey = 'firebase_api_key';

  // 소셜 로그인
  static const List<String> supportedSocialProviders = ['google', 'apple', 'line'];

  // 보안 설정
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 2;
  static const int maxUsernameLength = 20;

  // 파일 크기 제한
  static const int maxProfileImageSize = 5 * 1024 * 1024; // 5MB

  // private constructor (유틸리티 클래스)
  const AuthConfigConstants._();
}
