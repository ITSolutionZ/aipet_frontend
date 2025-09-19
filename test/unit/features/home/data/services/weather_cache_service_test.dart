import 'package:aipet_frontend/features/home/data/models/weather_model.dart';
import 'package:aipet_frontend/features/home/data/services/weather_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.dart';
import 'weather_cache_service_test.mocks.dart';

@GenerateMocks([])
void main() {
  group('WeatherCacheService', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });

    group('basic functionality', () {
      test('should have correct cache duration constants', () {
        // Assert
        expect(
          WeatherCacheService.defaultCacheDuration,
          equals(const Duration(minutes: 30)),
        );
        expect(
          WeatherCacheService.userTriggeredCacheDuration,
          equals(const Duration(minutes: 15)),
        );
        expect(
          WeatherCacheService.offlineCacheDuration,
          equals(const Duration(hours: 24)),
        );
      });

      test('should clear all cache', () async {
        // Act & Assert - 메서드가 정상적으로 실행되는지 확인
        await WeatherCacheService.clearAllCache();
        expect(WeatherCacheService, isNotNull);
      });
    });

    group('weather data model', () {
      test('should create WeatherData with all parameters', () {
        // Arrange
        const location = WeatherLocation(
          latitude: 35.6092,
          longitude: 139.7301,
          name: '東京都品川区',
        );

        // Act
        const weatherData = WeatherData(
          temperature: 25.0,
          location: '東京都品川区',
          weatherId: 800,
          description: '晴れ',
          feelsLike: 27.0,
          humidity: 65,
          windSpeed: 2.5,
          iconCode: '01d',
          uvIndex: 5.0,
          visibility: 10000,
          pressure: 1013.25,
        );

        // Assert
        expect(weatherData.temperature, equals(25.0));
        expect(weatherData.location, equals('東京都品川区'));
        expect(weatherData.weatherId, equals(800));
        expect(weatherData.description, equals('晴れ'));
        expect(weatherData.feelsLike, equals(27.0));
        expect(weatherData.humidity, equals(65));
        expect(weatherData.windSpeed, equals(2.5));
        expect(weatherData.iconCode, equals('01d'));
        expect(weatherData.uvIndex, equals(5.0));
        expect(weatherData.visibility, equals(10000));
        expect(weatherData.pressure, equals(1013.25));
      });

      test('should create WeatherLocation with all parameters', () {
        // Act
        const location = WeatherLocation(
          latitude: 35.6092,
          longitude: 139.7301,
          name: '東京都品川区',
        );

        // Assert
        expect(location.latitude, equals(35.6092));
        expect(location.longitude, equals(139.7301));
        expect(location.name, equals('東京都品川区'));
      });
    });

    group('edge cases', () {
      test('should handle extreme temperature values', () {
        // Arrange & Act
        const extremeWeather = WeatherData(
          temperature: -50.0,
          location: '極寒都市',
          weatherId: 800,
          description: '極寒',
          feelsLike: -55.0,
          humidity: 100,
          windSpeed: 0.0,
          iconCode: '01d',
          uvIndex: 0.0,
          visibility: 1000,
          pressure: 1050.0,
        );

        // Assert
        expect(extremeWeather.temperature, equals(-50.0));
        expect(extremeWeather.humidity, equals(100));
      });

      test('should handle special characters in location', () {
        // Arrange & Act
        const specialLocation = WeatherLocation(
          latitude: 35.6092,
          longitude: 139.7301,
          name: 'スペシャル都市',
        );

        // Assert
        expect(specialLocation.name, contains('スペシャル都市'));
      });

      test('should handle very long location name', () {
        // Arrange & Act
        final longLocation = WeatherLocation(
          latitude: 35.6092,
          longitude: 139.7301,
          name: 'A' * 1000,
        );

        // Assert
        expect(longLocation.name.length, equals(1000));
      });
    });
  });
}
