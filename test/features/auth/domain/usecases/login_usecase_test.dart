import 'package:aipet_frontend/features/auth/domain/domain.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('LoginUseCase', () {
    late LoginUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LoginUseCase(mockRepository);
    });

    test('should return success when login is successful', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const expectedUser = AuthUser(
        id: 'user_123',
        email: email,
        name: 'Test User',
        isEmailVerified: true,
      );

      when(
        mockRepository.signInWithEmailAndPassword(email, password),
      ).thenAnswer(
        (_) async => ResultFactory.success(expectedUser, 'ログインに成功しました'),
      );

      // Act
      final result = await useCase.call(email: email, password: password);

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, expectedUser);
      expect(result.dataOrNull?.email, email);
      verify(
        mockRepository.signInWithEmailAndPassword(email, password),
      ).called(1);
    });

    test('should return failure when credentials are invalid', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrongpassword';

      when(
        mockRepository.signInWithEmailAndPassword(email, password),
      ).thenAnswer((_) async => ResultFactory.failure<AuthUser>('認証に失敗しました'));

      // Act
      final result = await useCase.call(email: email, password: password);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, '認証に失敗しました');
    });

    test('should return failure when email is empty', () async {
      // Arrange
      const email = '';
      const password = 'password123';

      // Act
      final result = await useCase.call(email: email, password: password);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('メールアドレスを入力してください'));
    });

    test('should return failure when password is empty', () async {
      // Arrange
      const email = 'test@example.com';
      const password = '';

      // Act
      final result = await useCase.call(email: email, password: password);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('パスワードを入力してください'));
    });

    test('should handle network error', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      when(
        mockRepository.signInWithEmailAndPassword(email, password),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.call(email: email, password: password);

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('ネットワークエラーが発生しました'));
    });

    test('should validate email format', () async {
      // Arrange
      const invalidEmail = 'invalid-email';
      const password = 'password123';

      // Act
      final result = await useCase.call(
        email: invalidEmail,
        password: password,
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('有効なメールアドレスを入力してください'));
    });
  });
}
