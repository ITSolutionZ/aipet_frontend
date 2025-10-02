/// 🎯 고급 에러 복구 전략
///
/// 복잡한 에러 상황에 대한 고급 복구 전략을 제공합니다.
/// Circuit Breaker, Retry with Backoff, Fallback 등 엔터프라이즈급 패턴을 구현합니다.
library;

import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';

/// Future를 Result로 변환하는 확장 메서드
extension FutureToResult<T> on Future<T> {
  Future<Result<T>> toResult() async {
    try {
      final result = await this;
      return Result.success('Success', result);
    } catch (error) {
      return Result.failure(error.toString());
    }
  }
}

/// Circuit Breaker 패턴 구현
class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _nextAttemptTime;

  CircuitBreaker({
    required this.name,
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 30),
    this.resetTimeout = const Duration(minutes: 1),
  });

  /// Circuit Breaker를 통한 작업 실행
  Future<Result> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitState.open) {
      if (_nextAttemptTime != null && DateTime.now().isBefore(_nextAttemptTime!)) {
        return Result.failure('Circuit breaker is open. Next attempt at $_nextAttemptTime');
      }
      _state = CircuitState.halfOpen;
    }

    try {
      final result = await operation().timeout(timeout);
      _onSuccess();
      return Result.success('Success', result);
    } catch (e) {
      _onFailure();
      return Result.fromException(Exception(e.toString()));
    }
  }

  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitState.closed;
    _nextAttemptTime = null;
  }

  void _onFailure() {
    _failureCount++;

    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
      _nextAttemptTime = DateTime.now().add(resetTimeout);
    }
  }

  CircuitState get state => _state;
  int get failureCount => _failureCount;
}

enum CircuitState { closed, open, halfOpen }

/// 지수 백오프 재시도 전략
class ExponentialBackoffRetry {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final bool Function(Exception)? retryCondition;

  const ExponentialBackoffRetry({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
    this.retryCondition,
  });

  /// 지수 백오프로 재시도 실행
  Future<Result> execute<T>(Future<T> Function() operation) async {
    int attempt = 0;
    Duration delay = initialDelay;
    Exception? lastException;

    while (attempt <= maxRetries) {
      try {
        final result = await operation();
        return Result.success('Success', result);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;

        // 재시도 조건 확인
        if (retryCondition != null && !retryCondition!(lastException)) {
          break;
        }

        // 마지막 시도가 아니면 대기
        if (attempt <= maxRetries) {
          await Future.delayed(delay);
          delay = Duration(
            milliseconds: (delay.inMilliseconds * backoffMultiplier)
                .clamp(0, maxDelay.inMilliseconds)
                .round(),
          );
        }
      }
    }

    return Result.fromException(Exception(lastException!.toString()));
  }
}

/// Fallback 전략
class FallbackStrategy {
  final String name;
  final Duration timeout;
  final Map<String, dynamic>? context;

  const FallbackStrategy({
    required this.name,
    this.timeout = const Duration(seconds: 5),
    this.context,
  });

  /// Fallback 작업 실행
  Future<Result> execute<T>(
    Future<T> Function() primaryOperation,
    Future<T> Function() fallbackOperation,
  ) async {
    try {
      final result = await primaryOperation().timeout(timeout);
      return Result.success('Success', result);
    } catch (e) {
      try {
        final fallbackResult = await fallbackOperation().timeout(timeout);
        return Result.success('Fallback operation succeeded: $name', fallbackResult);
      } catch (fallbackError) {
        return Result.failure(
          'Both primary and fallback operations failed. Primary: ${e.toString()}, Fallback: ${fallbackError.toString()}',
        );
      }
    }
  }

  /// 동기 Fallback 작업 실행
  Result executeSync<T>(T Function() primaryOperation, T Function() fallbackOperation) {
    try {
      final result = primaryOperation();
      return Result.success('Success', result);
    } catch (e) {
      try {
        final fallbackResult = fallbackOperation();
        return Result.success('Fallback operation succeeded: $name', fallbackResult);
      } catch (fallbackError) {
        return Result.failure(
          'Both primary and fallback operations failed. Primary: ${e.toString()}, Fallback: ${fallbackError.toString()}',
        );
      }
    }
  }
}

/// 고급 에러 복구 매니저
class AdvancedErrorRecoveryManager extends BaseLoggingService {
  static AdvancedErrorRecoveryManager? _instance;

  final Map<String, CircuitBreaker> _circuitBreakers = {};
  final Map<String, ExponentialBackoffRetry> _retryStrategies = {};
  final Map<String, FallbackStrategy> _fallbackStrategies = {};

  AdvancedErrorRecoveryManager._() : super('advanced_error_recovery');

  static AdvancedErrorRecoveryManager get instance {
    _instance ??= AdvancedErrorRecoveryManager._();
    return _instance!;
  }

  /// Circuit Breaker 등록
  void registerCircuitBreaker(CircuitBreaker circuitBreaker) {
    _circuitBreakers[circuitBreaker.name] = circuitBreaker;
    logInfo('Circuit breaker registered: ${circuitBreaker.name}');
  }

