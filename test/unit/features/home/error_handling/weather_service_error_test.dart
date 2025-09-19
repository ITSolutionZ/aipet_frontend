import 'package:aipet_frontend/features/home/data/models/weather_model.dart';
import 'package:aipet_frontend/features/home/data/services/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../test_helper.dart';
import 'weather_service_error_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('WeatherService Error Handling Tests', () {
    late WeatherService weatherService;
    late MockClient mockClient;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      weatherService = WeatherService();
      mockClient = MockClient();
    });

    group('Network Error Handling', () {
      test('should handle network timeout gracefully', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenThrow(http.ClientException('Network timeout'));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle connection refused error', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenThrow(http.ClientException('Connection refused'));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle DNS resolution failure', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenThrow(http.ClientException('Failed host lookup'));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('API Error Handling', () {
      test('should handle 401 Unauthorized error', () async {
        // Arrange
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error": "Unauthorized"}', 401),
        );

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle 403 Forbidden error', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('{"error": "Forbidden"}', 403));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle 404 Not Found error', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('{"error": "Not Found"}', 404));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle 429 Too Many Requests error', () async {
        // Arrange
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error": "Too Many Requests"}', 429),
        );

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle 500 Internal Server Error', () async {
        // Arrange
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error": "Internal Server Error"}', 500),
        );

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle 503 Service Unavailable error', () async {
        // Arrange
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error": "Service Unavailable"}', 503),
        );

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Data Parsing Error Handling', () {
      test('should handle malformed JSON response', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('invalid json', 200));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle empty response body', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('', 200));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle null response body', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('null', 200));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle missing required fields in JSON', () async {
        // Arrange
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response('{"incomplete": "data"}', 200));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Location Error Handling', () {
      test('should handle location permission denied', () async {
        // Arrange
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error": "Permission denied"}', 403),
        );

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle location service disabled', () async {
        // Arrange
        when(mockClient.get(any)).thenAnswer(
          (_) async =>
              http.Response('{"error": "Location service disabled"}', 400),
        );

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle location timeout', () async {
        // Arrange
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error": "Location timeout"}', 408),
        );

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Fallback Error Handling', () {
      test('should fallback to mock data when all APIs fail', () async {
        // Arrange
        when(mockClient.get(any)).thenThrow(Exception('All APIs failed'));

        // Act
        final result = await weatherService.getCurrentWeather();

        // Assert
        expect(result, isNotNull);
        expect(result, isA<WeatherData>());
        // Should return mock data when all APIs fail
        expect(result!.location, isNotEmpty);
        expect(result.temperature, isA<double>());
      });

      test('should handle multiple consecutive failures', () async {
        // Arrange
        when(mockClient.get(any)).thenThrow(Exception('Consecutive failures'));

        // Act & Assert
        for (int i = 0; i < 5; i++) {
          expect(
            () => weatherService.getCurrentWeather(),
            throwsA(isA<Exception>()),
          );
        }
      });
    });

    group('Edge Cases', () {
      test('should handle very large response', () async {
        // Arrange
        final largeResponse = '{"data": "${'x' * 1000000}"}';
        when(
          mockClient.get(any),
        ).thenAnswer((_) async => http.Response(largeResponse, 200));

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle special characters in location', () async {
        // Arrange
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error": "Invalid location"}', 400),
        );

        // Act & Assert
        expect(
          () => weatherService.getCurrentWeather(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle concurrent requests', () async {
        // Arrange
        when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error": "Rate limited"}', 429),
        );

        // Act & Assert
        final futures = List.generate(
          10,
          (_) => weatherService.getCurrentWeather(),
        );
        expect(() => Future.wait(futures), throwsA(isA<Exception>()));
      });
    });
  });
}
