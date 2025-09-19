import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// 성능 모니터링 서비스
///
/// 앱의 성능을 실시간으로 모니터링하고 성능 지표를 수집합니다.
class PerformanceMonitorService {
  static final PerformanceMonitorService _instance =
      PerformanceMonitorService._internal();
  factory PerformanceMonitorService() => _instance;
  PerformanceMonitorService._internal();

  Timer? _monitoringTimer;
  final List<PerformanceMetric> _metrics = [];
  final StreamController<PerformanceMetric> _metricController =
      StreamController<PerformanceMetric>.broadcast();

  /// 성능 메트릭 스트림
  Stream<PerformanceMetric> get metricStream => _metricController.stream;

  /// 성능 모니터링 시작
  void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
    // 테스트 환경에서는 성능 모니터링을 비활성화
    if (kDebugMode && !_isTestEnvironment()) {
      if (_monitoringTimer != null) {
        _monitoringTimer!.cancel();
      }

      _monitoringTimer = Timer.periodic(interval, (timer) {
        _collectMetrics();
      });

      print('성능 모니터링 시작됨 (간격: ${interval.inSeconds}초)');
    }
  }

  /// 테스트 환경인지 확인
  bool _isTestEnvironment() {
    try {
      // Flutter 테스트 환경에서는 이 값이 true
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (e) {
      return false;
    }
  }

  /// 성능 모니터링 중지
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    if (kDebugMode) {
      print('성능 모니터링 중지됨');
    }
  }

  /// 스트림 컨트롤러가 닫혔는지 확인
  bool get _isDisposed =>
      _metricController.isClosed || _issueController.isClosed;

  /// 성능 메트릭 수집
  void _collectMetrics() {
    // 스트림 컨트롤러가 닫혔으면 수집 중단
    if (_isDisposed) return;

    final metric = PerformanceMetric(
      timestamp: DateTime.now(),
      memoryUsage: _getMemoryUsage(),
      cpuUsage: _getCpuUsage(),
      frameRate: _getFrameRate(),
      widgetRebuilds: _getWidgetRebuilds(),
    );

    _metrics.add(metric);

    try {
      _metricController.add(metric);
    } catch (e) {
      if (kDebugMode) {
        print('메트릭 스트림 추가 실패: $e');
      }
    }

    // 성능 이슈 감지
    _detectPerformanceIssues(metric);

    if (kDebugMode) {
      // print('성능 메트릭 수집: ${metric.toString()}');
    }
  }

  /// 메모리 사용량 측정
  double _getMemoryUsage() {
    try {
      // Flutter의 메모리 정보 가져오기 (시뮬레이션)
      // 실제 구현에서는 플랫폼별 메모리 측정 API 사용
      return 50.0 +
          (DateTime.now().millisecondsSinceEpoch % 20); // 50-70MB 시뮬레이션
    } catch (e) {
      if (kDebugMode) {
        print('메모리 사용량 측정 실패: $e');
      }
    }
    return 0.0;
  }

  /// CPU 사용량 측정 (시뮬레이션)
  double _getCpuUsage() {
    // 실제 CPU 사용량 측정은 플랫폼별 구현이 필요
    // 현재는 시뮬레이션된 값 반환
    return 0.0;
  }

  /// 프레임 레이트 측정
  double _getFrameRate() {
    try {
      // Flutter의 프레임 정보 가져오기 (시뮬레이션)
      // 실제 구현에서는 Flutter의 프레임 측정 API 사용
      return 55.0 +
          (DateTime.now().millisecondsSinceEpoch % 10); // 55-65fps 시뮬레이션
    } catch (e) {
      if (kDebugMode) {
        print('프레임 레이트 측정 실패: $e');
      }
    }
    return 60.0;
  }

  /// 위젯 리빌드 횟수 측정 (시뮬레이션)
  int _getWidgetRebuilds() {
    // 실제 위젯 리빌드 횟수 측정은 복잡한 구현이 필요
    // 현재는 시뮬레이션된 값 반환
    return 0;
  }

  /// 성능 이슈 감지
  void _detectPerformanceIssues(PerformanceMetric metric) {
    final issues = <PerformanceIssue>[];

    // 메모리 사용량 이슈 감지
    if (metric.memoryUsage > 100) {
      // 100MB 이상
      issues.add(
        PerformanceIssue(
          type: PerformanceIssueType.highMemoryUsage,
          severity: PerformanceIssueSeverity.warning,
          message: '메모리 사용량이 높습니다: ${metric.memoryUsage.toStringAsFixed(1)}MB',
          metric: metric,
        ),
      );
    }

    // 프레임 레이트 이슈 감지
    if (metric.frameRate < 30) {
      // 30fps 미만
      issues.add(
        PerformanceIssue(
          type: PerformanceIssueType.lowFrameRate,
          severity: PerformanceIssueSeverity.critical,
          message: '프레임 레이트가 낮습니다: ${metric.frameRate.toStringAsFixed(1)}fps',
          metric: metric,
        ),
      );
    }

    // 이슈가 있으면 알림
    for (final issue in issues) {
      _reportPerformanceIssue(issue);
    }
  }

  /// 성능 이슈 리포트
  void _reportPerformanceIssue(PerformanceIssue issue) {
    if (kDebugMode) {
      print('🚨 성능 이슈 감지: ${issue.message}');
    }

    // 성능 이슈 스트림으로 전송
    try {
      _issueController.add(issue);
    } catch (e) {
      if (kDebugMode) {
        print('이슈 스트림 추가 실패: $e');
      }
    }
  }

  final StreamController<PerformanceIssue> _issueController =
      StreamController<PerformanceIssue>.broadcast();

  /// 성능 이슈 스트림
  Stream<PerformanceIssue> get issueStream => _issueController.stream;

  /// 성능 메트릭 히스토리 가져오기
  List<PerformanceMetric> getMetrics({int limit = 100}) {
    if (_metrics.length <= limit) {
      return List.from(_metrics);
    }
    return _metrics.sublist(_metrics.length - limit);
  }

  /// 성능 메트릭 초기화
  void clearMetrics() {
    _metrics.clear();
  }

  /// 성능 리포트 생성
  PerformanceReport generateReport() {
    if (_metrics.isEmpty) {
      return PerformanceReport(
        timestamp: DateTime.now(),
        metrics: [],
        averageMemoryUsage: 0.0,
        averageFrameRate: 0.0,
        totalIssues: 0,
      );
    }

    final avgMemoryUsage =
        _metrics.map((m) => m.memoryUsage).reduce((a, b) => a + b) /
        _metrics.length;

    final avgFrameRate =
        _metrics.map((m) => m.frameRate).reduce((a, b) => a + b) /
        _metrics.length;

    return PerformanceReport(
      timestamp: DateTime.now(),
      metrics: List.from(_metrics),
      averageMemoryUsage: avgMemoryUsage,
      averageFrameRate: avgFrameRate,
      totalIssues: _metrics
          .where((m) => m.memoryUsage > 100 || m.frameRate < 30)
          .length,
    );
  }

  /// 리소스 정리
  void dispose() {
    stopMonitoring();
    _metricController.close();
    _issueController.close();
  }
}

