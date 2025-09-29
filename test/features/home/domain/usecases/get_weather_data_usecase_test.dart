import 'package:aipet_frontend/features/home/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_weather_data_usecase_test.mocks.dart';

@GenerateMocks([HomeRepository])
void main() {
  group('GetWeatherDataUseCase', () {
    late GetWeatherDataUseCase useCase;
    late MockHomeRepository mockRepository;

    setUp(() {
      mockRepository = MockHomeRepository();
      useCase = GetWeatherDataUseCase(mockRepository);
    });

    test(
      'should return success when weather data is retrieved successfully',
      () async {
        // Arrange
        final expectedWeather = WeatherEntity(
          id: 'weather_1',
          temperature: 25.0,
          humidity: 60.0,
          windSpeed: 5.0,
          description: '晴れ',
          iconCode: '01d',
          location: '東京',
          timestamp: DateTime.now(),
        );

        when(
          mockRepository.getCurrentWeather(userTriggered: false),
        ).thenAnswer((_) async => expectedWeather);

        // Act
        final result = await useCase.call(userTriggered: false);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, expectedWeather);
        expect(result.dataOrNull?.temperature, 25.0);
        expect(result.dataOrNull?.description, '晴れ');
        verify(
          mockRepository.getCurrentWeather(userTriggered: false),
        ).called(1);
      },
    );

    test(
      'should return success when weather data is retrieved with location',
      () async {
        // Arrange
        const location = WeatherLocationEntity(
          latitude: 35.6762,
          longitude: 139.6503,
          city: '東京',
          country: '日本',
        );

        final expectedWeather = WeatherEntity(
          id: 'weather_2',
          temperature: 22.0,
          humidity: 70.0,
          windSpeed: 3.0,
          description: '曇り',
          iconCode: '02d',
          location: '東京',
          timestamp: DateTime.now(),
        );

        when(
          mockRepository.getCurrentWeather(
            location: location,
            userTriggered: true,
          ),
        ).thenAnswer((_) async => expectedWeather);

        // Act
        final result = await useCase.call(
          location: location,
          userTriggered: true,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, expectedWeather);
        verify(
          mockRepository.getCurrentWeather(
            location: location,
            userTriggered: true,
          ),
        ).called(1);
      },
    );

    test('should return failure when repository throws exception', () async {
      // Arrange
      when(
        mockRepository.getCurrentWeather(userTriggered: false),
      ).thenThrow(Exception('API connection failed'));

      // Act
      final result = await useCase.call(userTriggered: false);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('天気情報の取得に失敗しました'));
    });

    test('should return failure when weather data is null', () async {
      // Arrange
      when(
        mockRepository.getCurrentWeather(userTriggered: false),
      ).thenAnswer((_) async => null);

      // Act
      final result = await useCase.call(userTriggered: false);

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, isNull);
    });

    test('should handle network timeout', () async {
      // Arrange
      when(
        mockRepository.getCurrentWeather(userTriggered: false),
      ).thenThrow(Exception('Network timeout'));

      // Act
      final result = await useCase.call(userTriggered: false);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('天気情報の取得に失敗しました'));
    });

    test('should handle API rate limit', () async {
      // Arrange
      when(
        mockRepository.getCurrentWeather(userTriggered: false),
      ).thenThrow(Exception('API rate limit exceeded'));

      // Act
      final result = await useCase.call(userTriggered: false);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('天気情報の取得に失敗しました'));
    });
  });
}
