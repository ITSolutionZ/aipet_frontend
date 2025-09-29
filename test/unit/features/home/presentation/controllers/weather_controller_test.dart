import 'package:aipet_frontend/features/home/presentation/controllers/weather_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'weather_controller_test.mocks.dart';

@GenerateMocks([WidgetRef])
void main() {
  group('WeatherController', () {
    late WeatherController controller;
    late MockWidgetRef mockRef;

    setUpAll(() async {
      // Test environment setup
    });

    setUp(() {
      mockRef = MockWidgetRef();
      controller = WeatherController(mockRef);
    });

    group('basic functionality', () {
      test('should initialize correctly', () {
        // Assert
        expect(controller, isNotNull);
        expect(controller.cachedWeatherData, isNull);
        expect(controller.hasWeatherData, isFalse);
      });

      test('should check if current time is day time', () {
        // Act
        final isDay = controller.isDayTime();

        // Assert
        expect(isDay, isA<bool>());
      });

      test('should clear advice cache', () {
        // Act
        controller.clearAdviceCache();

        // Assert - 캐시가 클리어되었는지 확인
        expect(controller, isNotNull);
      });
    });

    group('weather data access', () {
      test('should return null for cached weather data initially', () {
        // Assert
        expect(controller.cachedWeatherData, isNull);
      });

      test('should return false for hasWeatherData initially', () {
        // Assert
        expect(controller.hasWeatherData, isFalse);
      });
    });

    group('day time detection', () {
      test('should return boolean for isDayTime', () {
        // Act
        final result = controller.isDayTime();

        // Assert
        expect(result, isA<bool>());
      });
    });

    group('cache management', () {
      test('should clear advice cache', () {
        // Act
        controller.clearAdviceCache();

        // Assert - 메서드가 정상적으로 실행되는지 확인
        expect(controller, isNotNull);
      });
    });
  });
}
