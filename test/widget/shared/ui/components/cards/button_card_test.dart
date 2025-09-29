import 'package:aipet_frontend/shared/ui/components/cards/button_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ButtonCard', () {
    testWidgets('primary constructor displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ButtonCard.primary(
              title: 'Primary Button',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.byType(ButtonCard), findsOneWidget);
    });

    testWidgets('secondary constructor displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ButtonCard.secondary(
              title: 'Secondary Button',
              subtitle: 'With subtitle',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Secondary Button'), findsOneWidget);
      expect(find.text('With subtitle'), findsOneWidget);
    });

    testWidgets('danger constructor displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ButtonCard.danger(
              title: 'Delete Pet',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Delete Pet'), findsOneWidget);
    });

    testWidgets('outline constructor displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ButtonCard.outline(
              title: 'Outline Button',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Outline Button'), findsOneWidget);
    });

    testWidgets('handles tap events', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ButtonCard.primary(
              title: 'Tappable Button',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ButtonCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ButtonCard.primary(
              title: 'Button with Icon',
              icon: const Icon(Icons.save),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('Button with Icon'), findsOneWidget);
    });

    testWidgets('shows disabled state when isEnabled is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ButtonCard.primary(
              title: 'Disabled Button',
              onTap: () {},
              isEnabled: false,
            ),
          ),
        ),
      );

      expect(find.byType(Opacity), findsOneWidget);
      expect(find.text('Disabled Button'), findsOneWidget);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ButtonCard.primary(
              title: 'Save Changes',
              onTap: () {},
              semanticLabel: 'Save pet profile changes',
            ),
          ),
        ),
      );

      final semanticsWidget = tester.widget<Semantics>(
        find.byType(Semantics).last,
      );
      expect(semanticsWidget.properties.label, 'Save pet profile changes');
    });

    testWidgets('shows outline border for outline style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ButtonCard.outline(
              title: 'Outline Button',
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Outline Button'),
          matching: find.byType(Container),
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}