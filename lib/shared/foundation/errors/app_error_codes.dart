/// 🎯 공통 앱 에러 코드 정의
///
/// 타입 안전성을 보장하는 열거형 기반 에러 코드들을 정의합니다.
/// 각 Feature별로 고유한 에러 코드를 가질 수 있도록 설계되었습니다.
library;

/// 공통 에러 코드
enum AppErrorCode {
  // 네트워크 관련
  networkConnectionFailed('NETWORK_CONNECTION_FAILED'),
  networkTimeout('NETWORK_TIMEOUT'),
  networkUnavailable('NETWORK_UNAVAILABLE'),

  // 인증 관련
  authenticationFailed('AUTHENTICATION_FAILED'),
  authenticationExpired('AUTHENTICATION_EXPIRED'),
  authenticationRequired('AUTHENTICATION_REQUIRED'),

  // 권한 관련
  authorizationDenied('AUTHORIZATION_DENIED'),
  insufficientPermissions('INSUFFICIENT_PERMISSIONS'),

  // 데이터 검증 관련
  validationFailed('VALIDATION_FAILED'),
  requiredFieldMissing('REQUIRED_FIELD_MISSING'),
  invalidFormat('INVALID_FORMAT'),

  // 저장소 관련
  storageReadFailed('STORAGE_READ_FAILED'),
  storageWriteFailed('STORAGE_WRITE_FAILED'),
  storageDeleteFailed('STORAGE_DELETE_FAILED'),

  // 캐시 관련
  cacheMiss('CACHE_MISS'),
  cacheExpired('CACHE_EXPIRED'),
  cacheWriteFailed('CACHE_WRITE_FAILED'),

  // 설정 관련
  configurationMissing('CONFIGURATION_MISSING'),
  configurationInvalid('CONFIGURATION_INVALID'),

  // 데이터 파싱 관련
  parsingFailed('PARSING_FAILED'),
  dataFormatInvalid('DATA_FORMAT_INVALID'),

  // 비즈니스 로직 관련
  businessRuleViolation('BUSINESS_RULE_VIOLATION'),
  operationNotAllowed('OPERATION_NOT_ALLOWED'),

  // 외부 API 관련
  apiRequestFailed('API_REQUEST_FAILED'),
  apiResponseInvalid('API_RESPONSE_INVALID'),
  apiRateLimitExceeded('API_RATE_LIMIT_EXCEEDED'),

  // 예상치 못한 에러
  unexpectedError('UNEXPECTED_ERROR'),
  unknownError('UNKNOWN_ERROR');

  const AppErrorCode(this.code);

  final String code;

  @override
  String toString() => code;
}

/// AI Feature 전용 에러 코드
enum AiErrorCode {
  // OpenAI API 관련
  openaiApiKeyMissing('OPENAI_API_KEY_MISSING'),
  openaiApiKeyInvalid('OPENAI_API_KEY_INVALID'),
  openaiApiRateLimitExceeded('OPENAI_API_RATE_LIMIT_EXCEEDED'),
  openaiApiServerError('OPENAI_API_SERVER_ERROR'),

  // 콘텐츠 검증 관련
  contentNotPetRelated('CONTENT_NOT_PET_RELATED'),
  contentTooShort('CONTENT_TOO_SHORT'),
  contentFilterFailed('CONTENT_FILTER_FAILED'),

  // 채팅 관련
  chatHistoryLoadFailed('CHAT_HISTORY_LOAD_FAILED'),
  chatHistorySaveFailed('CHAT_HISTORY_SAVE_FAILED'),
  messageSendFailed('MESSAGE_SEND_FAILED'),

  // 즐겨찾기 관련
  favoriteAddFailed('FAVORITE_ADD_FAILED'),
  favoriteRemoveFailed('FAVORITE_REMOVE_FAILED'),
  favoriteLoadFailed('FAVORITE_LOAD_FAILED');

  const AiErrorCode(this.code);

  final String code;

  @override
  String toString() => code;
}

/// Auth Feature 전용 에러 코드
enum AuthErrorCode {
  // Firebase Auth 관련
  firebaseAuthFailed('FIREBASE_AUTH_FAILED'),
  firebaseUserNotFound('FIREBASE_USER_NOT_FOUND'),
  firebaseEmailAlreadyExists('FIREBASE_EMAIL_ALREADY_EXISTS'),
  firebaseInvalidCredentials('FIREBASE_INVALID_CREDENTIALS'),

  // 소셜 로그인 관련
  googleSignInFailed('GOOGLE_SIGN_IN_FAILED'),
  appleSignInFailed('APPLE_SIGN_IN_FAILED'),
  lineSignInFailed('LINE_SIGN_IN_FAILED'),

  // 토큰 관련
  tokenExchangeFailed('TOKEN_EXCHANGE_FAILED'),
  tokenExpired('TOKEN_EXPIRED'),
  tokenInvalid('TOKEN_INVALID'),
  tokenStorageFailed('TOKEN_STORAGE_FAILED'),

