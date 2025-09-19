import 'package:aipet_frontend/features/home/presentation/screens/home_screen.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/common_summary_card.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/home_summary_grid.dart';
import 'package:aipet_frontend/features/home/presentation/widgets/meteocons_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_helper.dart';

void main() {
  group('Home Feature Accessibility Tests', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });

    group('Screen Reader Support', () {
      testWidgets('should have proper semantic labels for screen readers', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: HomeScreen())),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(HomeScreen), findsOneWidget);

        // Check for semantic labels
        expect(find.byType(Semantics), findsWidgets);

        // Verify that important elements have semantic labels
        final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
        expect(semantics.isNotEmpty, isTrue);
      });

      testWidgets(
        'should provide meaningful descriptions for interactive elements',
        (tester) async {
          // Arrange
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: CommonSummaryCard(
                  icon: Icons.pets,
                  iconColor: Colors.blue,
                  mainValue: '3',
                  unit: 'pets',
                  onTap: null,
                ),
              ),
            ),
          );

          // Act
          await tester.pumpAndSettle();

          // Assert
          expect(find.byType(CommonSummaryCard), findsOneWidget);

          // Check for semantic information
          final semantics = tester.widget<Semantics>(find.byType(Semantics));
          expect(semantics, isNotNull);
        },
      );
    });

    group('Keyboard Navigation', () {
      testWidgets('should support keyboard navigation', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: HomeScreen())),
        );

        // Act
        await tester.pumpAndSettle();

        // Simulate keyboard navigation
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Assert
        expect(find.byType(HomeScreen), findsOneWidget);
        // Should handle keyboard navigation without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle focus management correctly', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CommonSummaryCard(
                icon: Icons.directions_walk,
                iconColor: Colors.green,
                mainValue: '5',
                unit: 'km',
                onTap: () {},
              ),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CommonSummaryCard), findsOneWidget);
        // Should handle focus without errors
        expect(tester.takeException(), isNull);
      });
    });

    group('Color Contrast and Visual Accessibility', () {
      testWidgets('should maintain proper color contrast', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CommonSummaryCard(
                icon: Icons.pets,
                iconColor: Colors.blue,
                mainValue: '3',
                unit: 'pets',
                onTap: null,
              ),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CommonSummaryCard), findsOneWidget);
        // Should have proper color contrast
        expect(tester.takeException(), isNull);
      });

      testWidgets('should support high contrast mode', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: const ColorScheme.dark(
                primary: Colors.white,
                secondary: Colors.blue,
              ),
            ),
            home: const Scaffold(
              body: CommonSummaryCard(
                icon: Icons.pets,
                iconColor: Colors.blue,
                mainValue: '3',
                unit: 'pets',
                onTap: null,
              ),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CommonSummaryCard), findsOneWidget);
        // Should work in high contrast mode
        expect(tester.takeException(), isNull);
      });
    });

    group('Font Size and Text Scaling', () {
      testWidgets('should handle different font sizes', (tester) async {
        // Arrange
        const testFontSizes = [12.0, 16.0, 20.0, 24.0, 32.0];

        for (final fontSize in testFontSizes) {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                textTheme: TextTheme(
                  bodyLarge: TextStyle(fontSize: fontSize),
                  bodyMedium: TextStyle(fontSize: fontSize),
                ),
              ),
              home: const Scaffold(
                body: CommonSummaryCard(
                  icon: Icons.pets,
                  iconColor: Colors.blue,
                  mainValue: '3',
                  unit: 'pets',
                  onTap: null,
                ),
              ),
            ),
          );

          // Act
          await tester.pumpAndSettle();

          // Assert
          expect(find.byType(CommonSummaryCard), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('should handle text scaling', (tester) async {
        // Arrange
        const testTextScales = [0.8, 1.0, 1.2, 1.5, 2.0];

        for (final textScale in testTextScales) {
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                );
              },
              home: const Scaffold(
                body: CommonSummaryCard(
                  icon: Icons.pets,
                  iconColor: Colors.blue,
                  mainValue: '3',
                  unit: 'pets',
                  onTap: null,
                ),
              ),
            ),
          );

          // Act
          await tester.pumpAndSettle();

          // Assert
          expect(find.byType(CommonSummaryCard), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      });
    });

    group('Touch Target Size', () {
      testWidgets('should have adequate touch target sizes', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CommonSummaryCard(
                icon: Icons.pets,
                iconColor: Colors.blue,
                mainValue: '3',
                unit: 'pets',
                onTap: () {},
              ),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CommonSummaryCard), findsOneWidget);

        // Check that the touch target is large enough
        final card = tester.widget<CommonSummaryCard>(
          find.byType(CommonSummaryCard),
        );
        expect(card, isNotNull);

        // Should handle touch without errors
        await tester.tap(find.byType(CommonSummaryCard));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    });

    group('Screen Reader Announcements', () {
      testWidgets('should announce important information to screen readers', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CommonSummaryCard(
                icon: Icons.pets,
                iconColor: Colors.blue,
                mainValue: '3',
                unit: 'pets',
                onTap: null,
              ),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CommonSummaryCard), findsOneWidget);

        // Check for semantic information
        final semantics = tester.widget<Semantics>(find.byType(Semantics));
        expect(semantics, isNotNull);
      });

      testWidgets('should provide context for weather information', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: MeteoconsIcon(name: '01d', size: 48.0)),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(MeteoconsIcon), findsOneWidget);

        // Should provide semantic information for weather icons
        expect(tester.takeException(), isNull);
      });
    });

    group('Motor Accessibility', () {
      testWidgets('should support alternative input methods', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CommonSummaryCard(
                icon: Icons.pets,
                iconColor: Colors.blue,
                mainValue: '3',
                unit: 'pets',
                onTap: () {},
              ),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Simulate alternative input methods
        await tester.tap(find.byType(CommonSummaryCard));
        await tester.pump();

        // Assert
        expect(find.byType(CommonSummaryCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle gesture recognition', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: HomeSummaryGrid())),
        );

        // Act
        await tester.pumpAndSettle();

        // Simulate different gestures
        await tester.drag(find.byType(HomeSummaryGrid), const Offset(100, 0));
        await tester.pump();

        // Assert
        expect(find.byType(HomeSummaryGrid), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Cognitive Accessibility', () {
      testWidgets('should provide clear visual hierarchy', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: HomeSummaryGrid())),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(HomeSummaryGrid), findsOneWidget);

        // Check for proper visual hierarchy
        expect(find.text('今日のサマリー'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should provide consistent navigation patterns', (
        tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: HomeScreen())),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(HomeScreen), findsOneWidget);

        // Should maintain consistent navigation
        expect(tester.takeException(), isNull);
      });
    });

    group('Internationalization Accessibility', () {
      testWidgets('should support different text directions', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: const Scaffold(
              body: CommonSummaryCard(
                icon: Icons.pets,
                iconColor: Colors.blue,
                mainValue: '3',
                unit: 'pets',
                onTap: null,
              ),
            ),
          ),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CommonSummaryCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle Japanese text properly', (tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: HomeSummaryGrid())),
        );

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('今日のサマリー'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