  /// Circuit Breaker를 통한 작업 실행
  Future<Result> executeWithCircuitBreaker<T>(
    String circuitBreakerName,
    Future<T> Function() operation,
  ) async {
    final circuitBreaker = _circuitBreakers[circuitBreakerName];
    if (circuitBreaker == null) {
      logWarning('Circuit breaker not found: $circuitBreakerName');
      return operation().toResult();
    }

    return circuitBreaker.execute(operation);
  }

  /// 지수 백오프 재시도 전략 등록
  void registerRetryStrategy(String name, ExponentialBackoffRetry retryStrategy) {
    _retryStrategies[name] = retryStrategy;
    logInfo('Retry strategy registered: $name');
  }

  /// 지수 백오프로 작업 실행
  Future<Result> executeWithRetry<T>(
    String retryStrategyName,
    Future<T> Function() operation,
  ) async {
    final retryStrategy = _retryStrategies[retryStrategyName];
    if (retryStrategy == null) {
      logWarning('Retry strategy not found: $retryStrategyName');
      return operation().toResult();
    }

    return retryStrategy.execute(operation);
  }

  /// Fallback 전략 등록
  void registerFallbackStrategy(FallbackStrategy fallbackStrategy) {
    _fallbackStrategies[fallbackStrategy.name] = fallbackStrategy;
    logInfo('Fallback strategy registered: ${fallbackStrategy.name}');
  }

  /// Fallback으로 작업 실행
  Future<Result> executeWithFallback<T>(
    String fallbackStrategyName,
    Future<T> Function() primaryOperation,
    Future<T> Function() fallbackOperation,
  ) async {
    final fallbackStrategy = _fallbackStrategies[fallbackStrategyName];
    if (fallbackStrategy == null) {
      logWarning('Fallback strategy not found: $fallbackStrategyName');
      return primaryOperation().toResult();
    }

    return fallbackStrategy.execute(primaryOperation, fallbackOperation);
  }

  /// 복합 전략 실행 (Circuit Breaker + Retry + Fallback)
  Future<Result> executeWithFullRecovery<T>({
    required String circuitBreakerName,
    required String retryStrategyName,
    required String fallbackStrategyName,
    required Future<T> Function() primaryOperation,
    required Future<T> Function() fallbackOperation,
  }) async {
    // 1. Circuit Breaker로 실행
    final circuitResult = await executeWithCircuitBreaker(circuitBreakerName, primaryOperation);

    if (circuitResult.isSuccess) {
      return circuitResult;
    }

    // 2. Retry 전략으로 재시도
    final retryResult = await executeWithRetry(retryStrategyName, primaryOperation);

    if (retryResult.isSuccess) {
      return retryResult;
    }

    // 3. Fallback 전략으로 최종 시도
    return executeWithFallback(fallbackStrategyName, primaryOperation, fallbackOperation);
  }

  /// Circuit Breaker 상태 조회
  Map<String, dynamic> getCircuitBreakerStatus() {
    return _circuitBreakers.map(
      (name, breaker) => MapEntry(name, {
        'state': breaker.state.name,
        'failureCount': breaker.failureCount,
        'nextAttemptTime': breaker._nextAttemptTime?.toIso8601String(),
      }),
    );
  }

  /// 모든 Circuit Breaker 리셋
  void resetAllCircuitBreakers() {
    for (final breaker in _circuitBreakers.values) {
      breaker._state = CircuitState.closed;
      breaker._failureCount = 0;
      breaker._nextAttemptTime = null;
    }
    logInfo('All circuit breakers reset');
  }
}

/// 고급 에러 복구 확장 메서드들
extension AdvancedErrorRecoveryExtensions<T> on Future<T> Function() {
  /// Circuit Breaker와 함께 실행
  Future<Result> withCircuitBreaker(String circuitBreakerName) async {
    return AdvancedErrorRecoveryManager.instance.executeWithCircuitBreaker(
      circuitBreakerName,
      this,
    );
  }

  /// 지수 백오프 재시도와 함께 실행
  Future<Result> withExponentialBackoff(String retryStrategyName) async {
    return AdvancedErrorRecoveryManager.instance.executeWithRetry(retryStrategyName, this);
  }

  /// Fallback과 함께 실행
  Future<Result> withFallback<T>(
    String fallbackStrategyName,
    Future<T> Function() fallbackOperation,
  ) async {
    return AdvancedErrorRecoveryManager.instance.executeWithFallback(
      fallbackStrategyName,
      this,
      fallbackOperation,
    );
  }
}

/// 동기 함수 고급 에러 복구 확장 메서드들
extension SyncAdvancedErrorRecoveryExtensions<T> on T Function() {
  /// 동기 Fallback과 함께 실행
  Result withFallbackSync(String fallbackStrategyName, T Function() fallbackOperation) {
    final fallbackStrategy =
        AdvancedErrorRecoveryManager.instance._fallbackStrategies[fallbackStrategyName];
    if (fallbackStrategy == null) {
      try {
        final result = this();
        return Result.success('Success', result);
      } catch (error) {
        return Result.failure(error.toString());
      }
    }

    return fallbackStrategy.executeSync(this, fallbackOperation);
  }
}
