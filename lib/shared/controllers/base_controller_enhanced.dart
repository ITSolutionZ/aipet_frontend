import '../../app/controllers/base_controller.dart';
import '../constants/app_texts.dart';
import '../utils/result_utils.dart';

/// 향상된 BaseController - 공통 컨트롤러 패턴 개선
abstract class BaseControllerEnhanced extends BaseController {
  BaseControllerEnhanced(super.ref);

  /// 성공 결과 생성 헬퍼
  Result<T> success<T>(String message, T data) {
    return Result.success(message, data);
  }

  /// 실패 결과 생성 헬퍼
  Result<T> failure<T>(String message, [Exception? error]) {
    return Result.failure(message, error);
  }

  /// 비동기 작업을 Result로 래핑
  Future<Result<T>> wrapAsync<T>(
    Future<T> Function() asyncFunction, {
    String? successMessage,
    String? failureMessage,
  }) async {
    return ResultHelper.wrapAsync(
      asyncFunction,
      successMessage: successMessage,
      failureMessage: failureMessage,
    );
  }

  /// 동기 작업을 Result로 래핑
  Result<T> wrapSync<T>(
    T Function() syncFunction, {
    String? successMessage,
    String? failureMessage,
  }) {
    return ResultHelper.wrapSync(
      syncFunction,
      successMessage: successMessage,
      failureMessage: failureMessage,
    );
  }

  /// 조건부 성공/실패 Result 생성
  Result<T> conditional<T>(
    bool condition,
    T data, {
    String? successMessage,
    String? failureMessage,
  }) {
    return ResultHelper.conditional(
      condition,
      data,
      successMessage: successMessage,
      failureMessage: failureMessage,
    );
  }

  /// null 체크 후 Result 생성
  Result<T> fromNullable<T>(
    T? data, {
    String? successMessage,
    String? failureMessage,
  }) {
    return ResultHelper.fromNullable(
      data,
      successMessage: successMessage,
      failureMessage: failureMessage,
    );
  }

  /// 공통 성공 메시지들
  Result<T> successSaved<T>(T data) => success(AppTexts.saved, data);
  Result<T> successUpdated<T>(T data) => success(AppTexts.updated, data);
  Result<T> successDeleted<T>(T data) => success(AppTexts.deleted, data);
  Result<T> successAdded<T>(T data) => success(AppTexts.added, data);
  Result<T> successCompleted<T>(T data) => success(AppTexts.completed, data);

  /// 공통 실패 메시지들
  Result<T> failureSave<T>([Exception? error]) =>
      failure(AppTexts.error, error);
  Result<T> failureUpdate<T>([Exception? error]) =>
      failure(AppTexts.error, error);
  Result<T> failureDelete<T>([Exception? error]) =>
      failure(AppTexts.error, error);
  Result<T> failureAdd<T>([Exception? error]) => failure(AppTexts.error, error);
  Result<T> failureLoad<T>([Exception? error]) =>
      failure(AppTexts.error, error);

  /// 네트워크 관련 Result 생성
  Result<T> networkError<T>([Exception? error]) =>
      failure(AppTexts.networkError, error);
  Result<T> serverError<T>([Exception? error]) =>
      failure(AppTexts.serverError, error);
  Result<T> timeoutError<T>([Exception? error]) =>
      failure(AppTexts.timeoutError, error);
  Result<T> connectionError<T>([Exception? error]) =>
      failure(AppTexts.connectionError, error);

  /// 검증 관련 Result 생성
  Result<T> validationError<T>(String message) => failure(message);
  Result<T> requiredFieldError<T>(String fieldName) =>
      failure('$fieldName${AppTexts.requiredField}');
  Result<T> invalidFormatError<T>(String fieldName) =>
      failure('$fieldName${AppTexts.invalidFormat}');

  /// 권한 관련 Result 생성
  Result<T> permissionError<T>([Exception? error]) =>
      failure(AppTexts.permissionError, error);
  Result<T> unauthorizedError<T>([Exception? error]) =>
      failure(AppTexts.unauthorizedError, error);
  Result<T> forbiddenError<T>([Exception? error]) =>
      failure(AppTexts.forbiddenError, error);

  /// 파일 관련 Result 생성
  Result<T> fileUploadError<T>([Exception? error]) =>
      failure(AppTexts.fileUploadFailed, error);
  Result<T> fileDownloadError<T>([Exception? error]) =>
      failure(AppTexts.fileDownloadFailed, error);
  Result<T> fileNotFoundError<T>([Exception? error]) =>
      failure(AppTexts.fileNotFound, error);
  Result<T> fileTooLargeError<T>([Exception? error]) =>
      failure(AppTexts.fileTooLarge, error);
  Result<T> invalidFileTypeError<T>([Exception? error]) =>
      failure(AppTexts.invalidFileType, error);

