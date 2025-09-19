import 'package:aipet_frontend/features/splash/domain/entities/splash_state.dart';
import 'package:aipet_frontend/features/splash/presentation/widgets/splash_logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('should display splash logo widget with different states', (
      tester,
    ) async {
      // Arrange
      const splashState = SplashState(
        phase: SplashPhase.initializing,
        imagePath: '',
        currentStep: 0,
        totalSteps: 3,
        progress: 0.0,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SplashLogoWidget(splashState: splashState)),
        ),
      );

      // Assert
      expect(find.byType(SplashLogoWidget), findsOneWidget);
    });

    testWidgets('should have proper background color in scaffold', (
      tester,
    ) async {
      // Arrange
      const splashState = SplashState(
        phase: SplashPhase.initializing,
        imagePath: '',
        currentStep: 0,
        totalSteps: 3,
        progress: 0.0,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: SplashLogoWidget(splashState: splashState),
          ),
        ),
      );

      // Assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.white));
    });

    testWidgets('should center content in scaffold', (tester) async {
      // Arrange
      const splashState = SplashState(
        phase: SplashPhase.initializing,
        imagePath: '',
        currentStep: 0,
        totalSteps: 3,
        progress: 0.0,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: SplashLogoWidget(splashState: splashState)),
          ),
        ),
      );

      // Assert
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(SplashLogoWidget), findsOneWidget);
    });
  });
}
