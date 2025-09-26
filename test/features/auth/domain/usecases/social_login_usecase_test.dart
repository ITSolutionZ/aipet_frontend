import 'package:aipet_frontend/features/auth/domain/domain.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'social_login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('SocialLoginUseCase', () {
    late SocialLoginUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = SocialLoginUseCase(mockRepository);
    });

    test('should return success when Google login is successful', () async {
      // Arrange
      const expectedUser = AuthUser(
        id: 'google_user_123',
        email: 'user@gmail.com',
        name: 'Google User',
        isEmailVerified: true,
      );

      when(mockRepository.signInWithGoogle()).thenAnswer(
        (_) async => ResultFactory.success(expectedUser, 'Googleログインに成功しました'),
      );

      // Act
      final result = await useCase.loginWithGoogle();

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, expectedUser);
      expect(result.dataOrNull?.email, 'user@gmail.com');
      verify(mockRepository.signInWithGoogle()).called(1);
    });

    test('should return success when Apple login is successful', () async {
      // Arrange
      const expectedUser = AuthUser(
        id: 'apple_user_123',
        email: 'user@icloud.com',
        name: 'Apple User',
        isEmailVerified: true,
      );

      when(mockRepository.signInWithApple()).thenAnswer(
        (_) async => ResultFactory.success(expectedUser, 'Appleログインに成功しました'),
      );

      // Act
      final result = await useCase.loginWithApple();

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, expectedUser);
      expect(result.dataOrNull?.email, 'user@icloud.com');
      verify(mockRepository.signInWithApple()).called(1);
    });

    test('should return success when LINE login is successful', () async {
      // Arrange
      const expectedUser = AuthUser(
        id: 'line_user_123',
        email: 'user@line.com',
        name: 'LINE User',
        isEmailVerified: true,
      );

      when(mockRepository.signInWithLine()).thenAnswer(
        (_) async => ResultFactory.success(expectedUser, 'LINEログインに成功しました'),
      );

      // Act
      final result = await useCase.loginWithLine();

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, expectedUser);
      expect(result.dataOrNull?.email, 'user@line.com');
      verify(mockRepository.signInWithLine()).called(1);
    });

    test('should return failure when Google login fails', () async {
      // Arrange
      when(mockRepository.signInWithGoogle()).thenAnswer(
        (_) async => ResultFactory.failure<AuthUser>('Googleログインに失敗しました'),
      );

      // Act
      final result = await useCase.loginWithGoogle();

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, 'Googleログインに失敗しました');
    });

    test('should return failure when Apple login fails', () async {
      // Arrange
      when(mockRepository.signInWithApple()).thenAnswer(
        (_) async => ResultFactory.failure<AuthUser>('Appleログインに失敗しました'),
      );

      // Act
      final result = await useCase.loginWithApple();

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, 'Appleログインに失敗しました');
    });

    test('should return failure when LINE login fails', () async {
      // Arrange
      when(mockRepository.signInWithLine()).thenAnswer(
        (_) async => ResultFactory.failure<AuthUser>('LINEログインに失敗しました'),
      );

      // Act
      final result = await useCase.loginWithLine();

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, 'LINEログインに失敗しました');
    });

    test('should handle network error during Google login', () async {
      // Arrange
      when(
        mockRepository.signInWithGoogle(),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.loginWithGoogle();

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('ネットワークエラーが発生しました'));
    });

    test('should handle network error during Apple login', () async {
      // Arrange
      when(
        mockRepository.signInWithApple(),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.loginWithApple();

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('ネットワークエラーが発生しました'));
    });

    test('should handle network error during LINE login', () async {
      // Arrange
      when(
        mockRepository.signInWithLine(),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await useCase.loginWithLine();

      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('ネットワークエラーが発生しました'));
    });
  });
}