  // 사용자 관련
  userCreationFailed('USER_CREATION_FAILED'),
  userUpdateFailed('USER_UPDATE_FAILED'),
  userDeletionFailed('USER_DELETION_FAILED');

  const AuthErrorCode(this.code);

  final String code;

  @override
  String toString() => code;
}

/// Facility Feature 전용 에러 코드
enum FacilityErrorCode {
  // 시설 조회 관련
  facilityLoadFailed('FACILITY_LOAD_FAILED'),
  facilityNotFound('FACILITY_NOT_FOUND'),
  facilitySearchFailed('FACILITY_SEARCH_FAILED'),

  // 위치 관련
  locationPermissionDenied('LOCATION_PERMISSION_DENIED'),
  locationServiceDisabled('LOCATION_SERVICE_DISABLED'),
  locationUpdateFailed('LOCATION_UPDATE_FAILED'),

  // 예약 관련
  reservationCreationFailed('RESERVATION_CREATION_FAILED'),
  reservationUpdateFailed('RESERVATION_UPDATE_FAILED'),
  reservationCancellationFailed('RESERVATION_CANCELLATION_FAILED'),
  reservationNotFound('RESERVATION_NOT_FOUND'),

  // 즐겨찾기 관련
  favoriteToggleFailed('FAVORITE_TOGGLE_FAILED'),
  favoriteListLoadFailed('FAVORITE_LIST_LOAD_FAILED');

  const FacilityErrorCode(this.code);

  final String code;

  @override
  String toString() => code;
}

/// 에러 코드 확장 메서드
extension AppErrorCodeExtension on AppErrorCode {
  /// 에러 코드에 대한 사용자 친화적인 메시지 반환
  String get userFriendlyMessage {
    switch (this) {
      case AppErrorCode.networkConnectionFailed:
        return 'ネットワーク接続を確認してください。';
      case AppErrorCode.networkTimeout:
        return '接続がタイムアウトしました。しばらくしてから再試行してください。';
      case AppErrorCode.networkUnavailable:
        return 'ネットワーク接続に問題があります。インターネット接続を確認してください。';
      case AppErrorCode.authenticationFailed:
        return '認証に失敗しました。ログイン情報を確認してください。';
      case AppErrorCode.authenticationExpired:
        return '認証が期限切れです。再度ログインしてください。';
      case AppErrorCode.authenticationRequired:
        return 'ログインが必要です。';
      case AppErrorCode.authorizationDenied:
        return 'アクセス権限がありません。';
      case AppErrorCode.insufficientPermissions:
        return '権限が不足しています。';
      case AppErrorCode.validationFailed:
        return '入力内容を確認してください。';
      case AppErrorCode.requiredFieldMissing:
        return '必須項目を入力してください。';
      case AppErrorCode.invalidFormat:
        return '入力形式が正しくありません。';
      case AppErrorCode.storageReadFailed:
        return 'データの読み込みに失敗しました。';
      case AppErrorCode.storageWriteFailed:
        return 'データの保存に失敗しました。';
      case AppErrorCode.storageDeleteFailed:
        return 'データの削除に失敗しました。';
      case AppErrorCode.cacheMiss:
        return 'キャッシュが見つかりません。';
      case AppErrorCode.cacheExpired:
        return 'キャッシュが期限切れです。';
      case AppErrorCode.cacheWriteFailed:
        return 'キャッシュの保存に失敗しました。';
      case AppErrorCode.configurationMissing:
        return '設定が見つかりません。管理者にお問い合わせください。';
      case AppErrorCode.configurationInvalid:
        return '設定に問題があります。管理者にお問い合わせください。';
      case AppErrorCode.parsingFailed:
        return 'データの処理中にエラーが発生しました。';
      case AppErrorCode.dataFormatInvalid:
        return 'データ形式が正しくありません。';
      case AppErrorCode.businessRuleViolation:
        return '処理中にエラーが発生しました。';
      case AppErrorCode.operationNotAllowed:
        return 'この操作は許可されていません。';
      case AppErrorCode.apiRequestFailed:
        return 'APIリクエストに失敗しました。しばらくしてから再試行してください。';
      case AppErrorCode.apiResponseInvalid:
        return 'API応答が無効です。';
      case AppErrorCode.apiRateLimitExceeded:
        return 'APIリクエスト制限を超えました。しばらくしてから再試行してください。';
      case AppErrorCode.unexpectedError:
        return '予期しないエラーが発生しました。しばらくしてから再試行してください。';
      case AppErrorCode.unknownError:
        return '不明なエラーが発生しました。';
    }
  }
}

