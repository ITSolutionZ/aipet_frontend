import 'common_error_service.dart';

/// 애플리케이션 레벨 에러 관리 서비스
///
/// BaseController에서 사용하는 간단한 에러 처리 서비스입니다.
/// CommonErrorService를 래핑하여 더 간단한 인터페이스를 제공합니다.
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  final CommonErrorService _commonErrorService = CommonErrorService();

  /// 에러를 처리합니다.
  ///
  /// [error] 처리할 에러 객체
  /// [stackTrace] 스택 트레이스 (선택사항)
  void handleError(Object error, [StackTrace? stackTrace]) {
    _commonErrorService.handleErrorInstance(
      error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.medium,
      type: ErrorType.unknown,
    );
  }

  /// 심각도별 에러를 처리합니다.
  ///
  /// [error] 처리할 에러 객체
  /// [severity] 에러 심각도
  /// [stackTrace] 스택 트레이스 (선택사항)
  void handleErrorWithSeverity(
    Object error,
    dynamic severity, [
    StackTrace? stackTrace,
  ]) {
    ErrorSeverity errorSeverity;

    // severity 타입에 따른 변환
    if (severity is ErrorSeverity) {
      errorSeverity = severity;
    } else if (severity is String) {
      errorSeverity = _parseSeverityFromString(severity);
    } else {
      errorSeverity = ErrorSeverity.medium;
    }

    _commonErrorService.handleErrorInstance(
      error,
      stackTrace: stackTrace,
      severity: errorSeverity,
      type: ErrorType.unknown,
    );
  }

  /// 사용자 친화적인 에러 메시지를 생성합니다.
  ///
  /// [error] 원본 에러 객체
  /// [return] 사용자 친화적인 에러 메시지
  String getUserFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    // 네트워크 관련 에러
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return 'ネットワーク接続を確認してください。';
    }

    // 서버 에러
    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return 'サーバーエラーが発生しました。しばらく経ってから再試行してください。';
    }

    // 인증 에러
    if (errorString.contains('auth') ||
        errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return '認証に失敗しました。ログインし直してください。';
    }

    // 권한 에러
    if (errorString.contains('permission') ||
        errorString.contains('forbidden') ||
        errorString.contains('403')) {
      return 'アクセス権限がありません。';
    }

    // 파일 에러
    if (errorString.contains('file') ||
        errorString.contains('upload') ||
        errorString.contains('download')) {
      return 'ファイルの処理中にエラーが発生しました。';
    }

    // 기본 에러 메시지
    return 'エラーが発生しました。しばらく経ってから再試行してください。';
  }

  /// 문자열에서 ErrorSeverity를 파싱합니다.
  ErrorSeverity _parseSeverityFromString(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return ErrorSeverity.low;
      case 'medium':
        return ErrorSeverity.medium;
      case 'high':
        return ErrorSeverity.high;
      case 'critical':
        return ErrorSeverity.critical;
      default:
        return ErrorSeverity.medium;
    }
  }

  /// 서비스를 초기화합니다.
  Future<void> initialize() async {
    await _commonErrorService.initialize();
  }

  /// 서비스를 정리합니다.
  void dispose() {
    _commonErrorService.dispose();
  }
}
