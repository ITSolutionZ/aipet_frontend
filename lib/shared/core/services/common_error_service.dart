import 'dart:async';
import 'dart:developer' as developer;

import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/utils/string_utils.dart';
import 'package:flutter/foundation.dart';

/// 에러 심각도 레벨
enum ErrorSeverity {
  low, // 낮음 - 로그만 기록
  medium, // 중간 - 사용자에게 알림
  high, // 높음 - 앱 재시작 필요
  critical, // 치명적 - 앱 종료
}

/// 에러 타입
enum ErrorType {
  network, // 네트워크 에러
  database, // 데이터베이스 에러
  validation, // 검증 에러
  authentication, // 인증 에러
  permission, // 권한 에러
  memory, // 메모리 에러
  unknown, // 알 수 없는 에러
}

/// 에러 정보 모델
class ErrorInfo {
  final String message;
  final String? stackTrace;
  final ErrorSeverity severity;
  final ErrorType type;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  const ErrorInfo({
    required this.message,
    this.stackTrace,
    required this.severity,
    required this.type,
    required this.timestamp,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'stackTrace': stackTrace,
      'severity': severity.name,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }

  @override
  String toString() {
    return 'ErrorInfo(severity: $severity, type: $type, message: $message)';
  }
}

/// 공통 에러 처리 서비스
///
/// 모든 feature에서 공통으로 사용되는 에러 처리 로직을 제공합니다.
/// Result<T> 패턴과 함께 사용하여 타입 안전한 에러 처리를 지원합니다.
class CommonErrorService {
  static final CommonErrorService _instance = CommonErrorService._internal();
  factory CommonErrorService() => _instance;
  CommonErrorService._internal();

  // 에러 스트림
  final StreamController<ErrorInfo> _errorController = StreamController<ErrorInfo>.broadcast();

  Stream<ErrorInfo> get errorStream => _errorController.stream;

  // 에러 히스토리
  final List<ErrorInfo> _errorHistory = [];
  static const int _maxHistorySize = 100;

  // 에러 카운터
  final Map<ErrorType, int> _errorCounters = {};
  final Map<ErrorSeverity, int> _severityCounters = {};

  // 에러 처리 설정
  bool _isInitialized = false;
  bool _isEnabled = true;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 전역 에러 핸들러 설정
      _setupGlobalErrorHandlers();

      // 에러 카운터 초기화
      _initializeErrorCounters();

      _isInitialized = true;

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 전역 에러 핸들러 설정
  void _setupGlobalErrorHandlers() {
    // Flutter 에러 핸들러
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };
  }

  /// 에러 카운터 초기화
  void _initializeErrorCounters() {
    for (final type in ErrorType.values) {
      _errorCounters[type] = 0;
    }

    for (final severity in ErrorSeverity.values) {
      _severityCounters[severity] = 0;
    }
  }

  /// Flutter 에러 처리
  void _handleFlutterError(FlutterErrorDetails details) {
    handleErrorInstance(
      details.exception,
      message: details.exceptionAsString(),
      severity: ErrorSeverity.high,
      type: ErrorType.unknown,
      stackTrace: details.stack,
      context: {'library': details.library, 'context': details.context?.toString()},
    );
  }

