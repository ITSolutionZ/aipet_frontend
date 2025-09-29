import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/weather_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherCardWidget', () {
    testWidgets('should display weather information correctly', (tester) async {
      // Arrange
      final weather = WeatherEntity(
        id: 'weather_1',
        temperature: 25.0,
        humidity: 60.0,
        windSpeed: 5.0,
        description: '晴れ',
        iconCode: '01d',
        location: '東京',
        timestamp: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: WeatherCardWidget(weather: weather)),
          ),
        ),
      );

      // Assert
      expect(find.text('25°C'), findsOneWidget);
      expect(find.text('晴れ'), findsOneWidget);
      expect(find.text('東京'), findsOneWidget);
      expect(find.text('湿度: 60%'), findsOneWidget);
      expect(find.text('風速: 5.0 m/s'), findsOneWidget);
    });

    testWidgets('should show loading state when weather is null', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: WeatherCardWidget(weather: null)),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('天気情報を読み込み中...'), findsOneWidget);
    });

    testWidgets('should handle refresh when refresh button is tapped', (
      tester,
    ) async {
      // Arrange
      final weather = WeatherEntity(
        id: 'weather_1',
        temperature: 25.0,
        humidity: 60.0,
        windSpeed: 5.0,
        description: '晴れ',
        iconCode: '01d',
        location: '東京',
        timestamp: DateTime.now(),
      );

      bool refreshCalled = false;

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WeatherCardWidget(
                weather: weather,
                onRefresh: () {
                  refreshCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Assert
      expect(refreshCalled, true);
    });

    testWidgets('should display different weather conditions', (tester) async {
      // Arrange
      final rainyWeather = WeatherEntity(
        id: 'weather_2',
        temperature: 18.0,
        humidity: 85.0,
        windSpeed: 8.0,
        description: '雨',
        iconCode: '10d',
        location: '大阪',
        timestamp: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: WeatherCardWidget(weather: rainyWeather)),
          ),
        ),
      );

      // Assert
      expect(find.text('18°C'), findsOneWidget);
      expect(find.text('雨'), findsOneWidget);
      expect(find.text('大阪'), findsOneWidget);
      expect(find.text('湿度: 85%'), findsOneWidget);
      expect(find.text('風速: 8.0 m/s'), findsOneWidget);
    });
  });
}
