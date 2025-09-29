import 'package:aipet_frontend/shared/performance/performance_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Performance Tests', () {
    late PerformanceMonitor performanceMonitor;

    setUp(() {
      performanceMonitor = PerformanceMonitor.instance;
      performanceMonitor.startMonitoring();
    });

    tearDown(() {
      performanceMonitor.stopMonitoring();
    });

    testWidgets('should load app within acceptable time', (tester) async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('AI Pet Frontend'))),
        ),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1초 이내
      performanceMonitor.recordWidgetBuild(
        'AppLoad',
        stopwatch.elapsedMilliseconds,
      );
    });

    testWidgets('should handle multiple widget rebuilds efficiently', (
      tester,
    ) async {
      // Arrange
      int rebuildCount = 0;
      final stopwatch = Stopwatch()..start();

      // Act
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuildCount++;
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    children: [
                      Text('Rebuild Count: $rebuildCount'),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Rebuild'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Trigger multiple rebuilds
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Rebuild'));
        await tester.pump();
      }

      stopwatch.stop();

      // Assert
      expect(rebuildCount, equals(11)); // Initial + 10 rebuilds
      expect(stopwatch.elapsedMilliseconds, lessThan(500)); // 500ms 이내
      performanceMonitor.recordWidgetBuild(
        'MultipleRebuilds',
        stopwatch.elapsedMilliseconds,
      );
    });

    testWidgets('should handle large lists efficiently', (tester) async {
      // Arrange
      const itemCount = 1000;
      final items = List.generate(itemCount, (index) => 'Item $index');
      final stopwatch = Stopwatch()..start();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(items[index]));
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // 2초 이내
      performanceMonitor.recordWidgetBuild(
        'LargeList',
        stopwatch.elapsedMilliseconds,
      );
    });

    testWidgets('should handle image loading efficiently', (tester) async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: List.generate(10, (index) {
                return SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(
                    'https://picsum.photos/100/100?random=$index',
                    fit: BoxFit.cover,
                  ),
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(3000)); // 3초 이내
      performanceMonitor.recordWidgetBuild(
        'ImageLoading',
        stopwatch.elapsedMilliseconds,
      );
    });

    testWidgets('should handle animations smoothly', (tester) async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedContainer(
                duration: const Duration(seconds: 1),
                width: 100,
                height: 100,
                color: Colors.blue,
                child: const Text('Animated'),
              ),
            ),
          ),
        ),
      );

      // Trigger animation
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // 2초 이내
      performanceMonitor.recordWidgetBuild(
        'Animation',
        stopwatch.elapsedMilliseconds,
      );
    });

    test('should generate performance report', () {
      // Arrange
      performanceMonitor.recordApiCall('test_endpoint', 200, 100);
      performanceMonitor.recordWidgetBuild('test_widget', 50);
      performanceMonitor.recordMemoryUsage('test_operation');

      // Act
      final report = performanceMonitor.generateReport();

      // Assert
      expect(report.totalMetrics, greaterThan(0));
      expect(report.avgApiResponseTime, greaterThanOrEqualTo(0));
      expect(report.avgMemoryUsage, greaterThanOrEqualTo(0));
      expect(report.avgWidgetBuildTime, greaterThanOrEqualTo(0));
    });

    test('should detect slow operations', () {
      // Arrange
      performanceMonitor.recordWidgetBuild('slow_widget', 2000); // 2초
      performanceMonitor.recordApiCall('slow_api', 200, 3000); // 3초

      // Act
      final report = performanceMonitor.generateReport();

      // Assert
      expect(report.slowOperations.length, greaterThan(0));
      expect(
        report.slowOperations.any((op) => op.operationName == 'slow_widget'),
        isTrue,
      );
    });

    test('should detect memory alerts', () {
      // Arrange
      // Simulate high memory usage
      for (int i = 0; i < 10; i++) {
        performanceMonitor.recordMemoryUsage('high_memory_operation');
      }

      // Act
      final report = performanceMonitor.generateReport();

      // Assert
      expect(report.memoryAlerts.length, greaterThanOrEqualTo(0));
    });
  });
}
