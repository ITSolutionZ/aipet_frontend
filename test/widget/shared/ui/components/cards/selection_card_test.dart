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
            body: SelectionCard.basic(isSelected: false, child: testChild),
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
              isSelected: true,
              child: Text('Selected Item'),
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
              isSelected: false,
              child: Text('Card Content'),
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
              isSelected: false,
              onTap: () => tapped = true,
              child: const Text('Tappable Card'),
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
              isSelected: false,
              child: Text('Content'),
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
              isSelected: false,
              semanticLabel: 'Pet selection card',
              child: Text('Accessible Card'),
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
              isSelected: false,
              tooltip: 'This is a helpful tooltip',
              child: Text('Card with Tooltip'),
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
    });
  });
}