/// 성능 메트릭 클래스
class PerformanceMetric {
  final DateTime timestamp;
  final double memoryUsage; // MB
  final double cpuUsage; // %
  final double frameRate; // fps
  final int widgetRebuilds;

  const PerformanceMetric({
    required this.timestamp,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.frameRate,
    required this.widgetRebuilds,
  });

  @override
  String toString() {
    return 'PerformanceMetric('
        'timestamp: $timestamp, '
        'memory: ${memoryUsage.toStringAsFixed(1)}MB, '
        'cpu: ${cpuUsage.toStringAsFixed(1)}%, '
        'fps: ${frameRate.toStringAsFixed(1)}, '
        'rebuilds: $widgetRebuilds)';
  }
}

/// 성능 이슈 타입
enum PerformanceIssueType {
  highMemoryUsage,
  lowFrameRate,
  highCpuUsage,
  excessiveWidgetRebuilds,
}

/// 성능 이슈 심각도
enum PerformanceIssueSeverity { info, warning, critical }

/// 성능 이슈 클래스
class PerformanceIssue {
  final PerformanceIssueType type;
  final PerformanceIssueSeverity severity;
  final String message;
  final PerformanceMetric metric;

  const PerformanceIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.metric,
  });

  @override
  String toString() {
    return 'PerformanceIssue('
        'type: $type, '
        'severity: $severity, '
        'message: $message)';
  }
}

/// 성능 리포트 클래스
class PerformanceReport {
  final DateTime timestamp;
  final List<PerformanceMetric> metrics;
  final double averageMemoryUsage;
  final double averageFrameRate;
  final int totalIssues;

  const PerformanceReport({
    required this.timestamp,
    required this.metrics,
    required this.averageMemoryUsage,
    required this.averageFrameRate,
    required this.totalIssues,
  });

  @override
  String toString() {
    return 'PerformanceReport('
        'timestamp: $timestamp, '
        'avgMemory: ${averageMemoryUsage.toStringAsFixed(1)}MB, '
        'avgFps: ${averageFrameRate.toStringAsFixed(1)}, '
        'issues: $totalIssues)';
  }
}
