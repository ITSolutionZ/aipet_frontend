/// 앱 전체에서 사용하는 표준화된 에러 코드와 메시지
class ErrorCodes {
  // === 네트워크 관련 에러 ===
  static const String networkConnectionTimeout = 'NETWORK_CONNECTION_TIMEOUT';
  static const String networkReceiveTimeout = 'NETWORK_RECEIVE_TIMEOUT';
  static const String networkSendTimeout = 'NETWORK_SEND_TIMEOUT';
  static const String networkConnectionError = 'NETWORK_CONNECTION_ERROR';
  static const String networkUnknownError = 'NETWORK_UNKNOWN_ERROR';

  // === HTTP 상태 코드 관련 에러 ===
  static const String httpBadRequest = 'HTTP_400_BAD_REQUEST';
  static const String httpUnauthorized = 'HTTP_401_UNAUTHORIZED';
  static const String httpForbidden = 'HTTP_403_FORBIDDEN';
  static const String httpNotFound = 'HTTP_404_NOT_FOUND';
  static const String httpConflict = 'HTTP_409_CONFLICT';
  static const String httpUnprocessableEntity = 'HTTP_422_UNPROCESSABLE_ENTITY';
  static const String httpTooManyRequests = 'HTTP_429_TOO_MANY_REQUESTS';
  static const String httpInternalServerError =
      'HTTP_500_INTERNAL_SERVER_ERROR';
  static const String httpBadGateway = 'HTTP_502_BAD_GATEWAY';
  static const String httpServiceUnavailable = 'HTTP_503_SERVICE_UNAVAILABLE';
  static const String httpGatewayTimeout = 'HTTP_504_GATEWAY_TIMEOUT';

  // === Firebase Auth 관련 에러 ===
  static const String firebaseUserNotFound = 'FIREBASE_USER_NOT_FOUND';
  static const String firebaseWrongPassword = 'FIREBASE_WRONG_PASSWORD';
  static const String firebaseEmailAlreadyInUse =
      'FIREBASE_EMAIL_ALREADY_IN_USE';
  static const String firebaseWeakPassword = 'FIREBASE_WEAK_PASSWORD';
  static const String firebaseInvalidEmail = 'FIREBASE_INVALID_EMAIL';
  static const String firebaseUserDisabled = 'FIREBASE_USER_DISABLED';
  static const String firebaseTooManyRequests = 'FIREBASE_TOO_MANY_REQUESTS';
  static const String firebaseOperationNotAllowed =
      'FIREBASE_OPERATION_NOT_ALLOWED';
  static const String firebaseNetworkRequestFailed =
      'FIREBASE_NETWORK_REQUEST_FAILED';
  static const String firebaseUnknownError = 'FIREBASE_UNKNOWN_ERROR';

  // === 인증 관련 에러 ===
  static const String authTokenExpired = 'AUTH_TOKEN_EXPIRED';
  static const String authTokenInvalid = 'AUTH_TOKEN_INVALID';
  static const String authTokenMissing = 'AUTH_TOKEN_MISSING';
  static const String authTokenRefreshFailed = 'AUTH_TOKEN_REFRESH_FAILED';
  static const String authLoginRequired = 'AUTH_LOGIN_REQUIRED';
  static const String authPermissionDenied = 'AUTH_PERMISSION_DENIED';
  static const String authAccountLocked = 'AUTH_ACCOUNT_LOCKED';
  static const String authEmailNotVerified = 'AUTH_EMAIL_NOT_VERIFIED';

  // === 유효성 검사 관련 에러 ===
  static const String validationEmailInvalid = 'VALIDATION_EMAIL_INVALID';
  static const String validationPasswordTooShort =
      'VALIDATION_PASSWORD_TOO_SHORT';
  static const String validationPasswordTooWeak =
      'VALIDATION_PASSWORD_TOO_WEAK';
  static const String validationFieldRequired = 'VALIDATION_FIELD_REQUIRED';
  static const String validationFieldTooLong = 'VALIDATION_FIELD_TOO_LONG';
  static const String validationFieldInvalidFormat =
      'VALIDATION_FIELD_INVALID_FORMAT';

