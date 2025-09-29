import 'package:aipet_frontend/features/home/presentation/widgets/common_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommonSummaryCard Widget Tests', () {
    testWidgets('should display basic information correctly', (tester) async {
      // Arrange
      const testIcon = Icons.pets;
      const testIconColor = Colors.blue;
      const testMainValue = '5';
      const testUnit = 'km';
      const testOnTap = null;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonSummaryCard(
              icon: testIcon,
              iconColor: testIconColor,
              mainValue: testMainValue,
              unit: testUnit,
              onTap: testOnTap,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(find.text(testMainValue), findsOneWidget);
      expect(find.text(testUnit), findsOneWidget);
    });

    testWidgets('should handle tap events when onTap is provided', (
      tester,
    ) async {
      // Arrange
      bool tapped = false;
      const testIcon = Icons.directions_walk;
      const testIconColor = Colors.green;
      const testMainValue = '3';
      const testUnit = 'walks';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const CommonSummaryCard(
              icon: testIcon,
              iconColor: testIconColor,
              mainValue: testMainValue,
              unit: testUnit,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CommonSummaryCard));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should not respond to tap when onTap is null', (tester) async {
      // Arrange
      const testIcon = Icons.pets;
      const testIconColor = Colors.blue;
      const testMainValue = '2';
      const testUnit = 'pets';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonSummaryCard(
              icon: testIcon,
              iconColor: testIconColor,
              mainValue: testMainValue,
              unit: testUnit,
              onTap: null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CommonSummaryCard));
      await tester.pump();

      // Assert - should not throw any exceptions
      expect(find.byType(CommonSummaryCard), findsOneWidget);
    });

    testWidgets('should display different icons and colors', (tester) async {
      // Arrange
      const testCases = [
        (Icons.restaurant, Colors.orange, '4', 'meals'),
        (Icons.fitness_center, Colors.purple, '2', 'kg'),
        (Icons.calendar_today, Colors.red, '1', 'appointment'),
      ];

      for (final testCase in testCases) {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const CommonSummaryCard(
                icon: testCase.$1,
                iconColor: testCase.$2,
                mainValue: testCase.$3,
                unit: testCase.$4,
                onTap: null,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(testCase.$1), findsOneWidget);
        expect(find.text(testCase.$3), findsOneWidget);
        expect(find.text(testCase.$4), findsOneWidget);
      }
    });

    testWidgets('should handle empty values gracefully', (tester) async {
      // Arrange
      const testIcon = Icons.pets;
      const testIconColor = Colors.blue;
      const testMainValue = '';
      const testUnit = '';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommonSummaryCard(
              icon: testIcon,
              iconColor: testIconColor,
              mainValue: testMainValue,
              unit: testUnit,
              onTap: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(find.text(testMainValue), findsOneWidget);
      expect(find.text(testUnit), findsOneWidget);
    });
  });
}
