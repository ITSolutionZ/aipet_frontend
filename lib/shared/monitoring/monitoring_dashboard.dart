import 'dart:async';

import 'package:aipet_frontend/shared/performance/performance_monitor.dart';
import 'package:aipet_frontend/shared/security/production_security_validator.dart';
import 'package:aipet_frontend/shared/services/base_logging_service.dart';

/// 📊 실시간 모니터링 대시보드
///
/// 앱의 전반적인 상태를 실시간으로 모니터링하고
/// 성능 지표, 보안 상태, 에러 로그 등을 종합적으로 관리합니다.
class MonitoringDashboard {
  static MonitoringDashboard? _instance;
  static MonitoringDashboard get instance => _instance ??= MonitoringDashboard._();

  MonitoringDashboard._();

  final List<MonitoringMetric> _metrics = [];
  final List<ErrorLog> _errorLogs = [];
  final List<SecurityAlert> _securityAlerts = [];
  Timer? _monitoringTimer;
  final Duration _collectionInterval = const Duration(seconds: 10);

  /// 모니터링 시작
  void startMonitoring() {
    if (_monitoringTimer?.isActive == true) return;

    _monitoringTimer = Timer.periodic(_collectionInterval, (_) {
      _collectMetrics();
      _checkSecurityStatus();
      _analyzePerformance();
    });

    BaseLoggingService.instance.logInfo('Monitoring dashboard started');
  }

