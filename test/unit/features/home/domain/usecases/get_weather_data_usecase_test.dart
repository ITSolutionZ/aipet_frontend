import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:aipet_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:aipet_frontend/features/home/domain/usecases/get_weather_data_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_helper.dart';
import 'get_weather_data_usecase_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  group('GetWeatherDataUseCase', () {
    late GetWeatherDataUseCase useCase;
    late MockHomeRepository mockRepository;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockRepository = MockHomeRepository();
      useCase = GetWeatherDataUseCase(mockRepository);
    });

    group('call method', () {
      test('should return weather data successfully', () async {
        // Arrange
        const expectedWeather = WeatherEntity(
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

        when(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).thenAnswer((_) async => expectedWeather);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, equals(expectedWeather));
        verify(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).called(1);
      });

      test('should return weather data with location parameter', () async {
        // Arrange
        const location = WeatherLocationEntity(
          latitude: 35.6092,
          longitude: 139.7301,
          name: '東京都品川区',
        );

        const expectedWeather = WeatherEntity(
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

        when(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).thenAnswer((_) async => expectedWeather);

        // Act
        final result = await useCase.call(location: location);

        // Assert
        expect(result, equals(expectedWeather));
        verify(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).called(1);
      });

      test('should return weather data with userTriggered parameter', () async {
        // Arrange
        const expectedWeather = WeatherEntity(
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

        when(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).thenAnswer((_) async => expectedWeather);

        // Act
        final result = await useCase.call(userTriggered: true);

        // Assert
        expect(result, equals(expectedWeather));
        verify(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).called(1);
      });

      test('should return null when no weather data', () async {
        // Arrange
        when(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).thenAnswer((_) async => null);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isNull);
        verify(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).called(1);
      });

      test('should handle repository errors', () async {
        // Arrange
        when(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).thenThrow(Exception('Repository error'));

        // Act & Assert
        expect(() => useCase.call(), throwsException);
        verify(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).called(1);
      });
    });

    group('edge cases', () {
      test('should handle extreme weather data', () async {
        // Arrange
        const extremeWeather = WeatherEntity(
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

        when(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).thenAnswer((_) async => extremeWeather);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isNotNull);
        expect(result!.temperature, equals(-50.0));
        expect(result.humidity, equals(100));
      });

      test('should handle special characters in location', () async {
        // Arrange
        const specialWeather = WeatherEntity(
          temperature: 25.0,
          location: 'スペシャル都市',
          weatherId: 800,
          description: 'スペシャル天気',
          feelsLike: 27.0,
          humidity: 65,
          windSpeed: 2.5,
          iconCode: '01d',
          uvIndex: 5.0,
          visibility: 10000,
          pressure: 1013.25,
        );

        when(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).thenAnswer((_) async => specialWeather);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isNotNull);
        expect(result!.location, contains('スペシャル都市'));
        expect(result.description, contains('スペシャル天気'));
      });

      test('should handle very long location and description', () async {
        // Arrange
        final longWeather = WeatherEntity(
          temperature: 25.0,
          location: 'A' * 1000,
          weatherId: 800,
          description: 'B' * 1000,
          feelsLike: 27.0,
          humidity: 65,
          windSpeed: 2.5,
          iconCode: '01d',
          uvIndex: 5.0,
          visibility: 10000,
          pressure: 1013.25,
        );

        when(
          mockRepository.getCurrentWeather(
            location: anyNamed('location'),
            userTriggered: anyNamed('userTriggered'),
          ),
        ).thenAnswer((_) async => longWeather);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isNotNull);
        expect(result!.location.length, equals(1000));
        expect(result.description.length, equals(1000));
      });
    });
  });
}
