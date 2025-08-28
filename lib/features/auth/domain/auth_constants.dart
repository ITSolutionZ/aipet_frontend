/// 인증 관련 상수 정의
class AuthConstants {
  // 유효성 검사 관련
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 2;
  static const int maxUsernameLength = 20;
  
  // 토큰 관련
  static const Duration defaultTokenExpiry = Duration(hours: 24);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  
  // API 타임아웃
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration loginTimeout = Duration(seconds: 30);
  
  // 재시도 관련
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  // UI 관련
  static const Duration loadingDebounce = Duration(milliseconds: 300);
  static const Duration errorDisplayDuration = Duration(seconds: 5);
  
  // 저장소 키 (TokenStorageService에서 사용)
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiresAtKey = 'token_expires_at';
  static const String tokenTypeKey = 'token_type';
  static const String savedEmailKey = 'saved_email';
  static const String rememberMeKey = 'remember_me';
  
  // 메시지
  static const Map<String, String> errorMessages = {
    'email_required': 'メールアドレスを入力してください',
    'email_invalid': '正しいメールアドレスを入力してください',
    'password_required': 'パスワードを入力してください',
    'password_too_short': 'パスワードは6文字以上である必要があります',
    'password_mismatch': 'パスワードが一致しません',
    'username_required': 'ユーザー名を入力してください',
    'username_too_short': 'ユーザー名は2文字以上である必要があります',
    'login_failed': 'ログインに失敗しました',
    'signup_failed': '会員登録に失敗しました',
    'network_error': 'インターネット接続を確認してください',
    'server_error': 'サーバーエラーが発生しました',
    'unknown_error': '予期しないエラーが発生しました',
  };
  
  // 정규식 패턴
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // 소셜 로그인 프로바이더
  static const List<String> supportedProviders = [
    'google',
    'apple',
    'line',
  ];
  
  // 파일 크기 제한 (프로필 이미지 등)
  static const int maxProfileImageSize = 5 * 1024 * 1024; // 5MB
  
  // private constructor (유틸리티 클래스)
  const AuthConstants._();
}