  /// 에러 처리 (Result 패턴 지원)
  Future<void> handleErrorInstance(
    dynamic error, {
    String? message,
    ErrorSeverity severity = ErrorSeverity.medium,
    ErrorType type = ErrorType.unknown,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) async {
    if (!_isEnabled) return;

    try {
      final errorInfo = ErrorInfo(
        message: message ?? error.toString(),
        stackTrace: stackTrace?.toString(),
        severity: severity,
        type: type,
        timestamp: DateTime.now(),
        context: context,
      );

      // 에러 히스토리에 추가
      _addToHistory(errorInfo);

      // 에러 카운터 업데이트
      _updateErrorCounters(errorInfo);

      // 에러 스트림에 전송
      _errorController.add(errorInfo);

      // 로그 기록
      _logError(errorInfo);

      // 심각도에 따른 처리
      await _handleErrorBySeverity(errorInfo);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 에러 히스토리에 추가
  void _addToHistory(ErrorInfo errorInfo) {
    _errorHistory.add(errorInfo);

    // 히스토리 크기 제한
    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeAt(0);
    }
  }

  /// 에러 카운터 업데이트
  void _updateErrorCounters(ErrorInfo errorInfo) {
    _errorCounters[errorInfo.type] = (_errorCounters[errorInfo.type] ?? 0) + 1;
    _severityCounters[errorInfo.severity] = (_severityCounters[errorInfo.severity] ?? 0) + 1;
  }

  /// 에러 로그 기록
  void _logError(ErrorInfo errorInfo) {
    if (kDebugMode) {
      if (errorInfo.stackTrace != null) {}
      if (errorInfo.context != null) {}
    }

    // 개발자 로그에 기록
    developer.log(
      errorInfo.message,
      name: 'CommonErrorService',
      error: errorInfo.stackTrace,
      stackTrace: errorInfo.stackTrace != null
          ? StackTrace.fromString(errorInfo.stackTrace!)
          : null,
    );
  }

  /// 심각도별 에러 처리
  Future<void> _handleErrorBySeverity(ErrorInfo errorInfo) async {
    switch (errorInfo.severity) {
      case ErrorSeverity.low:
        // 로그만 기록
        break;

      case ErrorSeverity.medium:
        // 사용자에게 알림
        _showUserNotification(errorInfo);
        break;

      case ErrorSeverity.high:
        // 앱 재시작 고려
        _handleHighSeverityError(errorInfo);
        break;

      case ErrorSeverity.critical:
        // 앱 종료
        _handleCriticalError(errorInfo);
        break;
    }
  }

  /// 사용자 알림 표시
  void _showUserNotification(ErrorInfo errorInfo) {
    // SnackBar 또는 다이얼로그로 사용자에게 알림
    if (kDebugMode) {}
  }

  /// 높은 심각도 에러 처리
  void _handleHighSeverityError(ErrorInfo errorInfo) {
    if (kDebugMode) {}

    // 메모리 정리, 캐시 정리 등 수행
    _performRecoveryActions();
  }

  /// 치명적 에러 처리
  void _handleCriticalError(ErrorInfo errorInfo) {
    if (kDebugMode) {}

    // 앱 종료 또는 재시작
    // 실제 구현에서는 앱 종료 로직
  }

  /// 복구 작업 수행
  void _performRecoveryActions() {
    try {
      // 메모리 정리
      // 캐시 정리
      // 네트워크 연결 재설정 등

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 에러 통계 가져오기
  Map<String, dynamic> getErrorStats() {
    return {
      'totalErrors': _errorHistory.length,
      'errorCounters': _errorCounters.map((key, value) => MapEntry(key.name, value)),
      'severityCounters': _severityCounters.map((key, value) => MapEntry(key.name, value)),
      'recentErrors': _errorHistory.take(10).map((e) => e.toJson()).toList(),
    };
  }

  /// 에러 히스토리 가져오기
  List<ErrorInfo> getErrorHistory() {
    return List<ErrorInfo>.from(_errorHistory);
  }

  /// 특정 타입의 에러 개수 가져오기
  int getErrorCountByType(ErrorType type) {
    return _errorCounters[type] ?? 0;
  }

  /// 특정 심각도의 에러 개수 가져오기
  int getErrorCountBySeverity(ErrorSeverity severity) {
    return _severityCounters[severity] ?? 0;
  }

  /// 에러 처리 활성화/비활성화
  void setEnabled(bool enabled) {
    _isEnabled = enabled;

    if (kDebugMode) {}
  }

  /// 에러 히스토리 정리
  void clearErrorHistory() {
    _errorHistory.clear();
    _errorCounters.clear();
    _severityCounters.clear();
    _initializeErrorCounters();

    if (kDebugMode) {}
  }

  /// 서비스 정리
  void dispose() {
    _errorController.close();
    _errorHistory.clear();
    _errorCounters.clear();
    _severityCounters.clear();

    if (kDebugMode) {}
  }

  // ========== Result<T> 패턴 지원 메서드들 ==========

  /// 네트워크 에러 처리
  static Result<T> handleNetworkError<T>(Object error) {
    final errorMessage = _getNetworkErrorMessage(error);
    return Result.failure(errorMessage);
  }

  /// 서버 에러 처리
  static Result<T> handleServerError<T>(Object error, {int? statusCode}) {
    final errorMessage = _getServerErrorMessage(error, statusCode);
    return Result.failure(errorMessage);
  }

  /// 유효성 검사 에러 처리
  static Result<T> handleValidationError<T>(String message) {
    return Result.failure(message);
  }

  /// 인증 에러 처리
  static Result<T> handleAuthError<T>(Object error) {
    final errorMessage = _getAuthErrorMessage(error);
    return Result.failure(errorMessage);
  }

  /// 권한 에러 처리
  static Result<T> handlePermissionError<T>(Object error) {
    final errorMessage = _getPermissionErrorMessage(error);
    return Result.failure(errorMessage);
  }

  /// 파일 에러 처리
  static Result<T> handleFileError<T>(Object error) {
    final errorMessage = _getFileErrorMessage(error);
    return Result.failure(errorMessage);
  }

  /// 일반 에러 처리
  static Result<T> handleGenericError<T>(Object error) {
    final errorMessage = _getGenericErrorMessage(error);
    return Result.failure(errorMessage);
  }

  /// 에러 타입에 따른 자동 처리
  static Result<T> handleError<T>(Object error, {String? context}) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return handleNetworkError<T>(error);
    }

    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return handleServerError<T>(error);
    }

    if (errorString.contains('auth') ||
        errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return handleAuthError<T>(error);
    }

    if (errorString.contains('permission') ||
        errorString.contains('forbidden') ||
        errorString.contains('403')) {
      return handlePermissionError<T>(error);
    }

    if (errorString.contains('file') ||
        errorString.contains('upload') ||
        errorString.contains('download')) {
      return handleFileError<T>(error);
    }

    return handleGenericError<T>(error);
  }

  /// 네트워크 에러 메시지 생성
  static String _getNetworkErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout')) {
      return '接続がタイムアウトしました。ネットワーク接続を確認してください。';
    }

