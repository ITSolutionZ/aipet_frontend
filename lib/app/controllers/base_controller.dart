import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/error_service.dart';

/// 모든 Controller의 기본 클래스
///
/// Clean Architecture 원칙에 따라 UI 로직을 분리하고 메모리 리크를 방지합니다.
/// 모든 Controller는 이 클래스를 상속받아야 하며, 공통 기능을 제공합니다.
abstract class BaseController {
  final WidgetRef ref;
  final ErrorService _errorService;

  bool _disposed = false;

  // 메모리 리크를 방지하기위해 StreamController 등 리소스를 추적
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<ChangeNotifier> _notifiers = [];

  BaseController(this.ref, {ErrorService? errorService})
    : _errorService = errorService ?? ErrorService();

  /// 에러를 처리합니다.
  ///
  /// 비즈니스 로직만 처리하고 UI는 분리하여 처리합니다.
  ///
  /// [error] 처리할 에러 객체
  /// [stackTrace] 스택 트레이스 (선택사항)
  void handleError(Object error, [StackTrace? stackTrace]) {
    _errorService.handleError(error, stackTrace);
  }

  /// 심각도별 에러를 처리합니다.
  ///
  /// 에러의 심각도에 따라 적절한 처리 방식을 선택합니다.
  ///
  /// [error] 처리할 에러 객체
  /// [severity] 에러 심각도
  /// [stackTrace] 스택 트레이스 (선택사항)
  void handleErrorWithSeverity(
    Object error,
    ErrorSeverity severity, [
    StackTrace? stackTrace,
  ]) {
    _errorService.handleErrorWithSeverity(error, severity, stackTrace);
  }

  /// 사용자에게 보여줄 친화적인 에러 메시지를 생성합니다.
  ///
  /// 기술적인 에러 메시지를 사용자가 이해할 수 있는 형태로 변환합니다.
  ///
  /// [error] 원본 에러 객체
  /// [return] 사용자 친화적인 에러 메시지
  String getUserFriendlyErrorMessage(Object error) {
    return _errorService.getUserFriendlyMessage(error);
  }

  /// Controller가 이미 dispose되었는지 확인합니다.
  bool get isDisposed => _disposed;

  /// dispose 전에 호출되는 검증 메서드입니다.
  ///
  /// Controller가 이미 dispose된 상태에서 메서드를 호출하려고 할 때 에러를 발생시킵니다.
  void _checkDisposed() {
    if (_disposed) {
      throw StateError('Controller가 이미 dispose되었습니다');
    }
  }

  /// StreamSubscription을 등록하여 자동으로 dispose될 수 있도록 합니다.
  ///
  /// [subscription] 등록할 StreamSubscription
  void addSubscription(StreamSubscription subscription) {
    _checkDisposed();
    _subscriptions.add(subscription);
  }

  /// Timer를 등록하여 자동으로 dispose될 수 있도록 합니다.
  ///
  /// [timer] 등록할 Timer
  void addTimer(Timer timer) {
    _checkDisposed();
    _timers.add(timer);
  }

  /// ChangeNotifier를 등록하여 자동으로 dispose될 수 있도록 합니다.
  ///
  /// [notifier] 등록할 ChangeNotifier
  void addNotifier(ChangeNotifier notifier) {
    _checkDisposed();
    _notifiers.add(notifier);
  }

  /// 지연된 작업을 실행합니다.
  ///
  /// [task] 실행할 작업
  /// [delay] 지연 시간
  /// [return] 생성된 Timer
  Timer scheduleTask(VoidCallback task, Duration delay) {
    _checkDisposed();
    final timer = Timer(delay, task);
    addTimer(timer);
    return timer;
  }

  /// 주기적 작업을 실행합니다.
  ///
  /// [task] 실행할 작업
  /// [period] 실행 주기
  /// [return] 생성된 Timer
  Timer schedulePeriodicTask(VoidCallback task, Duration period) {
    _checkDisposed();
    final timer = Timer.periodic(period, (_) => task());
    addTimer(timer);
    return timer;
  }

  /// 리소스를 정리합니다.
  ///
  /// 반드시 override하여 호출해야 하며, 모든 등록된 리소스를 해제합니다.
  void dispose() {
    if (_disposed) return;

    // 모든 구독 취소
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 모든 타이머 취소
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    // 모든 ChangeNotifier dispose
    for (final notifier in _notifiers) {
      notifier.dispose();
    }
    _notifiers.clear();

    _disposed = true;
  }

  /// 안전한 비동기 작업 실행
  /// 에러가 발생하면 자동으로 처리하고 사용자 친화적인 메시지를 반환합니다
  Future<T?> safeExecute<T>(
    Future<T> Function() action, {
    String? errorMessage,
  }) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      final errorToHandle = errorMessage != null
          ? '$errorMessage: $error'
          : error;
      handleError(errorToHandle, stackTrace);
      return null;
    }
  }

  /// 타임아웃이 있는 안전한 비동기 작업 실행
  Future<T?> safeExecuteWithTimeout<T>(
    Future<T> Function() action, {
    Duration timeout = const Duration(seconds: 30),
    String? errorMessage,
  }) async {
    try {
      return await action().timeout(timeout);
    } catch (error, stackTrace) {
      String errorToHandle;
      if (error is TimeoutException) {
        errorToHandle = errorMessage != null
            ? '$errorMessage: 操作がタイムアウトしました'
            : '操作がタイムアウトしました';
      } else {
        errorToHandle = errorMessage != null
            ? '$errorMessage: $error'
            : error.toString();
      }
      handleError(errorToHandle, stackTrace);
      return null;
    }
  }

  /// 재시도 로직이 있는 안전한 비동기 작업 실행
  Future<T?> safeExecuteWithRetry<T>(
    Future<T> Function() action, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    String? errorMessage,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await action();
      } catch (error, stackTrace) {
        attempts++;
        if (attempts >= maxRetries) {
          final errorToHandle = errorMessage != null
              ? '$errorMessage: $error (再試行 $maxRetries回失敗)'
              : '$error (再試行 $maxRetries回失敗)';
          handleError(errorToHandle, stackTrace);
          return null;
        }
        await Future.delayed(retryDelay * attempts);
      }
    }
    return null;
  }
}
