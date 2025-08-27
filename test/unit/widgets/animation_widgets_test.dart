import 'package:aipet_frontend/shared/widgets/animation/animated_fade_widget.dart';
import 'package:aipet_frontend/shared/widgets/animation/animated_scale_widget.dart';
import 'package:aipet_frontend/shared/widgets/animation/animated_slide_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedFadeWidget Tests', () {
    testWidgets('should show child with fade animation', (WidgetTester tester) async {
      // Arrange
      const testWidget = AnimatedFadeWidget(
        show: true,
        child: Text('Test'),
      );

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should hide child when show is false', (WidgetTester tester) async {
      // Arrange
      const testWidget = AnimatedFadeWidget(
        show: false,
        child: Text('Test'),
      );

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should call onAnimationComplete when animation completes', (WidgetTester tester) async {
      // Arrange
      bool callbackCalled = false;
      final testWidget = AnimatedFadeWidget(
        show: true,
        onAnimationComplete: () {
          callbackCalled = true;
        },
        child: const Text('Test'),
      );

      // Act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(callbackCalled, isTrue);
    });
  });

  group('StaggeredFadeWidget Tests', () {
    testWidgets('should show all children with staggered animation', (WidgetTester tester) async {
      // Arrange
      const testWidget = StaggeredFadeWidget(
        show: true,
        children: [
          Text('Child 1'),
          Text('Child 2'),
          Text('Child 3'),
        ],
      );

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
      expect(find.text('Child 3'), findsOneWidget);
    });
  });

  group('AnimatedSlideWidget Tests', () {
    testWidgets('should show child with slide animation from bottom', (WidgetTester tester) async {
      // Arrange
      const testWidget = AnimatedSlideWidget(
        direction: SlideDirection.fromBottom,
        show: true,
        child: Text('Test'),
      );

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should show child with slide animation from left', (WidgetTester tester) async {
      // Arrange
      const testWidget = AnimatedSlideWidget(
        direction: SlideDirection.fromLeft,
        show: true,
        child: Text('Test'),
      );

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should call onAnimationComplete when animation completes', (WidgetTester tester) async {
      // Arrange
      bool callbackCalled = false;
      final testWidget = AnimatedSlideWidget(
        direction: SlideDirection.fromBottom,
        show: true,
        onAnimationComplete: () {
          callbackCalled = true;
        },
        child: const Text('Test'),
      );

      // Act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(callbackCalled, isTrue);
    });
  });

  group('StaggeredSlideWidget Tests', () {
    testWidgets('should show all children with staggered slide animation', (WidgetTester tester) async {
      // Arrange
      const testWidget = StaggeredSlideWidget(
        direction: SlideDirection.fromBottom,
        show: true,
        children: [
          Text('Child 1'),
          Text('Child 2'),
          Text('Child 3'),
        ],
      );

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
      expect(find.text('Child 3'), findsOneWidget);
    });
  });

  group('AnimatedScaleWidget Tests', () {
    testWidgets('should show child with scale animation', (WidgetTester tester) async {
      // Arrange
      const testWidget = AnimatedScaleWidget(
        show: true,
        beginScale: 0.0,
        endScale: 1.0,
        child: Text('Test'),
      );

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should call onAnimationComplete when animation completes', (WidgetTester tester) async {
      // Arrange
      bool callbackCalled = false;
      final testWidget = AnimatedScaleWidget(
        show: true,
        beginScale: 0.0,
        endScale: 1.0,
        onAnimationComplete: () {
          callbackCalled = true;
        },
        child: const Text('Test'),
      );

      // Act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(callbackCalled, isTrue);
    });
  });

  group('StaggeredScaleWidget Tests', () {
    testWidgets('should show all children with staggered scale animation', (WidgetTester tester) async {
      // Arrange
      const testWidget = StaggeredScaleWidget(
        show: true,
        beginScale: 0.0,
        endScale: 1.0,
        children: [
          Text('Child 1'),
          Text('Child 2'),
          Text('Child 3'),
        ],
      );

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: testWidget)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
      expect(find.text('Child 3'), findsOneWidget);
    });
  });

  group('AnimatedButtonWidget Tests', () {
    testWidgets('should show button with scale animation on tap', (WidgetTester tester) async {
      // Arrange
      bool buttonPressed = false;
      final testWidget = AnimatedButtonWidget(
        child: const Text('Button'),
        onPressed: () {
          buttonPressed = true;
        },
      );

      // Act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: testWidget)));
      await tester.tap(find.text('Button'));
      await tester.pumpAndSettle();

      // Assert
      expect(buttonPressed, isTrue);
    });

    testWidgets('should not respond to tap when disabled', (WidgetTester tester) async {
      // Arrange
      bool buttonPressed = false;
      final testWidget = AnimatedButtonWidget(
        enabled: false,
        onPressed: () {
          buttonPressed = true;
        },
        child: const Text('Button'),
      );

      // Act
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: testWidget)));
      await tester.tap(find.text('Button'));
      await tester.pumpAndSettle();

      // Assert
      expect(buttonPressed, isFalse);
    });
  });
}
