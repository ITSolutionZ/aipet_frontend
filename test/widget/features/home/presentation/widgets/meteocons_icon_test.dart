import 'package:aipet_frontend/features/home/presentation/widgets/meteocons_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MeteoconsIcon Widget Tests', () {
    testWidgets('should display weather icon correctly', (tester) async {
      // Arrange
      const testName = '01d';
      const testSize = 48.0;

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MeteoconsIcon(name: testName, size: testSize),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MeteoconsIcon), findsOneWidget);
      final meteoconsIcon = tester.widget<MeteoconsIcon>(
        find.byType(MeteoconsIcon),
      );
      expect(meteoconsIcon.name, equals(testName));
      expect(meteoconsIcon.size, equals(testSize));
    });

    testWidgets('should handle different icon names', (tester) async {
      // Arrange
      const testIconNames = [
        '01d', // clear sky day
        '01n', // clear sky night
        '02d', // few clouds day
        '02n', // few clouds night
        '03d', // scattered clouds
        '04d', // broken clouds
        '09d', // shower rain
        '10d', // rain
        '11d', // thunderstorm
        '13d', // snow
        '50d', // mist
      ];

      for (final iconName in testIconNames) {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: const MeteoconsIcon(name: iconName, size: 32.0),
              ),
            ),
          ),
        );

        // Assert
        final meteoconsIcon = tester.widget<MeteoconsIcon>(
          find.byType(MeteoconsIcon),
        );
        expect(meteoconsIcon.name, equals(iconName));
      }
    });

    testWidgets('should handle different sizes', (tester) async {
      // Arrange
      const testSizes = [16.0, 24.0, 32.0, 48.0, 64.0, 96.0];

      for (final size in testSizes) {
        // Act
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: const MeteoconsIcon(name: '01d', size: size),
              ),
            ),
          ),
        );

        // Assert
        final meteoconsIcon = tester.widget<MeteoconsIcon>(
          find.byType(MeteoconsIcon),
        );
        expect(meteoconsIcon.size, equals(size));
      }
    });

    testWidgets('should handle default values', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MeteoconsIcon(name: '01d')),
          ),
        ),
      );

      // Assert
      final meteoconsIcon = tester.widget<MeteoconsIcon>(
        find.byType(MeteoconsIcon),
      );
      expect(meteoconsIcon.name, equals('01d'));
      expect(meteoconsIcon.size, equals(32.0)); // default size
    });

    testWidgets('should handle empty icon name gracefully', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: MeteoconsIcon(name: '', size: 32.0)),
          ),
        ),
      );

      // Assert
      expect(find.byType(MeteoconsIcon), findsOneWidget);
      final meteoconsIcon = tester.widget<MeteoconsIcon>(
        find.byType(MeteoconsIcon),
      );
      expect(meteoconsIcon.name, equals(''));
    });

    testWidgets('should handle very large sizes', (tester) async {
      // Arrange
      const testSize = 200.0;

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MeteoconsIcon(name: '01d', size: testSize),
            ),
          ),
        ),
      );

      // Assert
      final meteoconsIcon = tester.widget<MeteoconsIcon>(
        find.byType(MeteoconsIcon),
      );
      expect(meteoconsIcon.size, equals(testSize));
    });
  });
}