/// AI 에러 코드 확장 메서드
extension AiErrorCodeExtension on AiErrorCode {
  /// AI 에러 코드에 대한 사용자 친화적인 메시지 반환
  String get userFriendlyMessage {
    switch (this) {
      case AiErrorCode.openaiApiKeyMissing:
        return 'OpenAI APIキーが設定されていません。';
      case AiErrorCode.openaiApiKeyInvalid:
        return 'OpenAI APIキーが無効です。';
      case AiErrorCode.openaiApiRateLimitExceeded:
        return 'OpenAI APIリクエスト制限を超えました。しばらくしてから再試行してください。';
      case AiErrorCode.openaiApiServerError:
        return 'OpenAIサーバーに一時的な問題が発生しています。しばらくしてから再試行してください。';
      case AiErrorCode.contentNotPetRelated:
        return 'ペットに関連する内容を入力してください。';
      case AiErrorCode.contentTooShort:
        return '内容が短すぎます。ペット関連の具体的な質問を入力してください。';
      case AiErrorCode.contentFilterFailed:
        return 'コンテンツフィルタリングに失敗しました。';
      case AiErrorCode.chatHistoryLoadFailed:
        return 'チャット履歴の読み込みに失敗しました。';
      case AiErrorCode.chatHistorySaveFailed:
        return 'チャット履歴の保存に失敗しました。';
      case AiErrorCode.messageSendFailed:
        return 'メッセージの送信に失敗しました。';
      case AiErrorCode.favoriteAddFailed:
        return 'お気に入りの追加に失敗しました。';
      case AiErrorCode.favoriteRemoveFailed:
        return 'お気に入りの削除に失敗しました。';
      case AiErrorCode.favoriteLoadFailed:
        return 'お気に入りの読み込みに失敗しました。';
    }
  }
}

/// Auth 에러 코드 확장 메서드
extension AuthErrorCodeExtension on AuthErrorCode {
  /// Auth 에러 코드에 대한 사용자 친화적인 메시지 반환
  String get userFriendlyMessage {
    switch (this) {
      case AuthErrorCode.firebaseAuthFailed:
        return 'Firebase認証に失敗しました。';
      case AuthErrorCode.firebaseUserNotFound:
        return 'ユーザーが見つかりません。';
      case AuthErrorCode.firebaseEmailAlreadyExists:
        return 'このメールアドレスは既に使用されています。';
      case AuthErrorCode.firebaseInvalidCredentials:
        return 'メールアドレスまたはパスワードが正しくありません。';
      case AuthErrorCode.googleSignInFailed:
        return 'Googleログインに失敗しました。';
      case AuthErrorCode.appleSignInFailed:
        return 'Appleログインに失敗しました。';
      case AuthErrorCode.lineSignInFailed:
        return 'LINEログインに失敗しました。';
      case AuthErrorCode.tokenExchangeFailed:
        return 'トークンの交換に失敗しました。';
      case AuthErrorCode.tokenExpired:
        return 'トークンが期限切れです。再度ログインしてください。';
      case AuthErrorCode.tokenInvalid:
        return 'トークンが無効です。';
      case AuthErrorCode.tokenStorageFailed:
        return 'トークンの保存に失敗しました。';
      case AuthErrorCode.userCreationFailed:
        return 'ユーザーの作成に失敗しました。';
      case AuthErrorCode.userUpdateFailed:
        return 'ユーザー情報の更新に失敗しました。';
      case AuthErrorCode.userDeletionFailed:
        return 'ユーザーの削除に失敗しました。';
    }
  }
}

/// Facility 에러 코드 확장 메서드
extension FacilityErrorCodeExtension on FacilityErrorCode {
  /// Facility 에러 코드에 대한 사용자 친화적인 메시지 반환
  String get userFriendlyMessage {
    switch (this) {
      case FacilityErrorCode.facilityLoadFailed:
        return '施設情報の読み込みに失敗しました。';
      case FacilityErrorCode.facilityNotFound:
        return '施設が見つかりません。';
      case FacilityErrorCode.facilitySearchFailed:
        return '施設の検索に失敗しました。';
      case FacilityErrorCode.locationPermissionDenied:
        return '位置情報のアクセス許可が必要です。';
      case FacilityErrorCode.locationServiceDisabled:
        return '位置情報サービスが無効です。';
      case FacilityErrorCode.locationUpdateFailed:
        return '位置情報の更新に失敗しました。';
      case FacilityErrorCode.reservationCreationFailed:
        return '予約の作成に失敗しました。';
      case FacilityErrorCode.reservationUpdateFailed:
        return '予約の更新に失敗しました。';
      case FacilityErrorCode.reservationCancellationFailed:
        return '予約のキャンセルに失敗しました。';
      case FacilityErrorCode.reservationNotFound:
        return '予約が見つかりません。';
      case FacilityErrorCode.favoriteToggleFailed:
        return 'お気に入りの切り替えに失敗しました。';
      case FacilityErrorCode.favoriteListLoadFailed:
        return 'お気に入りリストの読み込みに失敗しました。';
    }
  }
}
