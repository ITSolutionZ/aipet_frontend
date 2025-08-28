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
  static const String httpInternalServerError = 'HTTP_500_INTERNAL_SERVER_ERROR';
  static const String httpBadGateway = 'HTTP_502_BAD_GATEWAY';
  static const String httpServiceUnavailable = 'HTTP_503_SERVICE_UNAVAILABLE';
  static const String httpGatewayTimeout = 'HTTP_504_GATEWAY_TIMEOUT';

  // === Firebase Auth 관련 에러 ===
  static const String firebaseUserNotFound = 'FIREBASE_USER_NOT_FOUND';
  static const String firebaseWrongPassword = 'FIREBASE_WRONG_PASSWORD';
  static const String firebaseEmailAlreadyInUse = 'FIREBASE_EMAIL_ALREADY_IN_USE';
  static const String firebaseWeakPassword = 'FIREBASE_WEAK_PASSWORD';
  static const String firebaseInvalidEmail = 'FIREBASE_INVALID_EMAIL';
  static const String firebaseUserDisabled = 'FIREBASE_USER_DISABLED';
  static const String firebaseTooManyRequests = 'FIREBASE_TOO_MANY_REQUESTS';
  static const String firebaseOperationNotAllowed = 'FIREBASE_OPERATION_NOT_ALLOWED';
  static const String firebaseNetworkRequestFailed = 'FIREBASE_NETWORK_REQUEST_FAILED';
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
  static const String validationPasswordTooShort = 'VALIDATION_PASSWORD_TOO_SHORT';
  static const String validationPasswordTooWeak = 'VALIDATION_PASSWORD_TOO_WEAK';
  static const String validationFieldRequired = 'VALIDATION_FIELD_REQUIRED';
  static const String validationFieldTooLong = 'VALIDATION_FIELD_TOO_LONG';
  static const String validationFieldInvalidFormat = 'VALIDATION_FIELD_INVALID_FORMAT';

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
  static const String permissionCameraNotGranted = 'PERMISSION_CAMERA_NOT_GRANTED';
  static const String permissionLocationNotGranted = 'PERMISSION_LOCATION_NOT_GRANTED';
  static const String permissionStorageNotGranted = 'PERMISSION_STORAGE_NOT_GRANTED';
  static const String permissionNotificationNotGranted = 'PERMISSION_NOTIFICATION_NOT_GRANTED';

  /// 에러 코드에 대응하는 사용자 친화적인 메시지를 반환
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      // === 네트워크 관련 에러 ===
      case networkConnectionTimeout:
        return '연결 시간이 초과되었습니다. 네트워크 상태를 확인해주세요.';
      case networkReceiveTimeout:
        return '응답 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.';
      case networkSendTimeout:
        return '요청 전송 시간이 초과되었습니다.';
      case networkConnectionError:
        return '네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.';
      case networkUnknownError:
        return '알 수 없는 네트워크 오류가 발생했습니다.';

      // === HTTP 상태 코드 관련 에러 ===
      case httpBadRequest:
        return '잘못된 요청입니다.';
      case httpUnauthorized:
        return '인증이 필요합니다. 다시 로그인해주세요.';
      case httpForbidden:
        return '접근 권한이 없습니다.';
      case httpNotFound:
        return '요청한 데이터를 찾을 수 없습니다.';
      case httpConflict:
        return '요청이 충돌했습니다.';
      case httpUnprocessableEntity:
        return '처리할 수 없는 요청입니다.';
      case httpTooManyRequests:
        return '너무 많은 요청을 보냈습니다. 잠시 후 다시 시도해주세요.';
      case httpInternalServerError:
        return '서버 내부 오류가 발생했습니다.';
      case httpBadGateway:
        return '서버 연결에 문제가 있습니다.';
      case httpServiceUnavailable:
        return '서비스를 일시적으로 사용할 수 없습니다.';
      case httpGatewayTimeout:
        return '서버 응답 시간이 초과되었습니다.';

      // === Firebase Auth 관련 에러 ===
      case firebaseUserNotFound:
        return '등록되지 않은 이메일입니다.';
      case firebaseWrongPassword:
        return '비밀번호가 올바르지 않습니다.';
      case firebaseEmailAlreadyInUse:
        return '이미 사용 중인 이메일 주소입니다.';
      case firebaseWeakPassword:
        return '비밀번호가 너무 간단합니다. 더 복잡한 비밀번호를 사용해주세요.';
      case firebaseInvalidEmail:
        return '올바르지 않은 이메일 형식입니다.';
      case firebaseUserDisabled:
        return '비활성화된 계정입니다. 관리자에게 문의해주세요.';
      case firebaseTooManyRequests:
        return '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
      case firebaseOperationNotAllowed:
        return '허용되지 않은 작업입니다.';
      case firebaseNetworkRequestFailed:
        return '네트워크 연결을 확인해주세요.';
      case firebaseUnknownError:
        return '알 수 없는 인증 오류가 발생했습니다.';

      // === 인증 관련 에러 ===
      case authTokenExpired:
        return '로그인이 만료되었습니다. 다시 로그인해주세요.';
      case authTokenInvalid:
        return '인증 정보가 올바르지 않습니다.';
      case authTokenMissing:
        return '인증이 필요합니다.';
      case authTokenRefreshFailed:
        return '인증 정보 갱신에 실패했습니다. 다시 로그인해주세요.';
      case authLoginRequired:
        return '로그인이 필요한 서비스입니다.';
      case authPermissionDenied:
        return '접근 권한이 없습니다.';
      case authAccountLocked:
        return '계정이 잠겨있습니다. 관리자에게 문의해주세요.';
      case authEmailNotVerified:
        return '이메일 인증이 필요합니다.';

      // === 유효성 검사 관련 에러 ===
      case validationEmailInvalid:
        return '올바른 이메일 주소를 입력해주세요.';
      case validationPasswordTooShort:
        return '비밀번호는 최소 6자 이상이어야 합니다.';
      case validationPasswordTooWeak:
        return '더 강한 비밀번호를 사용해주세요.';
      case validationFieldRequired:
        return '필수 입력 항목입니다.';
      case validationFieldTooLong:
        return '입력된 내용이 너무 깁니다.';
      case validationFieldInvalidFormat:
        return '올바르지 않은 형식입니다.';

      // === 저장소 관련 에러 ===
      case storageWriteFailed:
        return '데이터 저장에 실패했습니다.';
      case storageReadFailed:
        return '데이터 읽기에 실패했습니다.';
      case storageDeleteFailed:
        return '데이터 삭제에 실패했습니다.';
      case storageNotFound:
        return '저장된 데이터를 찾을 수 없습니다.';
      case storagePermissionDenied:
        return '저장소 접근 권한이 없습니다.';

      // === 일반적인 앱 에러 ===
      case appInitializationFailed:
        return '앱 초기화에 실패했습니다.';
      case appFeatureNotSupported:
        return '지원되지 않는 기능입니다.';
      case appVersionTooOld:
        return '앱 업데이트가 필요합니다.';
      case appMaintenanceMode:
        return '현재 서비스 점검 중입니다.';

      // === 데이터 관련 에러 ===
      case dataParsingFailed:
        return '데이터 처리 중 오류가 발생했습니다.';
      case dataCorrupted:
        return '손상된 데이터입니다.';
      case dataNotFound:
        return '데이터를 찾을 수 없습니다.';
      case dataSyncFailed:
        return '데이터 동기화에 실패했습니다.';

      // === 권한 관련 에러 ===
      case permissionCameraNotGranted:
        return '카메라 권한이 필요합니다.';
      case permissionLocationNotGranted:
        return '위치 권한이 필요합니다.';
      case permissionStorageNotGranted:
        return '저장소 권한이 필요합니다.';
      case permissionNotificationNotGranted:
        return '알림 권한이 필요합니다.';

      default:
        return '알 수 없는 오류가 발생했습니다.';
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