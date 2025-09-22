import 'package:aipet_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aipet_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Authentication Integration Tests', () {
    late AuthRepositoryImpl repository;
    late LoginUseCase loginUseCase;
    late SignupUseCase signupUseCase;
    late LogoutUseCase logoutUseCase;
    late GetCurrentUserUseCase getCurrentUserUseCase;

    setUp(() {
      repository = AuthRepositoryImpl();
      loginUseCase = LoginUseCase(repository);
      signupUseCase = SignupUseCase(repository);
      logoutUseCase = LogoutUseCase(repository);
      getCurrentUserUseCase = GetCurrentUserUseCase(repository);
    });

    group('Complete Authentication Flow', () {
      test('should complete full signup and login flow', () async {
        const testEmail = 'integration_test@example.com';
        const testPassword = 'IntegrationTest123!';
        const testDisplayName = 'Integration Test User';

        // Step 1: Check initial login state
        final initialLoginCheck = await getCurrentUserUseCase.isLoggedIn();
        expect(initialLoginCheck.isSuccess, isTrue);
        expect(initialLoginCheck.data, isFalse);

        // Step 2: Attempt login with non-existent account (should fail)
        final initialLoginAttempt = await loginUseCase.call(
          email: testEmail,
          password: testPassword,
        );
        expect(initialLoginAttempt.isSuccess, isFalse);

        // Step 3: Sign up new account
        final signupResult = await signupUseCase.call(
          email: testEmail,
          password: testPassword,
          confirmPassword: testPassword,
          displayName: testDisplayName,
        );
        expect(signupResult.isSuccess, isTrue);
        expect(signupResult.data, isA<AuthUser>());
        expect(signupResult.data?.email, equals(testEmail));
        expect(signupResult.data?.displayName, equals(testDisplayName));

        // Step 4: Check login state after signup
        final postSignupLoginCheck = await getCurrentUserUseCase.isLoggedIn();
        expect(postSignupLoginCheck.isSuccess, isTrue);
        expect(postSignupLoginCheck.data, isTrue);

        // Step 5: Get current user info
        final currentUserResult = await getCurrentUserUseCase.call();
        expect(currentUserResult.isSuccess, isTrue);
        expect(currentUserResult.data, isNotNull);
        expect(currentUserResult.data?.email, equals(testEmail));

        // Step 6: Logout
        final logoutResult = await logoutUseCase.call();
        expect(logoutResult.isSuccess, isTrue);

        // Step 7: Check login state after logout
        final postLogoutLoginCheck = await getCurrentUserUseCase.isLoggedIn();
        expect(postLogoutLoginCheck.isSuccess, isTrue);
        expect(postLogoutLoginCheck.data, isFalse);

        // Step 8: Login with created account
        final loginResult = await loginUseCase.call(
          email: testEmail,
          password: testPassword,
        );
        expect(loginResult.isSuccess, isTrue);
        expect(loginResult.data, isA<AuthUser>());
        expect(loginResult.data?.email, equals(testEmail));

        // Step 9: Final logout cleanup
        await logoutUseCase.call();
      });

      test('should handle email verification flow', () async {
        const testEmail = 'email_verification_test@example.com';
        const testPassword = 'EmailVerifyTest123!';

        // Step 1: Sign up new account
        final signupResult = await signupUseCase.call(
          email: testEmail,
          password: testPassword,
          confirmPassword: testPassword,
        );
        expect(signupResult.isSuccess, isTrue);

        // Step 2: Check email verification status (should be false initially)
        final emailVerifyCheck = await getCurrentUserUseCase.isEmailVerified();
        expect(emailVerifyCheck.isSuccess, isTrue);
        expect(emailVerifyCheck.data, isFalse);

        // Cleanup
        await logoutUseCase.call();
      });
    });

    group('Authentication Error Scenarios', () {
      test('should handle invalid email formats consistently', () async {
        const invalidEmails = [
          'invalid',
          'invalid@',
          '@domain.com',
          'user@',
          'user space@domain.com',
        ];

        for (final email in invalidEmails) {
          // Test signup with invalid email
          final signupResult = await signupUseCase.call(
            email: email,
            password: 'ValidPassword123!',
            confirmPassword: 'ValidPassword123!',
          );
          expect(signupResult.isSuccess, isFalse);
          expect(signupResult.message, contains('有効なメールアドレスを入力してください'));

          // Test login with invalid email
          final loginResult = await loginUseCase.call(
            email: email,
            password: 'ValidPassword123!',
          );
          expect(loginResult.isSuccess, isFalse);
          expect(loginResult.message, contains('有効なメールアドレスを入力してください'));
        }
      });

      test('should handle weak passwords consistently', () async {
        const testEmail = 'weak_password_test@example.com';
        const weakPasswords = [
          'password', // no uppercase, no numbers, no special chars
          'PASSWORD', // no lowercase, no numbers, no special chars
          '12345678', // no letters, no special chars
          'Password', // no numbers, no special chars
          'Password123', // no special chars
        ];

        for (final password in weakPasswords) {
          final signupResult = await signupUseCase.call(
            email: testEmail,
            password: password,
            confirmPassword: password,
          );
          expect(signupResult.isSuccess, isFalse);
          expect(signupResult.message, contains('パスワードは英字、数字、特殊文字を含む必要があります'));
        }
      });

      test('should handle password mismatch in signup', () async {
        const testEmail = 'password_mismatch_test@example.com';
        const password = 'ValidPassword123!';
        const wrongConfirmPassword = 'DifferentPassword123!';

        final signupResult = await signupUseCase.call(
          email: testEmail,
          password: password,
          confirmPassword: wrongConfirmPassword,
        );
        expect(signupResult.isSuccess, isFalse);
        expect(signupResult.message, contains('パスワードが一致しません'));
      });

      test('should handle empty field validations', () async {
        // Test empty email in signup
        final emptyEmailSignup = await signupUseCase.call(
          email: '',
          password: 'ValidPassword123!',
          confirmPassword: 'ValidPassword123!',
        );
        expect(emptyEmailSignup.isSuccess, isFalse);
        expect(emptyEmailSignup.message, contains('全ての項目を入力してください'));

        // Test empty password in signup
        final emptyPasswordSignup = await signupUseCase.call(
          email: 'test@example.com',
          password: '',
          confirmPassword: 'ValidPassword123!',
        );
        expect(emptyPasswordSignup.isSuccess, isFalse);
        expect(emptyPasswordSignup.message, contains('全ての項目を入力してください'));

        // Test empty email in login
        final emptyEmailLogin = await loginUseCase.call(
          email: '',
          password: 'ValidPassword123!',
        );
        expect(emptyEmailLogin.isSuccess, isFalse);
        expect(emptyEmailLogin.message, contains('メールアドレスとパスワードを入力してください'));

        // Test empty password in login
        final emptyPasswordLogin = await loginUseCase.call(
          email: 'test@example.com',
          password: '',
        );
        expect(emptyPasswordLogin.isSuccess, isFalse);
        expect(emptyPasswordLogin.message, contains('メールアドレスとパスワードを入力してください'));
      });
    });

    group('Social Login Integration', () {
      test('should handle Google login flow', () async {
        // Note: This would require actual Google authentication setup
        // For now, we test that the method exists and handles the call
        final result = await loginUseCase.loginWithGoogle();

        // In a real integration test environment with proper setup,
        // this might succeed or fail based on configuration
        expect(result, isA<Result<AuthUser>>());
      });

      test('should handle Apple login flow', () async {
        // Note: This would require actual Apple authentication setup
        final result = await loginUseCase.loginWithApple();

        // In a real integration test environment with proper setup,
        // this might succeed or fail based on configuration
        expect(result, isA<Result<AuthUser>>());
      });

      test('should handle LINE login flow', () async {
        // Note: This would require actual LINE authentication setup
        final result = await loginUseCase.loginWithLine();

        // In a real integration test environment with proper setup,
        // this might succeed or fail based on configuration
        expect(result, isA<Result<AuthUser>>());
      });
    });

    group('Session Management', () {
      test(
        'should maintain consistent login state across operations',
        () async {
          // Step 1: Verify logged out state
          final initialState = await getCurrentUserUseCase.isLoggedIn();
          expect(initialState.data, isFalse);

          // Step 2: Attempt to get current user when logged out
          final loggedOutUser = await getCurrentUserUseCase.call();
          expect(loggedOutUser.isSuccess, isTrue);
          expect(loggedOutUser.data, isNull);

          // Step 3: Attempt email verification when logged out
          final loggedOutEmailVerify = await getCurrentUserUseCase
              .isEmailVerified();
          expect(loggedOutEmailVerify.isSuccess, isFalse);
          expect(loggedOutEmailVerify.message, contains('ログインしていません'));

          // Step 4: Multiple logout calls should be safe
          final logoutWhenLoggedOut1 = await logoutUseCase.call();
          expect(logoutWhenLoggedOut1.isSuccess, isTrue);

          final logoutWhenLoggedOut2 = await logoutUseCase.call();
          expect(logoutWhenLoggedOut2.isSuccess, isTrue);
        },
      );
    });

    group('Data Validation Edge Cases', () {
      test('should handle very long inputs gracefully', () async {
        final longEmail = '${'a' * 100}@${'domain' * 10}.com';
        final longPassword = 'A1!${'x' * 200}';

        final signupResult = await signupUseCase.call(
          email: longEmail,
          password: longPassword,
          confirmPassword: longPassword,
        );

        // Should either succeed or fail gracefully (not crash)
        expect(signupResult, isA<Result<AuthUser>>());

        if (signupResult.isSuccess) {
          // If it succeeds, cleanup
          await logoutUseCase.call();
        }
      });

      test('should handle special characters in email and password', () async {
        const specialEmail = 'test+special.email@domain-name.co.jp';
        const specialPassword = 'P@ssw0rd!#\$%^&*()';

        final signupResult = await signupUseCase.call(
          email: specialEmail,
          password: specialPassword,
          confirmPassword: specialPassword,
        );

        // Should handle special characters appropriately
        expect(signupResult, isA<Result<AuthUser>>());

        if (signupResult.isSuccess) {
          // Test login with same credentials
          final loginResult = await loginUseCase.call(
            email: specialEmail,
            password: specialPassword,
          );
          expect(loginResult.isSuccess, isTrue);

          // Cleanup
          await logoutUseCase.call();
        }
      });
    });
  });
}