  /// 펫 관련 Result 생성
  Result<T> petNotFoundError<T>([Exception? error]) =>
      failure(AppTexts.petNotFound, error);
  Result<T> petRegistrationError<T>([Exception? error]) =>
      failure(AppTexts.petRegistrationFailed, error);
  Result<T> petUpdateError<T>([Exception? error]) =>
      failure(AppTexts.petUpdateFailed, error);
  Result<T> petDeleteError<T>([Exception? error]) =>
      failure(AppTexts.petDeleteFailed, error);

  /// 알림 관련 Result 생성
  Result<T> notificationError<T>([Exception? error]) =>
      failure(AppTexts.error, error);
  Result<T> notificationPermissionError<T>([Exception? error]) =>
      failure(AppTexts.notificationPermissionRequired, error);

  /// 설정 관련 Result 생성
  Result<T> settingsError<T>([Exception? error]) =>
      failure(AppTexts.error, error);
  Result<T> cacheError<T>([Exception? error]) => failure(AppTexts.error, error);

  /// 공유 관련 Result 생성
  Result<T> shareError<T>([Exception? error]) => failure(AppTexts.error, error);
  Result<T> sharePermissionError<T>([Exception? error]) =>
      failure(AppTexts.error, error);

  /// 로딩 상태 관리
  void setLoading(bool isLoading) {
    // BaseController의 로딩 상태 관리 메서드 호출
    // 실제 구현은 BaseController에서 제공
  }

  /// 에러 상태 관리
  void setError(String error) {
    // BaseController의 에러 상태 관리 메서드 호출
    // 실제 구현은 BaseController에서 제공
  }

  /// 성공 상태 관리
  void setSuccess(String message) {
    // BaseController의 성공 상태 관리 메서드 호출
    // 실제 구현은 BaseController에서 제공
  }

  /// 상태 초기화
  void clearState() {
    // BaseController의 상태 초기화 메서드 호출
    // 실제 구현은 BaseController에서 제공
  }

  /// 사용자 친화적인 에러 메시지 생성
  String getUserFriendlyErrorMessage(dynamic error) {
    if (error is Exception) {
      final errorMessage = error.toString();

      // 네트워크 관련 에러
      if (errorMessage.contains('SocketException') ||
          errorMessage.contains('HandshakeException')) {
        return AppTexts.connectionError;
      }

      if (errorMessage.contains('TimeoutException')) {
        return AppTexts.timeoutError;
      }

      if (errorMessage.contains('FormatException')) {
        return AppTexts.invalidFormat;
      }

      // HTTP 관련 에러
      if (errorMessage.contains('404')) {
        return AppTexts.notFoundError;
      }

      if (errorMessage.contains('401')) {
        return AppTexts.unauthorizedError;
      }

      if (errorMessage.contains('403')) {
        return AppTexts.forbiddenError;
      }

      if (errorMessage.contains('500')) {
        return AppTexts.serverError;
      }

      // 기본 에러 메시지
      return AppTexts.error;
    }

    return AppTexts.unknownError;
  }

  /// 에러 처리 및 로깅
  void handleError(dynamic error, [StackTrace? stackTrace]) {
    // BaseController의 에러 처리 메서드 호출
    // 실제 구현은 BaseController에서 제공

    // 추가 로깅 (필요시)
    // TODO: 실제 로깅 프레임워크로 교체
    print('Controller Error: $error');
    if (stackTrace != null) {
      print('Stack Trace: $stackTrace');
    }
  }

  /// 성공 메시지 표시
  void showSuccess(String message) {
    // BaseController의 성공 메시지 표시 메서드 호출
    // 실제 구현은 BaseController에서 제공
  }

  /// 에러 메시지 표시
  void showError(String message) {
    // BaseController의 에러 메시지 표시 메서드 호출
    // 실제 구현은 BaseController에서 제공
  }

  /// 정보 메시지 표시
  void showInfo(String message) {
    // BaseController의 정보 메시지 표시 메서드 호출
    // 실제 구현은 BaseController에서 제공
  }

  /// 경고 메시지 표시
  void showWarning(String message) {
    // BaseController의 경고 메시지 표시 메서드 호출
    // 실제 구현은 BaseController에서 제공
  }
}
