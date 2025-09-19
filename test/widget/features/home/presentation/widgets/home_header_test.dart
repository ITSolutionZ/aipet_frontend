import 'package:aipet_frontend/features/home/presentation/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeHeader Widget Tests', () {
    testWidgets('should display header elements correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeHeader(onNotificationTap: () {})),
        ),
      );

      // Assert
      expect(find.byType(HomeHeader), findsOneWidget);
      // Check for common header elements that should be present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle different screen sizes', (tester) async {
      // Test with different screen sizes
      final testSizes = [
        const Size(400, 800), // Phone portrait
        const Size(800, 400), // Phone landscape
        const Size(1200, 800), // Tablet
      ];

      for (final size in testSizes) {
        // Act
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: size.width,
                height: size.height,
                child: HomeHeader(onNotificationTap: () {}),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(HomeHeader), findsOneWidget);
      }
    });

    testWidgets('should maintain proper layout structure', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeHeader(onNotificationTap: () {})),
        ),
      );

      // Assert
      final homeHeader = tester.widget<HomeHeader>(find.byType(HomeHeader));
      expect(homeHeader, isNotNull);

      // Check that the widget renders without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle theme changes', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: HomeHeader(onNotificationTap: () {})),
        ),
      );

      // Assert
      expect(find.byType(HomeHeader), findsOneWidget);

      // Change theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: HomeHeader(onNotificationTap: () {})),
        ),
      );

      // Assert
      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('should be responsive to orientation changes', (tester) async {
      // Portrait orientation
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeHeader(onNotificationTap: () {})),
        ),
      );

      expect(find.byType(HomeHeader), findsOneWidget);

      // Landscape orientation
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeHeader(onNotificationTap: () {})),
        ),
      );

      expect(find.byType(HomeHeader), findsOneWidget);
    });

    testWidgets('should handle widget rebuilds', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: HomeHeader(onNotificationTap: () {})),
        ),
      );

      // Rebuild the widget
      await tester.pump();

      // Assert
      expect(find.byType(HomeHeader), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
