/// 🎯 통합 상수 정의
///
/// AI와 Auth 기능에서 공통으로 사용하는 상수들을 정의합니다.
library;

/// 공통 에러 메시지
class UnifiedErrorMessages {
  // 네트워크 에러
  static const String networkError = 'ネットワーク接続を確認してください';
  static const String timeoutError = '接続がタイムアウトしました。しばらくしてから再試行してください';
  static const String connectionError = 'ネットワーク接続に問題があります';

  // 인증 에러
  static const String authRequired = 'ログインが必要です';
  static const String authFailed = '認証に失敗しました';
  static const String tokenExpired = 'セッションが期限切れです。再度ログインしてください';

  // 유효성 검사 에러
  static const String fieldRequired = '必須項目です';
  static const String invalidEmail = '有効なメールアドレスを入力してください';
  static const String invalidPassword = 'パスワードは6文字以上で入力してください';
  static const String invalidUsername = 'ユーザー名は2文字以上で入力してください';

  // AI 관련 에러
  static const String aiServiceError = 'AIサービスに問題が発生しました';
  static const String aiResponseError = 'AI応答の生成に失敗しました';
  static const String contentFilterError = 'コンテンツフィルタリングに失敗しました';

  // 일반 에러
  static const String unexpectedError = '予期しないエラーが発生しました';
  static const String serviceUnavailable = 'サービスが一時的に利用できません';
  static const String dataNotFound = 'データが見つかりません';
}

/// 공통 성공 메시지
class UnifiedSuccessMessages {
  static const String operationSuccess = '操作が完了しました';
  static const String dataSaved = 'データが保存されました';
  static const String dataDeleted = 'データが削除されました';
  static const String loginSuccess = 'ログインが完了しました';
  static const String logoutSuccess = 'ログアウトが完了しました';
  static const String registrationSuccess = '登録が完了しました';
  static const String updateSuccess = '更新が完了しました';
}

/// 공통 유효성 검사 규칙
class UnifiedValidationRules {
  // 길이 제한
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 2;
  static const int maxUsernameLength = 50;
  static const int maxMessageLength = 2000;
  static const int maxPetNameLength = 50;

  // 정규식 패턴
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String usernamePattern =
      r'^[a-zA-Z0-9_\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]+$';
  static const String phonePattern = r'^(\+81|0)[0-9]{1,4}[0-9]{1,4}[0-9]{4}$';

  // API 제한
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration apiTimeout = Duration(seconds: 30);
}

/// 공통 상태 코드
class UnifiedStatusCodes {
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int tooManyRequests = 429;
  static const int serverError = 500;
  static const int serviceUnavailable = 503;
}

/// 공통 로깅 레벨
enum UnifiedLogLevel { debug, info, warning, error }

/// 공통 에러 타입
enum UnifiedErrorType {
  network,
  authentication,
  validation,
  authorization,
  notFound,
  conflict,
  server,
  unknown,
}

/// 공통 로딩 상태
enum UnifiedLoadingState { idle, loading, success, error }

/// 공통 폼 필드 타입
enum UnifiedFormFieldType {
  email,
  password,
  username,
  message,
  petName,
  phone,
  text,
  number,
  date,
}

/// 공통 API 엔드포인트
class UnifiedApiEndpoints {
  // Auth 관련
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';

  // AI 관련
  static const String aiChat = '/ai/chat';
  static const String aiCategories = '/ai/categories';
  static const String aiQuestions = '/ai/questions';
  static const String aiHistory = '/ai/history';

  // 펫 관련
  static const String pets = '/pets';
  static const String petProfile = '/pets/profile';
  static const String petHealth = '/pets/health';
  static const String petActivities = '/pets/activities';
}

/// 공통 캐시 키
class UnifiedCacheKeys {
  static const String userProfile = 'user_profile';
  static const String authToken = 'auth_token';
  static const String aiHistory = 'ai_history';
  static const String petProfiles = 'pet_profiles';
  static const String appSettings = 'app_settings';
}

/// 공통 설정값
class UnifiedSettings {
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration cacheExpiry = Duration(minutes: 30);
  static const int maxCacheSize = 100;
  static const int maxHistoryItems = 100;
}
