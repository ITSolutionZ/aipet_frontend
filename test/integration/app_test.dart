import 'package:aipet_frontend/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AI Pet App Integration Tests', () {
    testWidgets('should complete full app flow from splash to home',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: AIPetApp(),
        ),
      );

      // Act & Assert - Splash Screen (로고 이미지 확인)
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for splash to complete
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Act & Assert - Onboarding or Login Screen
      // Check if we're on onboarding or login screen
      final isOnboarding = find.text('반려동물과 함께하는\n스마트한 일상').evaluate().isNotEmpty;
      final isLogin = find.text('로그인').evaluate().isNotEmpty;

      if (isOnboarding) {
        // Complete onboarding flow
        await _completeOnboarding(tester);
      } else if (isLogin) {
        // Complete login flow
        await _completeLogin(tester);
      }

      // Act & Assert - Home Screen
      await tester.pumpAndSettle();
      expect(find.text('홈'), findsOneWidget);
      expect(find.text('펫'), findsOneWidget);
      expect(find.text('산책'), findsOneWidget);
      expect(find.text('설정'), findsOneWidget);
    });

    testWidgets('should handle navigation between main screens',
        (WidgetTester tester) async {
      // Arrange - Start app and navigate to home
      await tester.pumpWidget(
        const ProviderScope(
          child: AIPetApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Skip onboarding/login if needed
      await _skipToHome(tester);

      // Act & Assert - Navigate to Pet Screen
      await tester.tap(find.text('펫'));
      await tester.pumpAndSettle();
      expect(find.text('펫 관리'), findsOneWidget);

      // Act & Assert - Navigate to Walk Screen
      await tester.tap(find.text('산책'));
      await tester.pumpAndSettle();
      expect(find.text('산책'), findsOneWidget);

      // Act & Assert - Navigate to Settings Screen
      await tester.tap(find.text('설정'));
      await tester.pumpAndSettle();
      expect(find.text('설정'), findsOneWidget);

      // Act & Assert - Return to Home
      await tester.tap(find.text('홈'));
      await tester.pumpAndSettle();
      expect(find.text('홈'), findsOneWidget);
    });

    testWidgets('should handle pet management flow', (WidgetTester tester) async {
      // Arrange - Navigate to pet screen
      await tester.pumpWidget(
        const ProviderScope(
          child: AIPetApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await _skipToHome(tester);

      await tester.tap(find.text('펫'));
      await tester.pumpAndSettle();

      // Act & Assert - Add new pet
      final addPetButton = find.byIcon(Icons.add);
      if (addPetButton.evaluate().isNotEmpty) {
        await tester.tap(addPetButton);
        await tester.pumpAndSettle();

        // Fill pet information
        await tester.enterText(
          find.byType(TextField).first,
          '테스트 펫',
        );
        await tester.enterText(
          find.byType(TextField).at(1),
          '3',
        );

        // Select pet type
        await tester.tap(find.text('강아지'));
        await tester.pumpAndSettle();

        // Save pet
        await tester.tap(find.text('저장'));
        await tester.pumpAndSettle();

        // Verify pet was added
        expect(find.text('테스트 펫'), findsOneWidget);
      }
    });

    testWidgets('should handle authentication flow', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: AIPetApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Check if login screen is shown
      if (find.text('로그인').evaluate().isNotEmpty) {
        await _completeLogin(tester);
      }

      // Verify we're on home screen
      await tester.pumpAndSettle();
      expect(find.text('홈'), findsOneWidget);
    });

    testWidgets('should handle settings and logout flow',
        (WidgetTester tester) async {
      // Arrange - Navigate to settings
      await tester.pumpWidget(
        const ProviderScope(
          child: AIPetApp(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await _skipToHome(tester);

      await tester.tap(find.text('설정'));
      await tester.pumpAndSettle();

      // Act & Assert - Check settings options
      expect(find.text('설정'), findsOneWidget);

      // Look for logout option
      final logoutButton = find.text('로그아웃');
      if (logoutButton.evaluate().isNotEmpty) {
        await tester.tap(logoutButton);
        await tester.pumpAndSettle();

        // Verify logout confirmation or return to login
        expect(
          find.text('로그인').evaluate().isNotEmpty ||
              find.text('로그아웃').evaluate().isNotEmpty,
          isTrue,
        );
      }
    });

    testWidgets('should handle splash screen animation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: AIPetApp(),
        ),
      );

      // Act & Assert - Initial splash state
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for animation to start
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Image), findsOneWidget);

      // Wait for splash to complete
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify navigation occurred
      expect(find.text('홈').evaluate().isNotEmpty ||
          find.text('로그인').evaluate().isNotEmpty ||
          find.text('반려동물과 함께하는\n스마트한 일상').evaluate().isNotEmpty,
          isTrue);
    });
  });
}

/// 온보딩 플로우 완료
Future<void> _completeOnboarding(WidgetTester tester) async {
  // Skip through onboarding screens
  for (int i = 0; i < 4; i++) {
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
  }

  // Complete onboarding
  await tester.tap(find.text('시작하기'));
  await tester.pumpAndSettle();
}

/// 로그인 플로우 완료
Future<void> _completeLogin(WidgetTester tester) async {
  // Enter test credentials
  await tester.enterText(
    find.byType(TextField).first,
    'test@example.com',
  );
  await tester.enterText(
    find.byType(TextField).at(1),
    'password123',
  );

  // Login
  await tester.tap(find.text('로그인'));
  await tester.pumpAndSettle();
}

/// 홈 화면으로 이동
Future<void> _skipToHome(WidgetTester tester) async {
  // Check if we need to complete onboarding
  if (find.text('반려동물과 함께하는\n스마트한 일상').evaluate().isNotEmpty) {
    await _completeOnboarding(tester);
  }

  // Check if we need to login
  if (find.text('로그인').evaluate().isNotEmpty) {
    await _completeLogin(tester);
  }

  // Wait for home screen
  await tester.pumpAndSettle();
}
