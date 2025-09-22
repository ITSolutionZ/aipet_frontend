import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_current_user_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  group('GetCurrentUserUseCase', () {
    group('getCurrentUser', () {
      test('should return success with user when user is logged in', () async {
        // Arrange
        final mockUser = AuthUser(
          uid: 'user-123',
          email: 'test@example.com',
          displayName: 'Test User',
          isEmailVerified: true,
          creationTime: DateTime.now(),
        );

        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<Result<AuthUser?>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(mockUser));
        expect(result.message, equals('ユーザー情報を取得しました'));
        verify(mockRepository.getCurrentUser()).called(1);
      });

      test('should return success with null when user is not logged in', () async {
        // Arrange
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<Result<AuthUser?>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isNull);
        expect(result.message, equals('ログインしていません'));
        verify(mockRepository.getCurrentUser()).called(1);
      });

      test('should return failure when repository throws exception', () async {
        // Arrange
        when(mockRepository.getCurrentUser())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isA<Result<AuthUser?>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('ユーザー情報の取得に失敗しました'));
        verify(mockRepository.getCurrentUser()).called(1);
      });
    });

    group('isLoggedIn', () {
      test('should return true when user is logged in', () async {
        // Arrange
        final mockUser = AuthUser(
          uid: 'user-123',
          email: 'test@example.com',
          creationTime: DateTime.now(),
        );

        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);

        // Act
        final result = await useCase.isLoggedIn();

        // Assert
        expect(result, isA<Result<bool>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isTrue);
        expect(result.message, equals('ログイン状態を確認しました'));
        verify(mockRepository.getCurrentUser()).called(1);
      });

      test('should return false when user is not logged in', () async {
        // Arrange
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await useCase.isLoggedIn();

        // Assert
        expect(result, isA<Result<bool>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isFalse);
        expect(result.message, equals('ログイン状態を確認しました'));
        verify(mockRepository.getCurrentUser()).called(1);
      });

      test('should return failure when repository throws exception', () async {
        // Arrange
        when(mockRepository.getCurrentUser())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await useCase.isLoggedIn();

        // Assert
        expect(result, isA<Result<bool>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('ログイン状態の確認に失敗しました'));
        verify(mockRepository.getCurrentUser()).called(1);
      });
    });

    group('isEmailVerified', () {
      test('should return true when user email is verified', () async {
        // Arrange
        final mockUser = AuthUser(
          uid: 'user-123',
          email: 'test@example.com',
          isEmailVerified: true,
          creationTime: DateTime.now(),
        );

        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);

        // Act
        final result = await useCase.isEmailVerified();

        // Assert
        expect(result, isA<Result<bool>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isTrue);
        expect(result.message, equals('メール認証状態を確認しました'));
        verify(mockRepository.getCurrentUser()).called(1);
      });

      test('should return false when user email is not verified', () async {
        // Arrange
        final mockUser = AuthUser(
          uid: 'user-123',
          email: 'test@example.com',
          isEmailVerified: false,
          creationTime: DateTime.now(),
        );

        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);

        // Act
        final result = await useCase.isEmailVerified();

        // Assert
        expect(result, isA<Result<bool>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isFalse);
        expect(result.message, equals('メール認証状態を確認しました'));
        verify(mockRepository.getCurrentUser()).called(1);
      });

      test('should return failure when user is not logged in', () async {
        // Arrange
        when(mockRepository.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await useCase.isEmailVerified();

        // Assert
        expect(result, isA<Result<bool>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('ログインしていません'));
        verify(mockRepository.getCurrentUser()).called(1);
      });

      test('should return failure when repository throws exception', () async {
        // Arrange
        when(mockRepository.getCurrentUser())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await useCase.isEmailVerified();

        // Assert
        expect(result, isA<Result<bool>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('メール認証状態の確認に失敗しました'));
        verify(mockRepository.getCurrentUser()).called(1);
      });
    });
  });
}