  // === 저장소 관련 에러 ===
  static const String storageWriteFailed = 'STORAGE_WRITE_FAILED';
  static const String storageReadFailed = 'STORAGE_READ_FAILED';
  static const String storageDeleteFailed = 'STORAGE_DELETE_FAILED';
  static const String storageNotFound = 'STORAGE_NOT_FOUND';
  static const String storagePermissionDenied = 'STORAGE_PERMISSION_DENIED';

  // === 일반적인 앱 에러 ===
  static const String appInitializationFailed = 'APP_INITIALIZATION_FAILED';
  static const String appFeatureNotSupported = 'APP_FEATURE_NOT_SUPPORTED';
  static const String appVersionTooOld = 'APP_VERSION_TOO_OLD';
  static const String appMaintenanceMode = 'APP_MAINTENANCE_MODE';

  // === 데이터 관련 에러 ===
  static const String dataParsingFailed = 'DATA_PARSING_FAILED';
  static const String dataCorrupted = 'DATA_CORRUPTED';
  static const String dataNotFound = 'DATA_NOT_FOUND';
  static const String dataSyncFailed = 'DATA_SYNC_FAILED';

  // === 권한 관련 에러 ===
  static const String permissionCameraNotGranted =
      'PERMISSION_CAMERA_NOT_GRANTED';
  static const String permissionLocationNotGranted =
      'PERMISSION_LOCATION_NOT_GRANTED';
  static const String permissionStorageNotGranted =
      'PERMISSION_STORAGE_NOT_GRANTED';
  static const String permissionNotificationNotGranted =
      'PERMISSION_NOTIFICATION_NOT_GRANTED';

  /// 에러 코드에 대응하는 사용자 친화적인 메시지를 반환
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      // === 네트워크 관련 에러 ===
      case networkConnectionTimeout:
        return 'リクエストの時間が超過しました。ネットワークの状態を確認してください。';
      case networkReceiveTimeout:
        return '応答時間が超過しました。しばらくしてから再度お試しください。';
      case networkSendTimeout:
        return 'リクエスト送信時間が超過しました。';
      case networkConnectionError:
        return 'ネットワーク接続に失敗しました。インターネット接続を確認してください。';
      case networkUnknownError:
        return '不明なネットワークエラーが発生しました。';

      // === HTTP 상태 코드 관련 에러 ===
      case httpBadRequest:
        return '不正なリクエストです。';
      case httpUnauthorized:
        return '認証が必要です。再度ログインしてください。';
      case httpForbidden:
        return 'アクセス権限がありません。';
      case httpNotFound:
        return '要求されたデータが見つかりません。';
      case httpConflict:
        return 'リクエストが競合しました。';
      case httpUnprocessableEntity:
        return '処理できないリクエストです。';
      case httpTooManyRequests:
        return '多くのリクエストを送信しました。しばらくしてから再度お試しください。';
      case httpInternalServerError:
        return 'サーバー内部エラーが発生しました。';
      case httpBadGateway:
        return 'サーバー接続に問題があります。';
      case httpServiceUnavailable:
        return 'サービスは一時的に使用できません。';
      case httpGatewayTimeout:
        return 'サーバー応答時間が超過しました。';

      // === Firebase Auth 관련 에러 ===
      case firebaseUserNotFound:
        return '登録されていないメールです。';
      case firebaseWrongPassword:
        return 'パスワードが正しくありません。';
      case firebaseEmailAlreadyInUse:
        return 'すでに使用中のメールアドレスです。';
      case firebaseWeakPassword:
        return 'パスワードが簡単すぎます。より複雑なパスワードを使用してください。';
      case firebaseInvalidEmail:
        return '無効なメールアドレス形式です。';
      case firebaseUserDisabled:
        return '無効なアカウントです。管理者にお問い合わせください。';
      case firebaseTooManyRequests:
        return '多くの試行がありました。しばらくしてから再度お試しください。';
      case firebaseOperationNotAllowed:
        return '許可されていない操作です。';
      case firebaseNetworkRequestFailed:
        return 'ネットワーク接続を確認してください。';
      case firebaseUnknownError:
        return '不明な認証エラーが発生しました。';

