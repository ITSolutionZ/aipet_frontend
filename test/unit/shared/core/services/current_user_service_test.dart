import 'package:aipet_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/shared/core/services/current_user_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'current_user_service_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late CurrentUserService currentUserService;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    currentUserService = CurrentUserService(mockAuthRepository);
  });

  group('CurrentUserService', () {
    const String testUserId = 'test-user-123';
    const String testEmail = 'test@example.com';
    const String testDisplayName = 'Test User';

    final mockUser = UserEntity(
      uid: testUserId,
      email: testEmail,
      displayName: testDisplayName,
      isEmailVerified: true,
      createdAt: DateTime.now(),
    );

    group('getCurrentUserId', () {
      test('should return user ID when user is logged in', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);

        // Act
        final result = await currentUserService.getCurrentUserId();

        // Assert
        expect(result, isA<Result<String>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(testUserId));
        verify(mockAuthRepository.getCurrentUser()).called(1);
      });

      test('should return failure when user is not logged in', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await currentUserService.getCurrentUserId();

        // Assert
        expect(result, isA<Result<String>>());
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, contains('로그인된 사용자를 찾을 수 없습니다'));
      });

      test('should return failure when exception occurs', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await currentUserService.getCurrentUserId();

        // Assert
        expect(result, isA<Result<String>>());
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, contains('사용자 ID 조회에 실패했습니다'));
      });
    });

    group('isUserLoggedIn', () {
      test('should return true when user is logged in', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);

        // Act
        final result = await currentUserService.isUserLoggedIn();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when user is not logged in', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await currentUserService.isUserLoggedIn();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when exception occurs', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await currentUserService.isUserLoggedIn();

        // Assert
        expect(result, isFalse);
      });
    });

    group('getCurrentUserEmail', () {
      test('should return email when user has email', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);

        // Act
        final result = await currentUserService.getCurrentUserEmail();

        // Assert
        expect(result, isA<Result<String>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(testEmail));
      });

      test('should return failure when user has no email', () async {
        // Arrange
        final userWithoutEmail = UserEntity(
          uid: testUserId,
          email: null,
          displayName: testDisplayName,
          isEmailVerified: false,
          createdAt: DateTime.now(),
        );
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => userWithoutEmail);

        // Act
        final result = await currentUserService.getCurrentUserEmail();

        // Assert
        expect(result, isA<Result<String>>());
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, contains('사용자 이메일을 찾을 수 없습니다'));
      });
    });

    group('getCurrentUserDisplayName', () {
      test('should return display name when user has display name', () async {
        // Arrange
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);

        // Act
        final result = await currentUserService.getCurrentUserDisplayName();

        // Assert
        expect(result, isA<Result<String>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals(testDisplayName));
      });

      test('should extract name from email when no display name', () async {
        // Arrange
        final userWithoutDisplayName = UserEntity(
          uid: testUserId,
          email: testEmail,
          displayName: null,
          isEmailVerified: true,
          createdAt: DateTime.now(),
        );
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => userWithoutDisplayName);

        // Act
        final result = await currentUserService.getCurrentUserDisplayName();

        // Assert
        expect(result, isA<Result<String>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull, equals('test')); // From test@example.com
      });

      test('should return failure when no display name and no email', () async {
        // Arrange
        final userWithoutNameOrEmail = UserEntity(
          uid: testUserId,
          email: null,
          displayName: null,
          isEmailVerified: false,
          createdAt: DateTime.now(),
        );
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => userWithoutNameOrEmail);

        // Act
        final result = await currentUserService.getCurrentUserDisplayName();

        // Assert
        expect(result, isA<Result<String>>());
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, contains('사용자 이름을 찾을 수 없습니다'));
      });
    });

    group('signOut', () {
      test('should return success when sign out succeeds', () async {
        // Arrange
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => {});

        // Act
        final result = await currentUserService.signOut();

        // Assert
        expect(result, isA<Result<void>>());
        expect(result.isSuccess, isTrue);
        verify(mockAuthRepository.signOut()).called(1);
      });

      test('should return failure when sign out fails', () async {
        // Arrange
        when(mockAuthRepository.signOut())
            .thenThrow(Exception('Sign out failed'));

        // Act
        final result = await currentUserService.signOut();

        // Assert
        expect(result, isA<Result<void>>());
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, contains('로그아웃에 실패했습니다'));
      });
    });
  });
}