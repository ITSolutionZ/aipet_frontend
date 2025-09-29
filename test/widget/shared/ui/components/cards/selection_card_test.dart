import 'package:aipet_frontend/shared/ui/components/cards/selection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SelectionCard', () {
    testWidgets('basic constructor displays child content', (tester) async {
      const testChild = Text('Test Content');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectionCard.basic(
              child: testChild,
              isSelected: false,
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(SelectionCard), findsOneWidget);
    });

    testWidgets('shows selected state with check icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectionCard.basic(
              child: Text('Selected Item'),
              isSelected: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Selected Item'), findsOneWidget);
    });

    testWidgets('titled constructor shows title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectionCard.titled(
              title: 'Card Title',
              subtitle: 'Card Subtitle',
              child: Text('Card Content'),
              isSelected: false,
            ),
          ),
        ),
      );

      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Card Subtitle'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('handles tap events', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionCard.basic(
              child: const Text('Tappable Card'),
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SelectionCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectionCard.titled(
              title: 'Card with Icon',
              icon: Icon(Icons.pets),
              child: Text('Content'),
              isSelected: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.text('Card with Icon'), findsOneWidget);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectionCard.basic(
              child: Text('Accessible Card'),
              isSelected: false,
              semanticLabel: 'Pet selection card',
            ),
          ),
        ),
      );

      final semanticsWidget = tester.widget<Semantics>(
        find.byType(Semantics).last,
      );
      expect(semanticsWidget.properties.label, 'Pet selection card');
    });

    testWidgets('shows tooltip when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SelectionCard.basic(
              child: Text('Card with Tooltip'),
              isSelected: false,
              tooltip: 'This is a helpful tooltip',
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}