      // === 인증 관련 에러 ===
      case authTokenExpired:
        return 'ログインが期限切れです。再度ログインしてください。';
      case authTokenInvalid:
        return '認証情報が正しくありません。';
      case authTokenMissing:
        return '認証が必要です。';
      case authTokenRefreshFailed:
        return '認証情報の更新に失敗しました。再度ログインしてください。';
      case authLoginRequired:
        return 'ログインが必要なサービスです。';
      case authPermissionDenied:
        return 'アクセス権限がありません。';
      case authAccountLocked:
        return 'アカウントがロックされています。管理者にお問い合わせください。';
      case authEmailNotVerified:
        return 'メール認証が必要です。';

      // === 유효성 검사 관련 에러 ===
      case validationEmailInvalid:
        return '正しいメールアドレスを入力してください。';
      case validationPasswordTooShort:
        return 'パスワードは最低6文字以上でなければなりません。';
      case validationPasswordTooWeak:
        return 'より強力なパスワードを使用してください。';
      case validationFieldRequired:
        return '必須入力項目です。';
      case validationFieldTooLong:
        return '入力された内容が長すぎます。';
      case validationFieldInvalidFormat:
        return '無効な形式です。';

      // === 저장소 관련 에러 ===
      case storageWriteFailed:
        return 'データの保存に失敗しました。';
      case storageReadFailed:
        return 'データの読み取りに失敗しました。';
      case storageDeleteFailed:
        return 'データの削除に失敗しました。';
      case storageNotFound:
        return '保存されたデータが見つかりません。';
      case storagePermissionDenied:
        return 'ストレージへのアクセス権限がありません。';

      // === 일반적인 앱 에러 ===
      case appInitializationFailed:
        return 'アプリの初期化に失敗しました。';
      case appFeatureNotSupported:
        return 'サポートされていない機能です。';
      case appVersionTooOld:
        return 'アプリの更新が必要です。';
      case appMaintenanceMode:
        return '現在、サービスのメンテナンス中です。';

      // === 데이터 관련 에러 ===
      case dataParsingFailed:
        return 'データ処理中にエラーが発生しました。';
      case dataCorrupted:
        return '破損したデータです。';
      case dataNotFound:
        return 'データが見つかりません。';
      case dataSyncFailed:
        return 'データ同期に失敗しました。';

      // === 권한 관련 에러 ===
      case permissionCameraNotGranted:
        return 'カメラの権限が必要です。';
      case permissionLocationNotGranted:
        return '位置情報の権限が必要です。';
      case permissionStorageNotGranted:
        return 'ストレージの権限が必要です。';
      case permissionNotificationNotGranted:
        return '通知の権限が必要です。';

      default:
        return '不明なエラーが発生しました。';
    }
  }

  /// Firebase Auth 에러 코드를 앱 에러 코드로 변환
  static String mapFirebaseAuthError(String firebaseErrorCode) {
    switch (firebaseErrorCode) {
      case 'user-not-found':
        return firebaseUserNotFound;
      case 'wrong-password':
        return firebaseWrongPassword;
      case 'email-already-in-use':
        return firebaseEmailAlreadyInUse;
      case 'weak-password':
        return firebaseWeakPassword;
      case 'invalid-email':
        return firebaseInvalidEmail;
      case 'user-disabled':
        return firebaseUserDisabled;
      case 'too-many-requests':
        return firebaseTooManyRequests;
      case 'operation-not-allowed':
        return firebaseOperationNotAllowed;
      case 'network-request-failed':
        return firebaseNetworkRequestFailed;
      default:
        return firebaseUnknownError;
    }
  }

  /// HTTP 상태 코드를 앱 에러 코드로 변환
  static String mapHttpStatusError(int statusCode) {
    switch (statusCode) {
      case 400:
        return httpBadRequest;
      case 401:
        return httpUnauthorized;
      case 403:
        return httpForbidden;
      case 404:
        return httpNotFound;
      case 409:
        return httpConflict;
      case 422:
        return httpUnprocessableEntity;
      case 429:
        return httpTooManyRequests;
      case 500:
        return httpInternalServerError;
      case 502:
        return httpBadGateway;
      case 503:
        return httpServiceUnavailable;
      case 504:
        return httpGatewayTimeout;
      default:
        return 'HTTP_${statusCode}_ERROR';
    }
  }
}
