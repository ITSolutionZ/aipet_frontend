import 'dart:async';
import 'dart:io';

import 'package:aipet_frontend/shared/security/environment_config.dart';
import 'package:flutter/foundation.dart';

/// 📊 성능 모니터링 시스템
///
/// 앱의 성능을 실시간으로 모니터링하고 최적화합니다.
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();

  PerformanceMonitor._();

  Timer? _monitoringTimer;
  final List<PerformanceMetric> _metrics = [];
  final Map<String, Stopwatch> _activeTimers = {};

  /// 모니터링 시작
  void startMonitoring() {
    if (!EnvironmentConfig.isPerformanceMonitoringEnabled) return;

    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (_) => _collectMetrics());
  }

  /// 모니터링 중지
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// 타이머 시작
  void startTimer(String operationName) {
    if (!EnvironmentConfig.isPerformanceMonitoringEnabled) return;

    _activeTimers[operationName] = Stopwatch()..start();
  }

  /// 타이머 종료 및 메트릭 기록
  void endTimer(String operationName, {Map<String, dynamic>? metadata}) {
    if (!EnvironmentConfig.isPerformanceMonitoringEnabled) return;

    final timer = _activeTimers.remove(operationName);
    if (timer != null) {
      final duration = timer.elapsedMilliseconds;
      _recordMetric(
        PerformanceMetric(
          operationName: operationName,
          duration: duration,
          timestamp: DateTime.now(),
          metadata: metadata ?? {},
        ),
      );
    }
  }

  /// 메모리 사용량 측정
  void recordMemoryUsage(String operationName) {
    if (!EnvironmentConfig.isPerformanceMonitoringEnabled) return;

    try {
      final memoryUsage = _getCurrentMemoryUsage();
      _recordMetric(
        PerformanceMetric(
          operationName: operationName,
          duration: 0,
          timestamp: DateTime.now(),
          metadata: {'memoryUsage': memoryUsage, 'type': 'memory'},
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Memory usage measurement failed: $e');
      }
    }
  }

  /// API 호출 성능 측정
  void recordApiCall(String endpoint, int statusCode, int duration, {String? error}) {
    if (!EnvironmentConfig.isPerformanceMonitoringEnabled) return;

    _recordMetric(
      PerformanceMetric(
        operationName: 'api_call',
        duration: duration,
        timestamp: DateTime.now(),
        metadata: {'endpoint': endpoint, 'statusCode': statusCode, 'error': error, 'type': 'api'},
      ),
    );
  }

  /// 위젯 빌드 성능 측정
  void recordWidgetBuild(String widgetName, int duration) {
    if (!EnvironmentConfig.isPerformanceMonitoringEnabled) return;

    _recordMetric(
      PerformanceMetric(
        operationName: 'widget_build',
        duration: duration,
        timestamp: DateTime.now(),
        metadata: {'widgetName': widgetName, 'type': 'widget'},
      ),
    );
  }

  /// 메트릭 기록
  void _recordMetric(PerformanceMetric metric) {
    _metrics.add(metric);

    // 메트릭 개수 제한 (메모리 절약)
    if (_metrics.length > 1000) {
      _metrics.removeRange(0, 200);
    }
  }

  /// 주기적 메트릭 수집
  void _collectMetrics() {
    recordMemoryUsage('periodic_memory_check');

    // 메모리 사용량이 임계치를 초과하면 최적화 실행
    final memoryUsage = _getCurrentMemoryUsage();
    if (memoryUsage > 0.8) {
      _performMemoryOptimization();
    }
  }

  /// 현재 메모리 사용량 계산
  double _getCurrentMemoryUsage() {
    try {
      final processInfo = ProcessInfo.currentRss;
      // 실제 메모리 사용량 계산 (MB 단위)
      return processInfo / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  /// 메모리 최적화 실행
  void _performMemoryOptimization() {
    if (kDebugMode) {
      debugPrint('Performing memory optimization...');
    }

    // 오래된 메트릭 정리
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 1));
    _metrics.removeWhere((metric) => metric.timestamp.isBefore(cutoffTime));

    // 가비지 컬렉션 강제 실행 (가능한 경우)
    if (kDebugMode) {
      // 디버그 모드에서만 가비지 컬렉션 힌트 제공
      debugPrint('Memory optimization completed');
    }
  }

  /// 성능 리포트 생성
  PerformanceReport generateReport() {
    final now = DateTime.now();
    final lastHour = now.subtract(const Duration(hours: 1));

    // 최근 1시간 메트릭 필터링
    final recentMetrics = _metrics.where((metric) => metric.timestamp.isAfter(lastHour)).toList();

    // 평균 응답 시간 계산
    final apiMetrics = recentMetrics.where((metric) => metric.metadata['type'] == 'api').toList();

    final avgApiResponseTime = apiMetrics.isNotEmpty
        ? apiMetrics.map((m) => m.duration).reduce((a, b) => a + b) / apiMetrics.length
        : 0.0;

    // 메모리 사용량 통계
    final memoryMetrics = recentMetrics
        .where((metric) => metric.metadata['type'] == 'memory')
        .toList();

    final avgMemoryUsage = memoryMetrics.isNotEmpty
        ? memoryMetrics.map((m) => m.metadata['memoryUsage'] as double).reduce((a, b) => a + b) /
              memoryMetrics.length
        : 0.0;

    // 위젯 빌드 성능
    final widgetMetrics = recentMetrics
        .where((metric) => metric.metadata['type'] == 'widget')
        .toList();

    final avgWidgetBuildTime = widgetMetrics.isNotEmpty
        ? widgetMetrics.map((m) => m.duration).reduce((a, b) => a + b) / widgetMetrics.length
        : 0.0;

    return PerformanceReport(
      timestamp: now,
      totalMetrics: recentMetrics.length,
      avgApiResponseTime: avgApiResponseTime,
      avgMemoryUsage: avgMemoryUsage,
      avgWidgetBuildTime: avgWidgetBuildTime,
      slowOperations: _getSlowOperations(recentMetrics),
      memoryAlerts: _getMemoryAlerts(memoryMetrics),
    );
  }

  /// 느린 작업 식별
  List<SlowOperation> _getSlowOperations(List<PerformanceMetric> metrics) {
    const slowThreshold = 1000; // 1초

    return metrics
        .where((metric) => metric.duration > slowThreshold)
        .map(
          (metric) => SlowOperation(
            operationName: metric.operationName,
            duration: metric.duration,
            timestamp: metric.timestamp,
            metadata: metric.metadata,
          ),
        )
        .toList();
  }

  /// 메모리 알림 식별
  List<MemoryAlert> _getMemoryAlerts(List<PerformanceMetric> memoryMetrics) {
    const memoryThreshold = 100.0; // 100MB

    return memoryMetrics
        .where((metric) => (metric.metadata['memoryUsage'] as double) > memoryThreshold)
        .map(
          (metric) => MemoryAlert(
            memoryUsage: metric.metadata['memoryUsage'] as double,
            timestamp: metric.timestamp,
          ),
        )
        .toList();
  }

  /// 성능 통계 출력 (디버그용)
  void printPerformanceStats() {
    if (!kDebugMode) return;

    final report = generateReport();
    debugPrint('=== Performance Report ===');
    debugPrint('Total Metrics: ${report.totalMetrics}');
    debugPrint('Avg API Response Time: ${report.avgApiResponseTime.toStringAsFixed(2)}ms');
    debugPrint('Avg Memory Usage: ${report.avgMemoryUsage.toStringAsFixed(2)}MB');
    debugPrint('Avg Widget Build Time: ${report.avgWidgetBuildTime.toStringAsFixed(2)}ms');
    debugPrint('Slow Operations: ${report.slowOperations.length}');
    debugPrint('Memory Alerts: ${report.memoryAlerts.length}');
  }
}

/// 성능 메트릭 데이터 클래스
class PerformanceMetric {
  final String operationName;
  final int duration; // milliseconds
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });
}

/// 성능 리포트 데이터 클래스
class PerformanceReport {
  final DateTime timestamp;
  final int totalMetrics;
  final double avgApiResponseTime;
  final double avgMemoryUsage;
  final double avgWidgetBuildTime;
  final List<SlowOperation> slowOperations;
  final List<MemoryAlert> memoryAlerts;

  const PerformanceReport({
    required this.timestamp,
    required this.totalMetrics,
    required this.avgApiResponseTime,
    required this.avgMemoryUsage,
    required this.avgWidgetBuildTime,
    required this.slowOperations,
    required this.memoryAlerts,
  });
}

/// 느린 작업 데이터 클래스
class SlowOperation {
  final String operationName;
  final int duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const SlowOperation({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });
}

/// 메모리 알림 데이터 클래스
class MemoryAlert {
  final double memoryUsage;
  final DateTime timestamp;

  const MemoryAlert({required this.memoryUsage, required this.timestamp});
}