    if (errorString.contains('connection')) {
      return 'ネットワーク接続を確認してください。';
    }

    if (errorString.contains('dns')) {
      return 'サーバーに接続できません。しばらく経ってから再試行してください。';
    }

    return 'ネットワークエラーが発生しました。接続を確認してください。';
  }

  /// 서버 에러 메시지 생성
  static String _getServerErrorMessage(Object error, int? statusCode) {
    if (statusCode != null) {
      switch (statusCode) {
        case 500:
          return 'サーバー内部エラーが発生しました。しばらく経ってから再試行してください。';
        case 502:
          return 'サーバーが一時的に利用できません。しばらく経ってから再試行してください。';
        case 503:
          return 'サーバーがメンテナンス中です。しばらく経ってから再試行してください。';
        case 504:
          return 'サーバーの応答が遅いです。しばらく経ってから再試行してください。';
        default:
          return 'サーバーエラーが発生しました。($statusCode)';
      }
    }

    return 'サーバーエラーが発生しました。しばらく経ってから再試行してください。';
  }

  /// 인증 에러 메시지 생성
  static String _getAuthErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'ログインが必要です。再度ログインしてください。';
    }

    if (errorString.contains('token') || errorString.contains('expired')) {
      return 'セッションが期限切れです。再度ログインしてください。';
    }

    if (errorString.contains('invalid') || errorString.contains('credential')) {
      return '認証情報が正しくありません。';
    }

    return '認証エラーが発生しました。再度ログインしてください。';
  }

  /// 권한 에러 메시지 생성
  static String _getPermissionErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'この操作を実行する権限がありません。';
    }

    if (errorString.contains('permission')) {
      return '必要な権限がありません。設定を確認してください。';
    }

    return 'アクセスが拒否されました。';
  }

  /// 파일 에러 메시지 생성
  static String _getFileErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('upload')) {
      return 'ファイルのアップロードに失敗しました。';
    }

    if (errorString.contains('download')) {
      return 'ファイルのダウンロードに失敗しました。';
    }

    if (errorString.contains('size') || errorString.contains('too large')) {
      return 'ファイルサイズが大きすぎます。';
    }

    if (errorString.contains('format') || errorString.contains('type')) {
      return 'サポートされていないファイル形式です。';
    }

    return 'ファイル操作中にエラーが発生しました。';
  }

  /// 일반 에러 메시지 생성
  static String _getGenericErrorMessage(Object error) {
    final errorString = error.toString();

    // 빈 에러 메시지 처리
    if (StringUtils.isEmpty(errorString)) {
      return '不明なエラーが発生しました。';
    }

    // 기술적 에러 메시지를 사용자 친화적으로 변환
    if (errorString.contains('Exception')) {
      return '処理中にエラーが発生しました。しばらく経ってから再試行してください。';
    }

    if (errorString.contains('Error')) {
      return '予期しないエラーが発生しました。';
    }

    // 원본 메시지가 사용자 친화적이면 그대로 사용
    if (errorString.length < 100 &&
        !errorString.contains('at ') &&
        !errorString.contains('Exception')) {
      return errorString;
    }

    return 'エラーが発生しました。しばらく経ってから再試行してください。';
  }

  /// 에러 로깅을 위한 상세 정보 생성
  static Map<String, dynamic> createErrorLog(
    Object error,
    StackTrace? stackTrace, {
    String? context,
  }) {
    return {
      'error': error.toString(),
      'errorType': error.runtimeType.toString(),
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
      'stackTrace': stackTrace?.toString(),
    };
  }

  /// 에러 복구 가능 여부 확인
  static bool isRecoverableError(Object error) {
    final errorString = error.toString().toLowerCase();

    // 복구 가능한 에러들
    final recoverableErrors = [
      'network',
      'connection',
      'timeout',
      'server',
      '500',
      '502',
      '503',
      '504',
    ];

    return recoverableErrors.any((recoverable) => errorString.contains(recoverable));
  }

  /// 에러에 따른 재시도 권장 여부 확인
  static bool shouldRetry(Object error) {
    final errorString = error.toString().toLowerCase();

    // 재시도 권장 에러들
    final retryableErrors = [
      'network',
      'connection',
      'timeout',
      'server',
      '500',
      '502',
      '503',
      '504',
    ];

    return retryableErrors.any((retryable) => errorString.contains(retryable));
  }
}
