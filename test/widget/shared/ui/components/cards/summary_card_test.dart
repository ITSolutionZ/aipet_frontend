import 'package:aipet_frontend/shared/ui/components/cards/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SummaryCard', () {
    testWidgets('basic constructor displays title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard.basic(
              title: 'Pet Summary',
            ),
          ),
        ),
      );

      expect(find.text('Pet Summary'), findsOneWidget);
      expect(find.byType(SummaryCard), findsOneWidget);
    });

    testWidgets('withValue constructor shows title and value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard.withValue(
              title: 'Weight',
              value: '5.2',
              unit: 'kg',
            ),
          ),
        ),
      );

      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('5.2'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('loading constructor shows loading indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard.loading(
              title: 'Loading Data',
            ),
          ),
        ),
      );

      expect(find.text('Loading Data'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard.withValue(
              title: 'Steps Today',
              value: '1,250',
              icon: const Icon(Icons.directions_walk),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.directions_walk), findsOneWidget);
      expect(find.text('Steps Today'), findsOneWidget);
      expect(find.text('1,250'), findsOneWidget);
    });

    testWidgets('handles tap events when onTap is provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard.basic(
              title: 'Tappable Summary',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SummaryCard));
      expect(tapped, isTrue);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard.basic(
              title: 'Pet Health Summary',
              semanticLabel: 'Health summary for your pet',
            ),
          ),
        ),
      );

      final semanticsWidget = tester.widget<Semantics>(
        find.byType(Semantics).last,
      );
      expect(semanticsWidget.properties.label, 'Health summary for your pet');
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard.withValue(
              title: 'Daily Activity',
              subtitle: 'Based on last 7 days',
              value: '85%',
            ),
          ),
        ),
      );

      expect(find.text('Daily Activity'), findsOneWidget);
      expect(find.text('Based on last 7 days'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
    });

    testWidgets('shows trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SummaryCard.withValue(
              title: 'Progress',
              value: '75%',
              trailing: const Icon(Icons.trending_up),
            ),
          ),
        ),
      );

      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });
  });
}