  /// 모니터링 중지
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    BaseLoggingService.instance.logInfo('Monitoring dashboard stopped');
  }

  /// 메트릭 수집
  void _collectMetrics() {
    try {
      // 성능 메트릭 수집
      final performanceReport = PerformanceMonitor.instance.generateReport();

      _metrics.add(
        MonitoringMetric(
          type: MetricType.performance,
          name: 'api_response_time',
          value: performanceReport.avgApiResponseTime,
          timestamp: DateTime.now(),
          metadata: {'unit': 'ms'},
        ),
      );

      _metrics.add(
        MonitoringMetric(
          type: MetricType.performance,
          name: 'memory_usage',
          value: performanceReport.avgMemoryUsage,
          timestamp: DateTime.now(),
          metadata: {'unit': 'MB'},
        ),
      );

      _metrics.add(
        MonitoringMetric(
          type: MetricType.performance,
          name: 'widget_build_time',
          value: performanceReport.avgWidgetBuildTime,
          timestamp: DateTime.now(),
          metadata: {'unit': 'ms'},
        ),
      );

      // 느린 작업 알림
      for (final slowOp in performanceReport.slowOperations) {
        _metrics.add(
          MonitoringMetric(
            type: MetricType.alert,
            name: 'slow_operation',
            value: slowOp.duration.toDouble(),
            timestamp: slowOp.timestamp,
            metadata: {'operation': slowOp.operationName, 'threshold': 1000},
          ),
        );
      }

      // 메모리 알림
      for (final memoryAlert in performanceReport.memoryAlerts) {
        _metrics.add(
          MonitoringMetric(
            type: MetricType.alert,
            name: 'memory_alert',
            value: memoryAlert.memoryUsage,
            timestamp: memoryAlert.timestamp,
            metadata: {'threshold': 100.0},
          ),
        );
      }

      // 메트릭 개수 제한 (메모리 절약)
      if (_metrics.length > 1000) {
        _metrics.removeRange(0, 500);
      }
    } catch (e) {
      BaseLoggingService.instance.logError('Failed to collect metrics: $e');
    }
  }

  /// 보안 상태 확인
  void _checkSecurityStatus() {
    try {
      // 보안 검증 실행
      ProductionSecurityValidator.runAllSecurityValidations();

      _metrics.add(
        MonitoringMetric(
          type: MetricType.security,
          name: 'security_check',
          value: 1.0,
          timestamp: DateTime.now(),
          metadata: {'status': 'passed'},
        ),
      );
    } catch (e) {
      // 보안 위반 감지
      _securityAlerts.add(
        SecurityAlert(
          type: SecurityAlertType.validation,
          message: e.toString(),
          timestamp: DateTime.now(),
          severity: SecuritySeverity.high,
        ),
      );

      _metrics.add(
        MonitoringMetric(
          type: MetricType.security,
          name: 'security_violation',
          value: 0.0,
          timestamp: DateTime.now(),
          metadata: {'error': e.toString()},
        ),
      );
    }
  }

  /// 성능 분석
  void _analyzePerformance() {
    final recentMetrics = _metrics
        .where((m) => m.timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 5))))
        .toList();

    // API 응답 시간 분석
    final apiMetrics = recentMetrics.where((m) => m.name == 'api_response_time').toList();

    if (apiMetrics.isNotEmpty) {
      final avgResponseTime =
          apiMetrics.map((m) => m.value).reduce((a, b) => a + b) / apiMetrics.length;

      if (avgResponseTime > 2000) {
        // 2초 이상
        _metrics.add(
          MonitoringMetric(
            type: MetricType.alert,
            name: 'slow_api_response',
            value: avgResponseTime,
            timestamp: DateTime.now(),
            metadata: {'threshold': 2000},
          ),
        );
      }
    }

    // 메모리 사용량 분석
    final memoryMetrics = recentMetrics.where((m) => m.name == 'memory_usage').toList();

    if (memoryMetrics.isNotEmpty) {
      final avgMemory =
          memoryMetrics.map((m) => m.value).reduce((a, b) => a + b) / memoryMetrics.length;

      if (avgMemory > 150) {
        // 150MB 이상
        _metrics.add(
          MonitoringMetric(
            type: MetricType.alert,
            name: 'high_memory_usage',
            value: avgMemory,
            timestamp: DateTime.now(),
            metadata: {'threshold': 150},
          ),
        );
      }
    }
  }

  /// 에러 로그 추가
  void addErrorLog(String error, String stackTrace, {String? context}) {
    _errorLogs.add(
      ErrorLog(error: error, stackTrace: stackTrace, context: context, timestamp: DateTime.now()),
    );

    // 에러 메트릭 추가
    _metrics.add(
      MonitoringMetric(
        type: MetricType.error,
        name: 'error_count',
        value: 1.0,
        timestamp: DateTime.now(),
        metadata: {'error': error, 'context': context},
      ),
    );

    // 에러 로그 개수 제한
    if (_errorLogs.length > 500) {
      _errorLogs.removeRange(0, 250);
    }
  }

  /// 대시보드 상태 생성
  DashboardStatus getDashboardStatus() {
    final now = DateTime.now();
    final last5Minutes = now.subtract(const Duration(minutes: 5));

    final recentMetrics = _metrics.where((m) => m.timestamp.isAfter(last5Minutes)).toList();

    final recentErrors = _errorLogs.where((e) => e.timestamp.isAfter(last5Minutes)).toList();

    final recentSecurityAlerts = _securityAlerts
        .where((a) => a.timestamp.isAfter(last5Minutes))
        .toList();

    return DashboardStatus(
      isHealthy: recentErrors.isEmpty && recentSecurityAlerts.isEmpty,
      totalMetrics: _metrics.length,
      recentErrors: recentErrors.length,
      recentSecurityAlerts: recentSecurityAlerts.length,
      avgResponseTime: _calculateAverageResponseTime(recentMetrics),
      avgMemoryUsage: _calculateAverageMemoryUsage(recentMetrics),
      uptime: _calculateUptime(),
      lastUpdated: now,
    );
  }

  double _calculateAverageResponseTime(List<MonitoringMetric> metrics) {
    final apiMetrics = metrics.where((m) => m.name == 'api_response_time').toList();
    if (apiMetrics.isEmpty) return 0.0;

    return apiMetrics.map((m) => m.value).reduce((a, b) => a + b) / apiMetrics.length;
  }

  double _calculateAverageMemoryUsage(List<MonitoringMetric> metrics) {
    final memoryMetrics = metrics.where((m) => m.name == 'memory_usage').toList();
    if (memoryMetrics.isEmpty) return 0.0;

    return memoryMetrics.map((m) => m.value).reduce((a, b) => a + b) / memoryMetrics.length;
  }

  Duration _calculateUptime() {
    if (_metrics.isEmpty) return Duration.zero;

    final firstMetric = _metrics.first;
    return DateTime.now().difference(firstMetric.timestamp);
  }

  /// 대시보드 리포트 생성
  String generateDashboardReport() {
    final status = getDashboardStatus();
    final report = StringBuffer();

    report.writeln('# 📊 AI Pet Frontend - Monitoring Dashboard Report');
    report.writeln('Generated at: ${DateTime.now().toIso8601String()}');
    report.writeln('');

    report.writeln('## 🏥 Health Status');
    report.writeln('- **Overall Health**: ${status.isHealthy ? "✅ Healthy" : "❌ Issues Detected"}');
    report.writeln('- **Uptime**: ${status.uptime.inHours}h ${status.uptime.inMinutes % 60}m');
    report.writeln('- **Total Metrics**: ${status.totalMetrics}');
    report.writeln('');

    report.writeln('## 📈 Performance Metrics');
    report.writeln('- **Average Response Time**: ${status.avgResponseTime.toStringAsFixed(2)}ms');
    report.writeln('- **Average Memory Usage**: ${status.avgMemoryUsage.toStringAsFixed(2)}MB');
    report.writeln('');

    report.writeln('## 🚨 Recent Issues');
    report.writeln('- **Errors (Last 5min)**: ${status.recentErrors}');
    report.writeln('- **Security Alerts (Last 5min)**: ${status.recentSecurityAlerts}');
    report.writeln('');

    if (status.recentErrors > 0) {
      report.writeln('### Recent Error Logs');
      final recentErrors = _errorLogs
          .where((e) => e.timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 5))))
          .take(5)
          .toList();

      for (final error in recentErrors) {
        report.writeln('- **${error.timestamp.toIso8601String()}**: ${error.error}');
        if (error.context != null) {
          report.writeln('  - Context: ${error.context}');
        }
      }
      report.writeln('');
    }

    if (status.recentSecurityAlerts > 0) {
      report.writeln('### Recent Security Alerts');
      final recentAlerts = _securityAlerts
          .where((a) => a.timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 5))))
          .take(5)
          .toList();

      for (final alert in recentAlerts) {
        report.writeln('- **${alert.timestamp.toIso8601String()}**: ${alert.message}');
        report.writeln('  - Severity: ${alert.severity.name}');
        report.writeln('  - Type: ${alert.type.name}');
      }
      report.writeln('');
    }

    return report.toString();
  }

  /// 대시보드 데이터 초기화
  void clearDashboard() {
    _metrics.clear();
    _errorLogs.clear();
    _securityAlerts.clear();
    BaseLoggingService.instance.logInfo('Dashboard data cleared');
  }
}

