import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// 🎯 기본 로깅 서비스
///
/// 모든 서비스에서 공통으로 사용하는 로깅 로직을 제공
abstract class BaseLoggingService {
  late final Logger _logger;
  late final String _serviceName;

  BaseLoggingService(this._serviceName) {
    _initializeLogger();
  }

  /// Logger 초기화
  void _initializeLogger() {
    _logger = Logger(
      filter: AppConfig.current.isDebugMode
          ? DevelopmentFilter()
          : ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: AppConfig.current.isDebugMode ? 2 : 0,
        errorMethodCount: 3,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: ConsoleOutput(),
    );
  }

  /// Logger 인스턴스 가져오기 (지연 초기화)
  Logger get _loggerInstance {
    try {
      return _logger;
    } catch (e) {
      _initializeLogger();
      return _logger;
    }
  }

  /// 현재 로깅 레벨 (개발 중에는 debug, 프로덕션에서는 info)
  _LogLevel get _currentLogLevel {
    return AppConfig.current.isDebugMode ? _LogLevel.debug : _LogLevel.info;
  }

  /// 에러 로깅
  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (_currentLogLevel.index <= _LogLevel.error.index) {
      // Logger를 사용한 로깅
      _loggerInstance.e(message, error: error, stackTrace: stackTrace);

      // Sentry를 사용한 에러 추적
      if (error != null) {
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('service', _serviceName);
            scope.setExtra('${_serviceName}_error', {
              'message': message,
              'timestamp': DateTime.now().toIso8601String(),
            });
          },
        );
      } else {
        // 에러 객체가 없는 경우 메시지만 Sentry에 전송
        Sentry.captureMessage(
          message,
          level: SentryLevel.error,
          withScope: (scope) {
            scope.setTag('service', _serviceName);
            scope.setExtra('${_serviceName}_error', {
              'timestamp': DateTime.now().toIso8601String(),
            });
          },
        );
      }
    }
  }

  /// 정보 로깅
  void logInfo(String message) {
    if (_currentLogLevel.index <= _LogLevel.info.index) {
      _loggerInstance.i(message);
    }
  }

  /// 경고 로깅
  void logWarning(String message) {
    if (_currentLogLevel.index <= _LogLevel.warning.index) {
      _loggerInstance.w(message);

      // 경고도 Sentry에 전송 (선택적)
      if (AppConfig.current.isDebugMode) {
        Sentry.captureMessage(
          message,
          level: SentryLevel.warning,
          withScope: (scope) {
            scope.setTag('service', _serviceName);
            scope.setTag('type', 'warning');
          },
        );
      }
    }
  }

  /// 디버그 로깅
  void logDebug(String message) {
    if (_currentLogLevel.index <= _LogLevel.debug.index &&
        AppConfig.current.isDebugMode) {
      _loggerInstance.d(message);
    }
  }

  /// 성능 메트릭 기록
  void recordPerformanceMetric(String operation, Duration duration) {
    logDebug('Performance: $operation took ${duration.inMilliseconds}ms');

    // Sentry에 성능 메트릭 전송
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'Performance metric: $operation',
        data: {
          'operation': operation,
          'duration_ms': duration.inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
          'service': _serviceName,
        },
        category: 'performance',
        level: SentryLevel.info,
      ),
    );
  }

  /// API 호출 성능 추적
  Future<T> trackApiPerformance<T>(
    String operation,
    Future<T> Function() apiCall,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await apiCall();
      stopwatch.stop();
      recordPerformanceMetric(operation, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      recordPerformanceMetric('${operation}_error', stopwatch.elapsed);
      rethrow;
    }
  }
}

/// 로깅 레벨 열거형
enum _LogLevel { debug, info, warning, error }
