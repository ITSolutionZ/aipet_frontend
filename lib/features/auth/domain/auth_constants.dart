import 'package:aipet_frontend/shared/shared.dart';

/// 인증 관련 상수 정의 (공통 상수 사용)
class AuthConstants {
  // 유효성 검사 관련 (공통 상수 사용)
  static const int minPasswordLength = AppConstants.minPasswordLength;
  static const int maxPasswordLength = AppConstants.maxPasswordLength;
  static const int minUsernameLength = AppConstants.minUsernameLength;
  static const int maxUsernameLength = AppConstants.maxUsernameLength;

  // 토큰 관련 (공통 상수 사용)
  static const Duration defaultTokenExpiry = AppConstants.defaultTokenExpiry;
  static const Duration tokenRefreshThreshold = AppConstants.tokenRefreshThreshold;

  // API 타임아웃 (공통 상수 사용)
  static const Duration apiTimeout = AppConstants.apiTimeout;
  static const Duration loginTimeout = AppConstants.apiTimeout;

  // 재시도 관련 (공통 상수 사용)
  static const int maxRetryAttempts = AppConstants.maxRetryAttempts;
  static const Duration retryDelay = AppConstants.retryDelay;

  // UI 관련 (공통 상수 사용)
  static const Duration loadingDebounce = AppConstants.loadingDebounce;
  static const Duration errorDisplayDuration = AppConstants.errorDisplayDuration;

  // 저장소 키 (TokenStorageService에서 사용)
  // 이 상수들은 AuthConfigConstants로 이동되었습니다.
  // TokenStorageService에서 AuthConfigConstants를 직접 참조하도록 변경되었습니다.

  // 메시지 (공통 텍스트 사용)
  static const Map<String, String> errorMessages = {
    'email_required': AppTexts.requiredField,
    'email_invalid': AppTexts.invalidEmail,
    'password_required': AppTexts.requiredField,
    'password_too_short': AppTexts.invalidPassword,
    'password_mismatch': AppTexts.passwordMismatch,
    'username_required': AppTexts.requiredField,
    'username_too_short': AppTexts.tooShort,
    'login_failed': AppTexts.loginFailed,
    'signup_failed': AppTexts.signupFailed,
    'network_error': AppTexts.networkError,
    'server_error': AppTexts.serverError,
    'unknown_error': AppTexts.unknownError,
  };

  // 정규식 패턴
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // 소셜 로그인 프로바이더
  static const List<String> supportedProviders = ['google', 'apple', 'line'];

  // 파일 크기 제한 (프로필 이미지 등)
  static const int maxProfileImageSize = 5 * 1024 * 1024; // 5MB

  // private constructor (유틸리티 클래스)
  const AuthConstants._();
}
