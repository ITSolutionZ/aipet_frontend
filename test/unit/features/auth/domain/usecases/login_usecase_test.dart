import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    group('Email/Password Login', () {
      test('should return success when login is successful', () async {
        // Arrange
        final mockUser = AuthUser(
          uid: 'user-123',
          email: testEmail,
          displayName: 'Test User',
          isEmailVerified: true,
          creationTime: DateTime.now(),
        );

        final mockAuthResult = AuthResult.success(
          'ログインが完了しました',
          user: mockUser,
        );

        when(
          mockRepository.signInWithEmailAndPassword(testEmail, testPassword),
        ).thenAnswer((_) async => mockAuthResult);

        // Act
        final result = await useCase.call(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(mockUser));
        expect(result.message, equals('ログインが完了しました'));
        verify(
          mockRepository.signInWithEmailAndPassword(testEmail, testPassword),
        ).called(1);
      });

      test('should return failure when email is empty', () async {
        // Act
        final result = await useCase.call(email: '', password: testPassword);

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('メールアドレスとパスワードを入力してください'));
        verifyNever(mockRepository.signInWithEmailAndPassword(any, any));
      });

      test('should return failure when password is empty', () async {
        // Act
        final result = await useCase.call(email: testEmail, password: '');

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('メールアドレスとパスワードを入力してください'));
        verifyNever(mockRepository.signInWithEmailAndPassword(any, any));
      });

      test('should return failure when email format is invalid', () async {
        // Act
        final result = await useCase.call(
          email: 'invalid-email',
          password: testPassword,
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('有効なメールアドレスを入力してください'));
        verifyNever(mockRepository.signInWithEmailAndPassword(any, any));
      });

      test('should return failure when password is too short', () async {
        // Act
        final result = await useCase.call(email: testEmail, password: '123');

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('パスワードは6文字以上で入力してください'));
        verifyNever(mockRepository.signInWithEmailAndPassword(any, any));
      });

      test('should return failure when repository call fails', () async {
        // Arrange
        final mockAuthResult = AuthResult.failure('認証に失敗しました');

        when(
          mockRepository.signInWithEmailAndPassword(testEmail, testPassword),
        ).thenAnswer((_) async => mockAuthResult);

        // Act
        final result = await useCase.call(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('認証に失敗しました'));
        verify(
          mockRepository.signInWithEmailAndPassword(testEmail, testPassword),
        ).called(1);
      });
    });

    group('Social Login', () {
      test('should return success when Google login is successful', () async {
        // Arrange
        final mockUser = AuthUser(
          uid: 'google-user-123',
          email: 'user@gmail.com',
          displayName: 'Google User',
          isEmailVerified: true,
          creationTime: DateTime.now(),
        );

        final mockAuthResult = AuthResult.success(
          'Googleログインが完了しました',
          user: mockUser,
        );

        when(
          mockRepository.signInWithGoogle(),
        ).thenAnswer((_) async => mockAuthResult);

        // Act
        final result = await useCase.loginWithGoogle();

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(mockUser));
        expect(result.message, equals('Googleログインが完了しました'));
        verify(mockRepository.signInWithGoogle()).called(1);
      });

      test('should return success when Apple login is successful', () async {
        // Arrange
        final mockUser = AuthUser(
          uid: 'apple-user-123',
          email: 'user@privaterelay.appleid.com',
          displayName: 'Apple User',
          isEmailVerified: true,
          creationTime: DateTime.now(),
        );

        final mockAuthResult = AuthResult.success(
          'Appleログインが完了しました',
          user: mockUser,
        );

        when(
          mockRepository.signInWithApple(),
        ).thenAnswer((_) async => mockAuthResult);

        // Act
        final result = await useCase.loginWithApple();

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(mockUser));
        expect(result.message, equals('Appleログインが完了しました'));
        verify(mockRepository.signInWithApple()).called(1);
      });

      test('should return success when LINE login is successful', () async {
        // Arrange
        final mockUser = AuthUser(
          uid: 'line-user-123',
          email: 'user@line.me',
          displayName: 'LINE User',
          isEmailVerified: true,
          creationTime: DateTime.now(),
        );

        final mockAuthResult = AuthResult.success(
          'LINEログインが完了しました',
          user: mockUser,
        );

        when(
          mockRepository.signInWithLine(),
        ).thenAnswer((_) async => mockAuthResult);

        // Act
        final result = await useCase.loginWithLine();

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(mockUser));
        expect(result.message, equals('LINEログインが完了しました'));
        verify(mockRepository.signInWithLine()).called(1);
      });

      test('should return failure when social login fails', () async {
        // Arrange
        final mockAuthResult = AuthResult.failure('Googleログインに失敗しました');

        when(
          mockRepository.signInWithGoogle(),
        ).thenAnswer((_) async => mockAuthResult);

        // Act
        final result = await useCase.loginWithGoogle();

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('Googleログインに失敗しました'));
        verify(mockRepository.signInWithGoogle()).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle exceptions gracefully', () async {
        // Arrange
        when(
          mockRepository.signInWithEmailAndPassword(testEmail, testPassword),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await useCase.call(
          email: testEmail,
          password: testPassword,
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('ログインに失敗しました'));
        verify(
          mockRepository.signInWithEmailAndPassword(testEmail, testPassword),
        ).called(1);
      });
    });
  });
}