/// 모니터링 메트릭 데이터 모델
class MonitoringMetric {
  final MetricType type;
  final String name;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const MonitoringMetric({
    required this.type,
    required this.name,
    required this.value,
    required this.timestamp,
    this.metadata = const {},
  });
}

/// 에러 로그 데이터 모델
class ErrorLog {
  final String error;
  final String stackTrace;
  final String? context;
  final DateTime timestamp;

  const ErrorLog({
    required this.error,
    required this.stackTrace,
    this.context,
    required this.timestamp,
  });
}

/// 보안 알림 데이터 모델
class SecurityAlert {
  final SecurityAlertType type;
  final String message;
  final DateTime timestamp;
  final SecuritySeverity severity;

  const SecurityAlert({
    required this.type,
    required this.message,
    required this.timestamp,
    required this.severity,
  });
}

/// 대시보드 상태 데이터 모델
class DashboardStatus {
  final bool isHealthy;
  final int totalMetrics;
  final int recentErrors;
  final int recentSecurityAlerts;
  final double avgResponseTime;
  final double avgMemoryUsage;
  final Duration uptime;
  final DateTime lastUpdated;

  const DashboardStatus({
    required this.isHealthy,
    required this.totalMetrics,
    required this.recentErrors,
    required this.recentSecurityAlerts,
    required this.avgResponseTime,
    required this.avgMemoryUsage,
    required this.uptime,
    required this.lastUpdated,
  });
}

/// 메트릭 타입 열거형
enum MetricType { performance, security, error, alert }

/// 보안 알림 타입 열거형
enum SecurityAlertType { validation, authentication, authorization, data }

/// 보안 심각도 열거형
enum SecuritySeverity { low, medium, high, critical }
