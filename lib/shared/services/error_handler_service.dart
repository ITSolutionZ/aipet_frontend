import 'package:flutter/foundation.dart';

import 'common_error_service.dart';

/// 전역 에러 처리 및 모니터링 서비스
///
/// 앱 초기화 시 전역 에러 핸들러를 설정하고
/// 에러 모니터링 및 로깅을 담당합니다.
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  final CommonErrorService _commonErrorService = CommonErrorService();
  bool _isInitialized = false;

  /// 서비스를 초기화합니다.
  ///
  /// 전역 에러 핸들러를 설정하고 에러 모니터링을 시작합니다.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // CommonErrorService 초기화
      await _commonErrorService.initialize();

      // 전역 에러 핸들러 설정
      _setupGlobalErrorHandlers();

      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('✅ ErrorHandlerService 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ErrorHandlerService 초기화 실패: $e');
      }
      rethrow;
    }
  }

  /// 전역 에러 핸들러를 설정합니다.
  void _setupGlobalErrorHandlers() {
    // Flutter 에러 핸들러 설정
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Zone 에러 핸들러 설정
    // runZonedGuarded에서 이미 설정되므로 여기서는 추가 설정 불필요
  }

  /// Flutter 에러를 처리합니다.
  void _handleFlutterError(FlutterErrorDetails details) {
    _commonErrorService.handleErrorInstance(
      details.exception,
      message: details.exceptionAsString(),
      severity: ErrorSeverity.high,
      type: ErrorType.unknown,
      stackTrace: details.stack,
      context: {
        'library': details.library,
        'context': details.context?.toString(),
        'informationCollector': details.informationCollector?.toString(),
      },
    );
  }

  /// 에러를 수동으로 처리합니다.
  ///
  /// [error] 처리할 에러 객체
  /// [message] 에러 메시지 (선택사항)
  /// [severity] 에러 심각도 (기본값: medium)
  /// [type] 에러 타입 (기본값: unknown)
  /// [context] 추가 컨텍스트 정보 (선택사항)
  /// [stackTrace] 스택 트레이스 (선택사항)
  Future<void> handleError(
    Object error, {
    String? message,
    ErrorSeverity severity = ErrorSeverity.medium,
    ErrorType type = ErrorType.unknown,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) async {
    await _commonErrorService.handleErrorInstance(
      error,
      message: message,
      severity: severity,
      type: type,
      context: context,
      stackTrace: stackTrace,
    );
  }

  /// 에러 스트림을 구독합니다.
  ///
  /// [onError] 에러 발생 시 호출될 콜백
  void listenToErrors(void Function(ErrorInfo) onError) {
    _commonErrorService.errorStream.listen(onError);
  }

  /// 에러 히스토리를 가져옵니다.
  List<ErrorInfo> getErrorHistory() {
    return _commonErrorService.getErrorHistory();
  }

  /// 에러 통계를 가져옵니다.
  Map<String, int> getErrorStatistics() {
    // CommonErrorService에서 에러 카운터 정보를 가져옵니다
    return {'total_errors': _commonErrorService.getErrorHistory().length};
  }

  /// 에러 히스토리를 정리합니다.
  void clearErrorHistory() {
    _commonErrorService.clearErrorHistory();
  }

  /// 서비스가 초기화되었는지 확인합니다.
  bool get isInitialized => _isInitialized;

  /// 서비스를 정리합니다.
  void dispose() {
    _commonErrorService.dispose();
    _isInitialized = false;
  }
}
