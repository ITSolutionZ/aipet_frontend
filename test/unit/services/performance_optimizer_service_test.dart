import 'package:aipet_frontend/shared/services/performance_optimizer_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PerformanceOptimizerService Tests', () {
    late PerformanceOptimizerService service;

    setUp(() {
      service = PerformanceOptimizerService();
    });

    tearDown(() {
      service.dispose();
    });

    test('should initialize service', () async {
      // Act
      await service.initialize();

      // Assert
      expect(service, isNotNull);
    });

    test('should get performance stats', () {
      // Act
      final stats = service.getPerformanceStats();

      // Assert
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('memoryUsage'), isTrue);
      expect(stats.containsKey('memoryHistory'), isTrue);
      expect(stats.containsKey('imageCacheSize'), isTrue);
      expect(stats.containsKey('imageCacheSizeBytes'), isTrue);
      expect(stats.containsKey('isAnimationOptimized'), isTrue);
    });

    test('should get memory usage history', () {
      // Act
      final history = service.getMemoryUsageHistory();

      // Assert
      expect(history, isA<List<double>>());
    });

    test('should calculate average memory usage', () {
      // Act
      final average = service.getAverageMemoryUsage();

      // Assert
      expect(average, isA<double>());
      expect(average >= 0.0, isTrue);
    });

    test('should analyze memory usage trend', () {
      // Act
      final trend = service.getMemoryUsageTrend();

      // Assert
      expect(trend, isA<String>());
      expect(['increasing', 'decreasing', 'stable'], contains(trend));
    });

    test('should perform manual optimization', () async {
      // Act & Assert
      expect(() async {
        await service.performManualOptimization();
      }, returnsNormally);
    });
  });
}
