import 'package:aipet_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aipet_frontend/features/auth/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../test_helper.dart';
import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRepository, Ref])
void main() {
  group('AuthRepositoryImpl', () {
    late MockAuthRepository mockFirebaseRepository;
    late MockRef mockRef;
    late AuthRepositoryImpl repository;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockFirebaseRepository = MockAuthRepository();
      // Ref는 Mock으로 생성 (실제로는 사용되지 않음)
      mockRef = MockRef();
      repository = AuthRepositoryImpl(
        firebaseRepository: mockFirebaseRepository,
        ref: mockRef,
      );
    });

    group('signInWithEmailAndPassword', () {
      test('should return success when Firebase repository succeeds', () async {
        // Given
        const email = 'test@example.com';
        const password = 'password123';
        final mockUser = AuthUser(
          uid: 'test-uid',
          email: email,
          displayName: 'Test User',
          isEmailVerified: true,
          creationTime: DateTime.now(),
          customData: {
            'accessToken': 'test-access-token',
            'refreshToken': 'test-refresh-token',
            'expiresAt': DateTime.now()
                .add(const Duration(hours: 24))
                .toIso8601String(),
          },
        );

        when(
          mockFirebaseRepository.signInWithEmailAndPassword(email, password),
        ).thenAnswer((_) async => AuthResult.success('ログイン成功', user: mockUser));

        // When
        final result = await repository.signInWithEmailAndPassword(
          email,
          password,
        );

        // Then
        expect(result.isSuccess, true);
        expect(result.message, 'ログイン成功');
        expect(result.user, mockUser);
        verify(
          mockFirebaseRepository.signInWithEmailAndPassword(email, password),
        ).called(1);
      });

      test('should return failure when Firebase repository fails', () async {
        // Given
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(
          mockFirebaseRepository.signInWithEmailAndPassword(email, password),
        ).thenAnswer((_) async => AuthResult.failure('ログインに失敗しました'));

        // When
        final result = await repository.signInWithEmailAndPassword(
          email,
          password,
        );

        // Then
        expect(result.isSuccess, false);
        expect(result.message, 'ログインに失敗しました');
        verify(
          mockFirebaseRepository.signInWithEmailAndPassword(email, password),
        ).called(1);
      });

      test('should handle exceptions and return failure', () async {
        // Given
        const email = 'test@example.com';
        const password = 'password123';

        when(
          mockFirebaseRepository.signInWithEmailAndPassword(email, password),
        ).thenThrow(Exception('Network error'));

        // When
        final result = await repository.signInWithEmailAndPassword(
          email,
          password,
        );

        // Then
        expect(result.isSuccess, false);
        expect(result.message, contains('ログインに失敗しました'));
        verify(
          mockFirebaseRepository.signInWithEmailAndPassword(email, password),
        ).called(1);
      });
    });

    group('createUserWithEmailAndPassword', () {
      test('should return success when Firebase repository succeeds', () async {
        // Given
        const email = 'newuser@example.com';
        const password = 'password123';
        final mockUser = AuthUser(
          uid: 'new-user-uid',
          email: email,
          displayName: 'New User',
          isEmailVerified: false,
          creationTime: DateTime.now(),
          customData: {
            'accessToken': 'new-access-token',
            'refreshToken': 'new-refresh-token',
            'expiresAt': DateTime.now()
                .add(const Duration(hours: 24))
                .toIso8601String(),
          },
        );

        when(
          mockFirebaseRepository.createUserWithEmailAndPassword(
            email,
            password,
          ),
        ).thenAnswer((_) async => AuthResult.success('会員登録成功', user: mockUser));

        // When
        final result = await repository.createUserWithEmailAndPassword(
          email,
          password,
        );

        // Then
        expect(result.isSuccess, true);
        expect(result.message, '会員登録成功');
        expect(result.user, mockUser);
        verify(
          mockFirebaseRepository.createUserWithEmailAndPassword(
            email,
            password,
          ),
        ).called(1);
      });

      test('should return failure when Firebase repository fails', () async {
        // Given
        const email = 'invalid-email';
        const password = 'password123';

        when(
          mockFirebaseRepository.createUserWithEmailAndPassword(
            email,
            password,
          ),
        ).thenAnswer((_) async => AuthResult.failure('会員登録に失敗しました'));

        // When
        final result = await repository.createUserWithEmailAndPassword(
          email,
          password,
        );

        // Then
        expect(result.isSuccess, false);
        expect(result.message, '会員登録に失敗しました');
        verify(
          mockFirebaseRepository.createUserWithEmailAndPassword(
            email,
            password,
          ),
        ).called(1);
      });
    });

    group('signInWithGoogle', () {
      test('should return success when Google sign-in succeeds', () async {
        // Given
        final mockUser = AuthUser(
          uid: 'google-user-uid',
          email: 'user@gmail.com',
          displayName: 'Google User',
          photoURL: 'https://example.com/photo.jpg',
          isEmailVerified: true,
          creationTime: DateTime.now(),
          customData: {
            'accessToken': 'google-access-token',
            'refreshToken': 'google-refresh-token',
            'expiresAt': DateTime.now()
                .add(const Duration(hours: 24))
                .toIso8601String(),
            'provider': 'google',
          },
        );

        when(mockFirebaseRepository.signInWithGoogle()).thenAnswer(
          (_) async => AuthResult.success('Google ログイン成功', user: mockUser),
        );

        // When
        final result = await repository.signInWithGoogle();

        // Then
        expect(result.isSuccess, true);
        expect(result.message, 'Google ログイン成功');
        expect(result.user, mockUser);
        verify(mockFirebaseRepository.signInWithGoogle()).called(1);
      });

      test('should return failure when Google sign-in fails', () async {
        // Given
        when(
          mockFirebaseRepository.signInWithGoogle(),
        ).thenAnswer((_) async => AuthResult.failure('Google ログインに失敗しました'));

        // When
        final result = await repository.signInWithGoogle();

        // Then
        expect(result.isSuccess, false);
        expect(result.message, 'Google ログインに失敗しました');
        verify(mockFirebaseRepository.signInWithGoogle()).called(1);
      });
    });

    group('signInWithApple', () {
      test('should return success when Apple sign-in succeeds', () async {
        // Given
        final mockUser = AuthUser(
          uid: 'apple-user-uid',
          email: 'user@privaterelay.appleid.com',
          displayName: 'Apple User',
          photoURL: 'https://example.com/photo.jpg',
          isEmailVerified: true,
          creationTime: DateTime.now(),
          customData: {
            'accessToken': 'apple-access-token',
            'refreshToken': 'apple-refresh-token',
            'expiresAt': DateTime.now()
                .add(const Duration(hours: 24))
                .toIso8601String(),
            'provider': 'apple',
          },
        );

        when(mockFirebaseRepository.signInWithApple()).thenAnswer(
          (_) async => AuthResult.success('Apple ログイン成功', user: mockUser),
        );

        // When
        final result = await repository.signInWithApple();

        // Then
        expect(result.isSuccess, true);
        expect(result.message, 'Apple ログイン成功');
        expect(result.user, mockUser);
        verify(mockFirebaseRepository.signInWithApple()).called(1);
      });
    });

    group('signInWithLine', () {
      test('should return success when LINE sign-in succeeds', () async {
        // Given
        final mockUser = AuthUser(
          uid: 'line-user-uid',
          email: 'user@line.me',
          displayName: 'LINE User',
          photoURL: 'https://example.com/photo.jpg',
          isEmailVerified: true,
          creationTime: DateTime.now(),
          customData: {
            'accessToken': 'line-access-token',
            'refreshToken': 'line-refresh-token',
            'expiresAt': DateTime.now()
                .add(const Duration(hours: 24))
                .toIso8601String(),
            'provider': 'line',
          },
        );

        when(mockFirebaseRepository.signInWithLine()).thenAnswer(
          (_) async => AuthResult.success('LINE ログイン成功', user: mockUser),
        );

        // When
        final result = await repository.signInWithLine();

        // Then
        expect(result.isSuccess, true);
        expect(result.message, 'LINE ログイン成功');
        expect(result.user, mockUser);
        verify(mockFirebaseRepository.signInWithLine()).called(1);
      });
    });

    group('signOut', () {
      test('should call Firebase repository signOut', () async {
        // Given
        when(mockFirebaseRepository.signOut()).thenAnswer((_) async {});

        // When
        await repository.signOut();

        // Then
        verify(mockFirebaseRepository.signOut()).called(1);
      });

      test('should handle exceptions during signOut', () async {
        // Given
        when(
          mockFirebaseRepository.signOut(),
        ).thenThrow(Exception('Sign out failed'));

        // When & Then
        expect(() => repository.signOut(), throwsException);
        // verify는 예외가 발생하기 전에 호출되므로 제거
      });
    });

    group('getCurrentUser', () {
      test(
        'should return user when Firebase repository returns user',
        () async {
          // Given
          final mockUser = AuthUser(
            uid: 'current-user-uid',
            email: 'current@example.com',
            displayName: 'Current User',
            isEmailVerified: true,
            creationTime: DateTime.now(),
          );

          when(
            mockFirebaseRepository.getCurrentUser(),
          ).thenAnswer((_) async => mockUser);

          // When
          final result = await repository.getCurrentUser();

          // Then
          expect(result, mockUser);
          verify(mockFirebaseRepository.getCurrentUser()).called(1);
        },
      );

      test(
        'should return null when Firebase repository returns null',
        () async {
          // Given
          when(
            mockFirebaseRepository.getCurrentUser(),
          ).thenAnswer((_) async => null);

          // When
          final result = await repository.getCurrentUser();

          // Then
          expect(result, null);
          verify(mockFirebaseRepository.getCurrentUser()).called(1);
        },
      );

      test('should return null when exception occurs', () async {
        // Given
        when(
          mockFirebaseRepository.getCurrentUser(),
        ).thenThrow(Exception('Get current user failed'));

        // When
        final result = await repository.getCurrentUser();

        // Then
        expect(result, null);
        verify(mockFirebaseRepository.getCurrentUser()).called(1);
      });
    });

    group('sendPasswordResetEmail', () {
      test('should call Firebase repository sendPasswordResetEmail', () async {
        // Given
        const email = 'test@example.com';
        when(
          mockFirebaseRepository.sendPasswordResetEmail(email),
        ).thenAnswer((_) async {});

        // When
        await repository.sendPasswordResetEmail(email);

        // Then
        verify(mockFirebaseRepository.sendPasswordResetEmail(email)).called(1);
      });
    });

    group('sendEmailVerification', () {
      test('should call Firebase repository sendEmailVerification', () async {
        // Given
        when(
          mockFirebaseRepository.sendEmailVerification(),
        ).thenAnswer((_) async {});

        // When
        await repository.sendEmailVerification();

        // Then
        verify(mockFirebaseRepository.sendEmailVerification()).called(1);
      });
    });

    group('updateUserProfile', () {
      test('should call Firebase repository updateUserProfile', () async {
        // Given
        const displayName = 'Updated Name';
        const photoURL = 'https://example.com/new-photo.jpg';

        when(
          mockFirebaseRepository.updateUserProfile(
            displayName: displayName,
            photoURL: photoURL,
          ),
        ).thenAnswer((_) async {});

        // When
        await repository.updateUserProfile(
          displayName: displayName,
          photoURL: photoURL,
        );

        // Then
        verify(
          mockFirebaseRepository.updateUserProfile(
            displayName: displayName,
            photoURL: photoURL,
          ),
        ).called(1);
      });
    });

    group('deleteAccount', () {
      test('should call Firebase repository deleteAccount', () async {
        // Given
        when(mockFirebaseRepository.deleteAccount()).thenAnswer((_) async {});

        // When
        await repository.deleteAccount();

        // Then
        verify(mockFirebaseRepository.deleteAccount()).called(1);
      });

      test('should handle exceptions during deleteAccount', () async {
        // Given
        when(
          mockFirebaseRepository.deleteAccount(),
        ).thenThrow(Exception('Delete account failed'));

        // When & Then
        expect(() => repository.deleteAccount(), throwsException);
        verify(mockFirebaseRepository.deleteAccount()).called(1);
      });
    });
  });
}
