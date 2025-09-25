import 'dart:async';
import 'dart:convert';

import 'package:aipet_frontend/shared/monitoring/monitoring_dashboard.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';

/// 🔴 실시간 모니터링 서비스
///
/// 앱의 실시간 상태를 모니터링하고 알림을 제공합니다.
class RealTimeMonitor {
  static RealTimeMonitor? _instance;
  static RealTimeMonitor get instance => _instance ??= RealTimeMonitor._();

  RealTimeMonitor._();

  final StreamController<MonitoringEvent> _eventController =
      StreamController.broadcast();
  final List<MonitoringSubscription> _subscriptions = [];
  Timer? _monitoringTimer;
  final Duration _checkInterval = const Duration(seconds: 5);

  /// 이벤트 스트림
  Stream<MonitoringEvent> get eventStream => _eventController.stream;

  /// 모니터링 시작
  void startRealTimeMonitoring() {
    if (_monitoringTimer?.isActive == true) return;

    _monitoringTimer = Timer.periodic(_checkInterval, (_) {
      _checkSystemHealth();
      _checkPerformanceThresholds();
      _checkSecurityStatus();
    });

    BaseLoggingService.instance.logInfo('Real-time monitoring started');
  }

  /// 모니터링 중지
  void stopRealTimeMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    BaseLoggingService.instance.logInfo('Real-time monitoring stopped');
  }

  /// 시스템 건강 상태 확인
  void _checkSystemHealth() {
    final dashboard = MonitoringDashboard.instance;
    final status = dashboard.getDashboardStatus();

    if (!status.isHealthy) {
      _emitEvent(
        MonitoringEvent(
          type: EventType.systemHealth,
          severity: EventSeverity.critical,
          message: 'System health issues detected',
          data: {
            'recentErrors': status.recentErrors,
            'recentSecurityAlerts': status.recentSecurityAlerts,
          },
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// 성능 임계값 확인
  void _checkPerformanceThresholds() {
    final dashboard = MonitoringDashboard.instance;
    final status = dashboard.getDashboardStatus();

    // API 응답 시간 임계값 확인
    if (status.avgResponseTime > 2000) {
      _emitEvent(
        MonitoringEvent(
          type: EventType.performance,
          severity: EventSeverity.warning,
          message: 'API response time is slow',
          data: {'avgResponseTime': status.avgResponseTime, 'threshold': 2000},
          timestamp: DateTime.now(),
        ),
      );
    }

    // 메모리 사용량 임계값 확인
    if (status.avgMemoryUsage > 150) {
      _emitEvent(
        MonitoringEvent(
          type: EventType.performance,
          severity: EventSeverity.warning,
          message: 'High memory usage detected',
          data: {'avgMemoryUsage': status.avgMemoryUsage, 'threshold': 150},
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// 보안 상태 확인
  void _checkSecurityStatus() {
    final dashboard = MonitoringDashboard.instance;
    final status = dashboard.getDashboardStatus();

    if (status.recentSecurityAlerts > 0) {
      _emitEvent(
        MonitoringEvent(
          type: EventType.security,
          severity: EventSeverity.critical,
          message: 'Security alerts detected',
          data: {'recentSecurityAlerts': status.recentSecurityAlerts},
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// 이벤트 발생
  void _emitEvent(MonitoringEvent event) {
    _eventController.add(event);

    // 구독자들에게 알림
    for (final subscription in _subscriptions) {
      if (subscription.shouldNotify(event)) {
        subscription.notify(event);
      }
    }

    // 로그 기록
    BaseLoggingService.instance.logInfo(
      'Monitoring event: ${event.type.name} - ${event.message}',
    );
  }

  /// 구독 추가
  void addSubscription(MonitoringSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// 구독 제거
  void removeSubscription(MonitoringSubscription subscription) {
    _subscriptions.remove(subscription);
  }

  /// 에러 이벤트 발생
  void emitErrorEvent(String error, String stackTrace, {String? context}) {
    _emitEvent(
      MonitoringEvent(
        type: EventType.error,
        severity: EventSeverity.critical,
        message: error,
        data: {'stackTrace': stackTrace, 'context': context},
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 성능 이벤트 발생
  void emitPerformanceEvent(
    String operation,
    int duration, {
    Map<String, dynamic>? metadata,
  }) {
    EventSeverity severity = EventSeverity.info;
    if (duration > 5000) {
      severity = EventSeverity.critical;
    } else if (duration > 2000) {
      severity = EventSeverity.warning;
    }

    _emitEvent(
      MonitoringEvent(
        type: EventType.performance,
        severity: severity,
        message: 'Performance issue detected',
        data: {
          'operation': operation,
          'duration': duration,
          'metadata': metadata,
        },
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 보안 이벤트 발생
  void emitSecurityEvent(String message, {Map<String, dynamic>? data}) {
    _emitEvent(
      MonitoringEvent(
        type: EventType.security,
        severity: EventSeverity.critical,
        message: message,
        data: data,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 리소스 정리
  void dispose() {
    stopRealTimeMonitoring();
    _eventController.close();
    _subscriptions.clear();
  }
}

/// 모니터링 이벤트 데이터 모델
class MonitoringEvent {
  final EventType type;
  final EventSeverity severity;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  MonitoringEvent({
    required this.type,
    required this.severity,
    required this.message,
    this.data,
    required this.timestamp,
  });
}

/// 모니터링 구독 인터페이스
abstract class MonitoringSubscription {
  bool shouldNotify(MonitoringEvent event);
  void notify(MonitoringEvent event);
}

/// 콘솔 알림 구독
class ConsoleNotificationSubscription implements MonitoringSubscription {
  @override
  bool shouldNotify(MonitoringEvent event) {
    return event.severity == EventSeverity.critical ||
        event.severity == EventSeverity.warning;
  }

  @override
  void notify(MonitoringEvent event) {
    final emoji = _getSeverityEmoji(event.severity);
    print(
      '$emoji [${event.timestamp.toIso8601String()}] ${event.type.name.toUpperCase()}: ${event.message}',
    );

    if (event.data != null) {
      print('   Data: ${jsonEncode(event.data)}');
    }
  }

  String _getSeverityEmoji(EventSeverity severity) {
    switch (severity) {
      case EventSeverity.info:
        return 'ℹ️';
      case EventSeverity.warning:
        return '⚠️';
      case EventSeverity.critical:
        return '🚨';
    }
  }
}

/// 파일 로그 구독
class FileLogSubscription implements MonitoringSubscription {
  @override
  bool shouldNotify(MonitoringEvent event) {
    return true; // 모든 이벤트 로그
  }

  @override
  void notify(MonitoringEvent event) {
    // 파일 로그 구현
    BaseLoggingService.instance.logInfo(
      'MONITORING: ${event.type.name} - ${event.message}',
    );
  }
}

/// 이벤트 타입 열거형
enum EventType { systemHealth, performance, security, error, user }

/// 이벤트 심각도 열거형
enum EventSeverity { info, warning, critical }
