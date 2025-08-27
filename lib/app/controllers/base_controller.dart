import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/error_service.dart';

/// 모든 Controller의 기본 클래스
/// Clean Architecture 원칙에 따라 UI 로직을 분리하고 메모리 리크를 방지합니다
abstract class BaseController {
  final WidgetRef ref;
  final ErrorService _errorService = ErrorService();

  // 메모리 리크를 방지하기위해 StreamController 등 리소스를 추적
  final List<StreamSubscription> _subscriptions = [];
  final List<Timer> _timers = [];
  final List<ChangeNotifier> _notifiers = [];

  BaseController(this.ref);

  /// 에러 처리 (비즈니스 로직만 처리, UI는 분리)
  void handleError(dynamic error, [StackTrace? stackTrace]) {
    _errorService.handleError(error, stackTrace);
  }

  /// 심각도별 에러 처리
  void handleErrorWithSeverity(
    dynamic error,
    ErrorSeverity severity, [
    StackTrace? stackTrace,
  ]) {
    _errorService.handleErrorWithSeverity(error, severity, stackTrace);
  }

  /// 사용자에게 보여줄 에러 메시지 생성
  String getUserFriendlyErrorMessage(dynamic error) {
    return _errorService.getUserFriendlyMessage(error);
  }

  /// StreamSubscription을 등록하여 자동으로 dispose될 수 있도록 합니다
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Timer를 등록하여 자동으로 dispose될 수 있도록 합니다
  void addTimer(Timer timer) {
    _timers.add(timer);
  }

  /// ChangeNotifier를 등록하여 자동으로 dispose될 수 있도록 합니다
  void addNotifier(ChangeNotifier notifier) {
    _notifiers.add(notifier);
  }

  /// 지연된 작업 실행
  Timer scheduleTask(VoidCallback task, Duration delay) {
    final timer = Timer(delay, task);
    addTimer(timer);
    return timer;
  }

  /// 주기적 작업 실행
  Timer schedulePeriodicTask(VoidCallback task, Duration period) {
    final timer = Timer.periodic(period, (_) => task());
    addTimer(timer);
    return timer;
  }

  /// 리소스 정리 (반드시 override하여 호출해야 함)
  void dispose() {
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
      handleError(error, stackTrace);
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
      if (error is TimeoutException) {
        handleError('작업이 시간 초과되었습니다', stackTrace);
      } else {
        handleError(error, stackTrace);
      }
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
          handleError(error, stackTrace);
          return null;
        }
        await Future.delayed(retryDelay * attempts);
      }
    }
    return null;
  }
}
