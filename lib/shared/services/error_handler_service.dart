import 'dart:async';
import 'dart:developer' as developer;

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

/// 전역 에러 처리 서비스
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  // 에러 스트림
  final StreamController<ErrorInfo> _errorController =
      StreamController<ErrorInfo>.broadcast();

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

      if (kDebugMode) {
        print('에러 처리 서비스 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('에러 처리 서비스 초기화 실패: $e');
      }
    }
  }

  /// 전역 에러 핸들러 설정
  void _setupGlobalErrorHandlers() {
    // Flutter 에러 핸들러
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Zone 에러 핸들러
    runZonedGuarded(
      () {
        // 앱 실행
      },
      (error, stackTrace) {
        _handleZoneError(error, stackTrace);
      },
    );
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

  /// 에러 처리
  Future<void> handleError(
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

      if (kDebugMode) {
        print('에러 처리 완료: ${errorInfo.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('에러 처리 중 실패: $e');
      }
    }
  }

  /// Flutter 에러 처리
  void _handleFlutterError(FlutterErrorDetails details) {
    handleError(
      details.exception,
      message: details.exceptionAsString(),
      severity: ErrorSeverity.high,
      type: ErrorType.unknown,
      stackTrace: details.stack,
      context: {
        'library': details.library,
        'context': details.context?.toString(),
      },
    );
  }

  /// Zone 에러 처리
  void _handleZoneError(dynamic error, StackTrace stackTrace) {
    handleError(
      error,
      severity: ErrorSeverity.high,
      type: ErrorType.unknown,
      stackTrace: stackTrace,
    );
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
    _severityCounters[errorInfo.severity] =
        (_severityCounters[errorInfo.severity] ?? 0) + 1;
  }

  /// 에러 로그 기록
  void _logError(ErrorInfo errorInfo) {
    if (kDebugMode) {
      print('=== 에러 발생 ===');
      print('메시지: ${errorInfo.message}');
      print('심각도: ${errorInfo.severity}');
      print('타입: ${errorInfo.type}');
      print('시간: ${errorInfo.timestamp}');
      if (errorInfo.stackTrace != null) {
        print('스택 트레이스: ${errorInfo.stackTrace}');
      }
      if (errorInfo.context != null) {
        print('컨텍스트: ${errorInfo.context}');
      }
      print('================');
    }

    // 개발자 로그에 기록
    developer.log(
      errorInfo.message,
      name: 'ErrorHandler',
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
    // 실제 구현에서는 UiService 사용
    if (kDebugMode) {
      print('사용자 알림: ${errorInfo.message}');
    }
  }

  /// 높은 심각도 에러 처리
  void _handleHighSeverityError(ErrorInfo errorInfo) {
    if (kDebugMode) {
      print('높은 심각도 에러: ${errorInfo.message}');
    }

    // 메모리 정리, 캐시 정리 등 수행
    _performRecoveryActions();
  }

  /// 치명적 에러 처리
  void _handleCriticalError(ErrorInfo errorInfo) {
    if (kDebugMode) {
      print('치명적 에러: ${errorInfo.message}');
    }

    // 앱 종료 또는 재시작
    // 실제 구현에서는 앱 종료 로직
  }

  /// 복구 작업 수행
  void _performRecoveryActions() {
    try {
      // 메모리 정리
      // 캐시 정리
      // 네트워크 연결 재설정 등

      if (kDebugMode) {
        print('복구 작업 수행 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('복구 작업 실패: $e');
      }
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

    if (kDebugMode) {
      print('에러 처리 ${enabled ? '활성화' : '비활성화'}');
    }
  }

  /// 에러 히스토리 정리
  void clearErrorHistory() {
    _errorHistory.clear();
    _errorCounters.clear();
    _severityCounters.clear();
    _initializeErrorCounters();

    if (kDebugMode) {
      print('에러 히스토리 정리 완료');
    }
  }

  /// 서비스 정리
  void dispose() {
    _errorController.close();
    _errorHistory.clear();
    _errorCounters.clear();
    _severityCounters.clear();

    if (kDebugMode) {
      print('에러 처리 서비스 정리 완료');
    }
  }
}
