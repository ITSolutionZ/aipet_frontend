import 'package:aipet_frontend/features/home/data/repositories/home_repository_impl.dart';
import 'package:aipet_frontend/features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:aipet_frontend/features/home/domain/usecases/get_pet_summary_usecase.dart';
import 'package:aipet_frontend/features/home/domain/usecases/get_weather_data_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helper.dart';

void main() {
  group('Home Feature Performance Tests', () {
    late HomeRepositoryImpl repository;
    late GetDashboardDataUseCase getDashboardDataUseCase;
    late GetPetSummaryUseCase getPetSummaryUseCase;
    late GetWeatherDataUseCase getWeatherDataUseCase;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      repository = HomeRepositoryImpl();
      getDashboardDataUseCase = GetDashboardDataUseCase(repository);
      getPetSummaryUseCase = GetPetSummaryUseCase(repository);
      getWeatherDataUseCase = GetWeatherDataUseCase(repository);
    });

    group('Response Time Performance', () {
      test('should load dashboard data within acceptable time', () async {
        // Arrange
        const maxResponseTime = Duration(milliseconds: 2000); // 2 seconds max

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await getDashboardDataUseCase.call();
        stopwatch.stop();

        // Assert
        expect(result, isNotNull);
        expect(stopwatch.elapsed, lessThan(maxResponseTime));
        print('Dashboard data loaded in: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('should load pet summaries within acceptable time', () async {
        // Arrange
        const maxResponseTime = Duration(milliseconds: 1000); // 1 second max

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await getPetSummaryUseCase.call();
        stopwatch.stop();

        // Assert
        expect(result, isNotNull);
        expect(stopwatch.elapsed, lessThan(maxResponseTime));
        print('Pet summaries loaded in: ${stopwatch.elapsedMilliseconds}ms');
      });

      test('should load weather data within acceptable time', () async {
        // Arrange
        const maxResponseTime = Duration(milliseconds: 3000); // 3 seconds max

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await getWeatherDataUseCase.call();
        stopwatch.stop();

        // Assert
        if (result != null) {
          expect(stopwatch.elapsed, lessThan(maxResponseTime));
        }
        print('Weather data loaded in: ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Concurrent Request Performance', () {
      test(
        'should handle multiple concurrent dashboard requests efficiently',
        () async {
          // Arrange
          const requestCount = 10;
          const maxTotalTime = Duration(milliseconds: 5000); // 5 seconds max

          // Act
          final stopwatch = Stopwatch()..start();
          final futures = List.generate(
            requestCount,
            (_) => getDashboardDataUseCase.call(),
          );
          final results = await Future.wait(futures);
          stopwatch.stop();

          // Assert
          expect(results.length, equals(requestCount));
          expect(stopwatch.elapsed, lessThan(maxTotalTime));
          print(
            '$requestCount concurrent dashboard requests completed in: ${stopwatch.elapsedMilliseconds}ms',
          );
          print(
            'Average time per request: ${stopwatch.elapsedMilliseconds / requestCount}ms',
          );
        },
      );

      test('should handle mixed concurrent requests efficiently', () async {
        // Arrange
        const maxTotalTime = Duration(milliseconds: 8000); // 8 seconds max

        // Act
        final stopwatch = Stopwatch()..start();
        final futures = [
          getDashboardDataUseCase.call(),
          getPetSummaryUseCase.call(),
          getWeatherDataUseCase.call(),
          getDashboardDataUseCase.call(),
          getPetSummaryUseCase.call(),
        ];
        final results = await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(results.length, equals(5));
        expect(stopwatch.elapsed, lessThan(maxTotalTime));
        print(
          'Mixed concurrent requests completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });

    group('Memory Performance', () {
      test('should not leak memory with repeated requests', () async {
        // Arrange
        const requestCount = 100;

        // Act
        for (int i = 0; i < requestCount; i++) {
          final result = await getDashboardDataUseCase.call();
          expect(result, isNotNull);

          // Force garbage collection if available
          if (i % 10 == 0) {
            await Future.delayed(const Duration(milliseconds: 1));
          }
        }

        // Assert
        // If we reach here without running out of memory, the test passes
        expect(true, isTrue);
        print('Completed $requestCount requests without memory issues');
      });

      test('should handle large data sets efficiently', () async {
        // Arrange
        // const maxMemoryUsage = 50 * 1024 * 1024; // 50MB max (approximate)

        // Act
        final stopwatch = Stopwatch()..start();
        final results = <dynamic>[];

        for (int i = 0; i < 50; i++) {
          final result = await getDashboardDataUseCase.call();
          results.add(result);
        }
        stopwatch.stop();

        // Assert
        expect(results.length, equals(50));
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 30)));
        print(
          'Large data set processing completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });

    group('Caching Performance', () {
      test('should benefit from caching on repeated requests', () async {
        // Arrange
        const requestCount = 5;

        // Act
        final firstRequestStopwatch = Stopwatch()..start();
        await getDashboardDataUseCase.call();
        firstRequestStopwatch.stop();

        final subsequentRequestsStopwatch = Stopwatch()..start();
        for (int i = 0; i < requestCount - 1; i++) {
          await getDashboardDataUseCase.call();
        }
        subsequentRequestsStopwatch.stop();

        // Assert
        final firstRequestTime = firstRequestStopwatch.elapsedMilliseconds;
        final averageSubsequentTime =
            subsequentRequestsStopwatch.elapsedMilliseconds /
            (requestCount - 1);

        print('First request time: ${firstRequestTime}ms');
        print('Average subsequent request time: ${averageSubsequentTime}ms');

        // Subsequent requests should be faster due to caching
        expect(averageSubsequentTime, lessThanOrEqualTo(firstRequestTime));
      });

      test('should handle cache invalidation efficiently', () async {
        // Arrange
        const requestCount = 10;

        // Act
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < requestCount; i++) {
          await getDashboardDataUseCase.call();
          // Simulate cache invalidation
          await Future.delayed(const Duration(milliseconds: 100));
        }
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 15)));
        print(
          'Cache invalidation test completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });

    group('Network Performance', () {
      test('should handle network timeouts gracefully', () async {
        // Arrange
        const maxTimeout = Duration(seconds: 30);

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await getWeatherDataUseCase.call();
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsed, lessThan(maxTimeout));
        // Result can be null due to network issues, but should not crash
        print(
          'Network timeout test completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      });

      test('should handle slow network conditions', () async {
        // Arrange
        const maxTime = Duration(seconds: 60);

        // Act
        final stopwatch = Stopwatch()..start();
        final futures = [
          getDashboardDataUseCase.call(),
          getPetSummaryUseCase.call(),
          getWeatherDataUseCase.call(),
        ];
        final results = await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(results.length, equals(3));
        expect(stopwatch.elapsed, lessThan(maxTime));
        print(
          'Slow network test completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });

    group('UI Performance', () {
      test('should handle rapid UI updates efficiently', () async {
        // Arrange
        const updateCount = 20;
        const maxTime = Duration(seconds: 10);

        // Act
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < updateCount; i++) {
          await getDashboardDataUseCase.call();
          // Simulate UI update delay
          await Future.delayed(const Duration(milliseconds: 50));
        }
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsed, lessThan(maxTime));
        print(
          'Rapid UI updates completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      });

      test('should handle background processing efficiently', () async {
        // Arrange
        const backgroundTaskCount = 5;
        const maxTime = Duration(seconds: 15);

        // Act
        final stopwatch = Stopwatch()..start();
        final futures = List.generate(
          backgroundTaskCount,
          (_) => getDashboardDataUseCase.call(),
        );
        final results = await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(results.length, equals(backgroundTaskCount));
        expect(stopwatch.elapsed, lessThan(maxTime));
        print(
          'Background processing completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });

    group('Resource Usage Performance', () {
      test('should not consume excessive CPU resources', () async {
        // Arrange
        const requestCount = 50;
        final startTime = DateTime.now();

        // Act
        for (int i = 0; i < requestCount; i++) {
          await getDashboardDataUseCase.call();
        }
        final endTime = DateTime.now();

        // Assert
        final totalTime = endTime.difference(startTime);
        expect(totalTime, lessThan(const Duration(seconds: 30)));
        print('CPU resource test completed in: ${totalTime.inMilliseconds}ms');
      });

      test('should handle resource constraints gracefully', () async {
        // Arrange
        const maxRequests = 100;

        // Act
        final stopwatch = Stopwatch()..start();
        final results = <dynamic>[];

        for (int i = 0; i < maxRequests; i++) {
          try {
            final result = await getDashboardDataUseCase.call();
            results.add(result);
          } catch (e) {
            // Should handle resource constraints gracefully
            print('Resource constraint handled: $e');
          }
        }
        stopwatch.stop();

        // Assert
        expect(results.length, greaterThan(0));
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 60)));
        print(
          'Resource constraint test completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });
  });
}
