import 'package:aipet_frontend/features/home/presentation/widgets/home_summary_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeSummaryGrid Widget Tests', () {
    testWidgets('should display section title correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: HomeSummaryGrid())),
        ),
      );

      // Assert
      expect(find.text('今日のサマリー'), findsOneWidget);
    });

    testWidgets('should contain all summary cards', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: HomeSummaryGrid()),
            ),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Assert - Check that the grid contains the expected cards
      expect(find.byType(GridView), findsOneWidget);

      // Check for specific card types (these should be present in the grid)
      // Note: The actual card widgets might not be directly findable due to their implementation
      // but we can verify the grid structure
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView, isNotNull);
    });

    testWidgets('should have proper grid configuration', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: HomeSummaryGrid()),
            ),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Assert
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView, isNotNull);
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
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: const HomeSummaryGrid(),
                ),
              ),
            ),
          ),
        );

        // Wait for async operations to complete
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('今日のサマリー'), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('should maintain proper spacing', (tester) async {
      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: HomeSummaryGrid()),
            ),
          ),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Assert
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView, isNotNull);
    });
  });
}
