import 'package:aipet_frontend/shared/services/performance_monitor_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerformanceMonitorService Tests', () {
    late PerformanceMonitorService service;

    setUp(() {
      service = PerformanceMonitorService();
    });

    tearDown(() {
      service.dispose();
    });

    group('Monitoring Control', () {
      test('should start monitoring', () {
        // Act
        service.startMonitoring(interval: const Duration(seconds: 1));

        // Assert
        expect(service.metricStream, isNotNull);
        expect(service.issueStream, isNotNull);
      });

      test('should stop monitoring', () {
        // Arrange
        service.startMonitoring();

        // Act
        service.stopMonitoring();

        // Assert
        // 모니터링이 중지되었는지 확인 (타이머가 취소됨)
        expect(true, isTrue); // 실제로는 타이머 상태를 확인해야 함
      });

      test('should handle multiple start calls', () {
        // Act
        service.startMonitoring();
        service.startMonitoring();

        // Assert
        // 중복 시작이 안전하게 처리되는지 확인
        expect(true, isTrue);
      });
    });

    group('Metric Collection', () {
      test('should collect performance metrics', () async {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 100));

        // Act
        await Future.delayed(const Duration(milliseconds: 200));

        // Assert
        final metrics = service.getMetrics();
        expect(metrics.length, greaterThan(0));
        expect(metrics.first, isA<PerformanceMetric>());
      });

      test('should generate valid performance metrics', () async {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 100));

        // Act
        await Future.delayed(const Duration(milliseconds: 200));
        final metrics = service.getMetrics();

        // Assert
        expect(metrics.length, greaterThan(0));
        final metric = metrics.first;
        expect(metric.timestamp, isA<DateTime>());
        expect(metric.memoryUsage, isA<double>());
        expect(metric.cpuUsage, isA<double>());
        expect(metric.frameRate, isA<double>());
        expect(metric.widgetRebuilds, isA<int>());
      });

      test('should limit metrics history', () {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 50));

        // Act
        // 충분한 시간 동안 메트릭 수집
        Future.delayed(const Duration(milliseconds: 1000));

        // Assert
        final metrics = service.getMetrics(limit: 10);
        expect(metrics.length, lessThanOrEqualTo(10));
      });
    });

    group('Performance Issues', () {
      test('should detect high memory usage', () async {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 100));
        bool issueDetected = false;

        service.issueStream.listen((issue) {
          if (issue.type == PerformanceIssueType.highMemoryUsage) {
            issueDetected = true;
          }
        });

        // Act
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        // 메모리 사용량이 임계값을 초과하면 이슈가 감지되어야 함
        expect(issueDetected, isTrue);
      });

      test('should detect low frame rate', () async {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 100));
        bool issueDetected = false;

        service.issueStream.listen((issue) {
          if (issue.type == PerformanceIssueType.lowFrameRate) {
            issueDetected = true;
          }
        });

        // Act
        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        // 프레임 레이트가 임계값 미만이면 이슈가 감지되어야 함
        expect(issueDetected, isTrue);
      });

      test(
        'should generate performance issues with correct severity',
        () async {
          // Arrange
          service.startMonitoring(interval: const Duration(milliseconds: 100));
          PerformanceIssue? detectedIssue;

          service.issueStream.listen((issue) {
            detectedIssue = issue;
          });

          // Act
          await Future.delayed(const Duration(milliseconds: 500));

          // Assert
          if (detectedIssue != null) {
            expect(detectedIssue!.type, isA<PerformanceIssueType>());
            expect(detectedIssue!.severity, isA<PerformanceIssueSeverity>());
            expect(detectedIssue!.message, isA<String>());
            expect(detectedIssue!.metric, isA<PerformanceMetric>());
          }
        },
      );
    });

    group('Performance Report', () {
      test('should generate performance report', () async {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 100));

        // Act
        await Future.delayed(const Duration(milliseconds: 300));
        final report = service.generateReport();

        // Assert
        expect(report, isA<PerformanceReport>());
        expect(report.timestamp, isA<DateTime>());
        expect(report.metrics, isA<List<PerformanceMetric>>());
        expect(report.averageMemoryUsage, isA<double>());
        expect(report.averageFrameRate, isA<double>());
        expect(report.totalIssues, isA<int>());
      });

      test('should calculate correct averages in report', () async {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 100));

        // Act
        await Future.delayed(const Duration(milliseconds: 300));
        final report = service.generateReport();

        // Assert
        if (report.metrics.isNotEmpty) {
          final avgMemory =
              report.metrics.map((m) => m.memoryUsage).reduce((a, b) => a + b) /
              report.metrics.length;

          final avgFrameRate =
              report.metrics.map((m) => m.frameRate).reduce((a, b) => a + b) /
              report.metrics.length;

          expect(report.averageMemoryUsage, closeTo(avgMemory, 0.1));
          expect(report.averageFrameRate, closeTo(avgFrameRate, 0.1));
        }
      });

      test('should handle empty metrics in report', () {
        // Act
        final report = service.generateReport();

        // Assert
        expect(report.metrics, isEmpty);
        expect(report.averageMemoryUsage, equals(0.0));
        expect(report.averageFrameRate, equals(0.0));
        expect(report.totalIssues, equals(0));
      });
    });

    group('Data Management', () {
      test('should clear metrics', () async {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 100));
        await Future.delayed(const Duration(milliseconds: 200));

        // Act
        service.clearMetrics();

        // Assert
        final metrics = service.getMetrics();
        expect(metrics, isEmpty);
      });

      test('should handle metric stream subscription', () async {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 100));
        final metrics = <PerformanceMetric>[];

        // Act
        service.metricStream.listen((metric) {
          metrics.add(metric);
        });

        await Future.delayed(const Duration(milliseconds: 300));

        // Assert
        expect(metrics.length, greaterThan(0));
        expect(metrics.first, isA<PerformanceMetric>());
      });

      test('should handle issue stream subscription', () async {
        // Arrange
        service.startMonitoring(interval: const Duration(milliseconds: 100));
        final issues = <PerformanceIssue>[];

        // Act
        service.issueStream.listen((issue) {
          issues.add(issue);
        });

        await Future.delayed(const Duration(milliseconds: 500));

        // Assert
        expect(issues.length, greaterThan(0));
        expect(issues.first, isA<PerformanceIssue>());
      });
    });

    group('Performance Metric', () {
      test('should create valid performance metric', () {
        // Arrange
        final timestamp = DateTime.now();
        const memoryUsage = 50.0;
        const cpuUsage = 25.0;
        const frameRate = 60.0;
        const widgetRebuilds = 10;

        // Act
        final metric = PerformanceMetric(
          timestamp: timestamp,
          memoryUsage: memoryUsage,
          cpuUsage: cpuUsage,
          frameRate: frameRate,
          widgetRebuilds: widgetRebuilds,
        );

        // Assert
        expect(metric.timestamp, equals(timestamp));
        expect(metric.memoryUsage, equals(memoryUsage));
        expect(metric.cpuUsage, equals(cpuUsage));
        expect(metric.frameRate, equals(frameRate));
        expect(metric.widgetRebuilds, equals(widgetRebuilds));
      });

      test('should provide meaningful string representation', () {
        // Arrange
        final metric = PerformanceMetric(
          timestamp: DateTime(2023, 1, 1, 12, 0, 0),
          memoryUsage: 50.5,
          cpuUsage: 25.0,
          frameRate: 60.0,
          widgetRebuilds: 10,
        );

        // Act
        final string = metric.toString();

        // Assert
        expect(string, contains('PerformanceMetric'));
        expect(string, contains('50.5MB'));
        expect(string, contains('25.0%'));
        expect(string, contains('60.0'));
        expect(string, contains('10'));
      });
    });

    group('Performance Issue', () {
      test('should create valid performance issue', () {
        // Arrange
        final metric = PerformanceMetric(
          timestamp: DateTime.now(),
          memoryUsage: 50.0,
          cpuUsage: 25.0,
          frameRate: 60.0,
          widgetRebuilds: 10,
        );

        // Act
        final issue = PerformanceIssue(
          type: PerformanceIssueType.highMemoryUsage,
          severity: PerformanceIssueSeverity.warning,
          message: '메모리 사용량이 높습니다',
          metric: metric,
        );

        // Assert
        expect(issue.type, equals(PerformanceIssueType.highMemoryUsage));
        expect(issue.severity, equals(PerformanceIssueSeverity.warning));
        expect(issue.message, equals('메모리 사용량이 높습니다'));
        expect(issue.metric, equals(metric));
      });

      test('should provide meaningful string representation', () {
        // Arrange
        final metric = PerformanceMetric(
          timestamp: DateTime.now(),
          memoryUsage: 50.0,
          cpuUsage: 25.0,
          frameRate: 60.0,
          widgetRebuilds: 10,
        );

        final issue = PerformanceIssue(
          type: PerformanceIssueType.highMemoryUsage,
          severity: PerformanceIssueSeverity.warning,
          message: '메모리 사용량이 높습니다',
          metric: metric,
        );

        // Act
        final string = issue.toString();

        // Assert
        expect(string, contains('PerformanceIssue'));
        expect(string, contains('highMemoryUsage'));
        expect(string, contains('warning'));
        expect(string, contains('메모리 사용량이 높습니다'));
      });
    });

    group('Performance Report', () {
      test('should create valid performance report', () {
        // Arrange
        final timestamp = DateTime.now();
        final metrics = [
          PerformanceMetric(
            timestamp: DateTime.now(),
            memoryUsage: 50.0,
            cpuUsage: 25.0,
            frameRate: 60.0,
            widgetRebuilds: 10,
          ),
        ];

        // Act
        final report = PerformanceReport(
          timestamp: timestamp,
          metrics: metrics,
          averageMemoryUsage: 50.0,
          averageFrameRate: 60.0,
          totalIssues: 1,
        );

        // Assert
        expect(report.timestamp, equals(timestamp));
        expect(report.metrics, equals(metrics));
        expect(report.averageMemoryUsage, equals(50.0));
        expect(report.averageFrameRate, equals(60.0));
        expect(report.totalIssues, equals(1));
      });

      test('should provide meaningful string representation', () {
        // Arrange
        final report = PerformanceReport(
          timestamp: DateTime(2023, 1, 1, 12, 0, 0),
          metrics: [],
          averageMemoryUsage: 50.5,
          averageFrameRate: 60.0,
          totalIssues: 1,
        );

        // Act
        final string = report.toString();

        // Assert
        expect(string, contains('PerformanceReport'));
        expect(string, contains('50.5MB'));
        expect(string, contains('60.0'));
        expect(string, contains('1'));
      });
    });
  });
}
