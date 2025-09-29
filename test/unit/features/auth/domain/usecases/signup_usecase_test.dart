import 'package:aipet_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:aipet_frontend/features/auth/domain/usecases/signup_usecase.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'signup_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignupUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignupUseCase(mockRepository);
  });

  group('SignupUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'Password123!';
    const testConfirmPassword = 'Password123!';
    const testDisplayName = 'Test User';

    group('Successful Signup', () {
      test(
        'should return success when signup is successful with display name',
        () async {
          // Arrange
          final mockUser = AuthUser(
            uid: 'user-123',
            email: testEmail,
            displayName: testDisplayName,
            isEmailVerified: false,
            creationTime: DateTime.now(),
          );

          final mockAuthResult = AuthResult.success(
            '会員登録が完了しました。確認メールを送信しました。',
            user: mockUser,
          );

          when(
            mockRepository.createUserWithEmailAndPassword(
              testEmail,
              testPassword,
            ),
          ).thenAnswer((_) async => mockAuthResult);
          when(
            mockRepository.updateUserProfile(displayName: testDisplayName),
          ).thenAnswer((_) async {});
          when(mockRepository.sendEmailVerification()).thenAnswer((_) async {});

          // Act
          final result = await useCase.call(
            email: testEmail,
            password: testPassword,
            confirmPassword: testConfirmPassword,
            displayName: testDisplayName,
          );

          // Assert
          expect(result, isA<Result<AuthUser>>());
          expect(result.isSuccess, isTrue);
          expect(result.data, equals(mockUser));
          expect(result.message, contains('会員登録が完了しました'));

          verify(
            mockRepository.createUserWithEmailAndPassword(
              testEmail,
              testPassword,
            ),
          ).called(1);
          verify(
            mockRepository.updateUserProfile(displayName: testDisplayName),
          ).called(1);
          verify(mockRepository.sendEmailVerification()).called(1);
        },
      );

      test(
        'should return success when signup is successful without display name',
        () async {
          // Arrange
          final mockUser = AuthUser(
            uid: 'user-123',
            email: testEmail,
            isEmailVerified: false,
            creationTime: DateTime.now(),
          );

          final mockAuthResult = AuthResult.success(
            '会員登録が完了しました。確認メールを送信しました。',
            user: mockUser,
          );

          when(
            mockRepository.createUserWithEmailAndPassword(
              testEmail,
              testPassword,
            ),
          ).thenAnswer((_) async => mockAuthResult);
          when(mockRepository.sendEmailVerification()).thenAnswer((_) async {});

          // Act
          final result = await useCase.call(
            email: testEmail,
            password: testPassword,
            confirmPassword: testConfirmPassword,
          );

          // Assert
          expect(result, isA<Result<AuthUser>>());
          expect(result.isSuccess, isTrue);
          expect(result.data, equals(mockUser));

          verify(
            mockRepository.createUserWithEmailAndPassword(
              testEmail,
              testPassword,
            ),
          ).called(1);
          verifyNever(
            mockRepository.updateUserProfile(
              displayName: anyNamed('displayName'),
            ),
          );
          verify(mockRepository.sendEmailVerification()).called(1);
        },
      );
    });

    group('Validation Failures', () {
      test('should return failure when email is empty', () async {
        // Act
        final result = await useCase.call(
          email: '',
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('全ての項目を入力してください'));
        verifyNever(mockRepository.createUserWithEmailAndPassword(any, any));
      });

      test('should return failure when password is empty', () async {
        // Act
        final result = await useCase.call(
          email: testEmail,
          password: '',
          confirmPassword: testConfirmPassword,
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('全ての項目を入力してください'));
        verifyNever(mockRepository.createUserWithEmailAndPassword(any, any));
      });

      test('should return failure when confirm password is empty', () async {
        // Act
        final result = await useCase.call(
          email: testEmail,
          password: testPassword,
          confirmPassword: '',
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('全ての項目を入力してください'));
        verifyNever(mockRepository.createUserWithEmailAndPassword(any, any));
      });

      test('should return failure when email format is invalid', () async {
        // Act
        final result = await useCase.call(
          email: 'invalid-email',
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('有効なメールアドレスを入力してください'));
        verifyNever(mockRepository.createUserWithEmailAndPassword(any, any));
      });

      test('should return failure when password is too short', () async {
        // Act
        final result = await useCase.call(
          email: testEmail,
          password: '123',
          confirmPassword: '123',
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('パスワードは8文字以上で入力してください'));
        verifyNever(mockRepository.createUserWithEmailAndPassword(any, any));
      });

      test(
        'should return failure when password is not strong enough',
        () async {
          // Act
          final result = await useCase.call(
            email: testEmail,
            password: 'weakpassword',
            confirmPassword: 'weakpassword',
          );

          // Assert
          expect(result, isA<Result<AuthUser>>());
          expect(result.isSuccess, isFalse);
          expect(result.message, equals('パスワードは英字、数字、特殊文字を含む必要があります'));
          verifyNever(mockRepository.createUserWithEmailAndPassword(any, any));
        },
      );

      test('should return failure when passwords do not match', () async {
        // Act
        final result = await useCase.call(
          email: testEmail,
          password: testPassword,
          confirmPassword: 'DifferentPassword123!',
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('パスワードが一致しません'));
        verifyNever(mockRepository.createUserWithEmailAndPassword(any, any));
      });
    });

    group('Repository Failures', () {
      test('should return failure when repository call fails', () async {
        // Arrange
        final mockAuthResult = AuthResult.failure('会員登録に失敗しました');

        when(
          mockRepository.createUserWithEmailAndPassword(
            testEmail,
            testPassword,
          ),
        ).thenAnswer((_) async => mockAuthResult);

        // Act
        final result = await useCase.call(
          email: testEmail,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('会員登録に失敗しました'));
        verify(
          mockRepository.createUserWithEmailAndPassword(
            testEmail,
            testPassword,
          ),
        ).called(1);
      });

      test('should handle exceptions gracefully', () async {
        // Arrange
        when(
          mockRepository.createUserWithEmailAndPassword(
            testEmail,
            testPassword,
          ),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await useCase.call(
          email: testEmail,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        );

        // Assert
        expect(result, isA<Result<AuthUser>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('会員登録に失敗しました'));
        verify(
          mockRepository.createUserWithEmailAndPassword(
            testEmail,
            testPassword,
          ),
        ).called(1);
      });
    });

    group('Password Validation', () {
      group('Email Validation', () {
        test('should pass for valid email formats', () async {
          const validEmails = [
            'user@example.com',
            'test.email@domain.co.jp',
            'user+tag@domain.org',
            'user_name@domain-name.com',
          ];

          for (final email in validEmails) {
            when(
              mockRepository.createUserWithEmailAndPassword(
                email,
                testPassword,
              ),
            ).thenAnswer(
              (_) async => AuthResult.success(
                'Success',
                user: AuthUser(
                  uid: 'user-123',
                  email: email,
                  creationTime: DateTime.now(),
                ),
              ),
            );
            when(
              mockRepository.sendEmailVerification(),
            ).thenAnswer((_) async {});

            final result = await useCase.call(
              email: email,
              password: testPassword,
              confirmPassword: testConfirmPassword,
            );

            expect(
              result.isSuccess,
              isTrue,
              reason: 'Email $email should be valid',
            );
          }
        });

        test('should fail for invalid email formats', () async {
          const invalidEmails = [
            'invalid',
            'invalid@',
            '@domain.com',
            'user@',
            'user@domain',
            'user space@domain.com',
          ];

          for (final email in invalidEmails) {
            final result = await useCase.call(
              email: email,
              password: testPassword,
              confirmPassword: testConfirmPassword,
            );

            expect(
              result.isSuccess,
              isFalse,
              reason: 'Email $email should be invalid',
            );
            expect(result.message, equals('有効なメールアドレスを入力してください'));
          }
        });
      });

      group('Strong Password Validation', () {
        test('should pass for strong passwords', () async {
          const strongPasswords = [
            'Password123!',
            'MyStr0ng@Pass',
            'C0mplex#P@ssw0rd',
            '1qA!2wS@3eD#',
          ];

          for (final password in strongPasswords) {
            when(
              mockRepository.createUserWithEmailAndPassword(
                testEmail,
                password,
              ),
            ).thenAnswer(
              (_) async => AuthResult.success(
                'Success',
                user: AuthUser(
                  uid: 'user-123',
                  email: testEmail,
                  creationTime: DateTime.now(),
                ),
              ),
            );
            when(
              mockRepository.sendEmailVerification(),
            ).thenAnswer((_) async {});

            final result = await useCase.call(
              email: testEmail,
              password: password,
              confirmPassword: password,
            );

            expect(
              result.isSuccess,
              isTrue,
              reason: 'Password $password should be strong enough',
            );
          }
        });

        test('should fail for weak passwords', () async {
          const weakPasswords = [
            'password', // no uppercase, no numbers, no special chars
            'PASSWORD', // no lowercase, no numbers, no special chars
            '12345678', // no letters, no special chars
            '!!!!!!!!!', // no letters, no numbers
            'Password', // no numbers, no special chars
            'Password123', // no special chars
          ];

          for (final password in weakPasswords) {
            final result = await useCase.call(
              email: testEmail,
              password: password,
              confirmPassword: password,
            );

            expect(
              result.isSuccess,
              isFalse,
              reason: 'Password $password should be weak',
            );
            expect(result.message, equals('パスワードは英字、数字、特殊文字を含む必要があります'));
          }
        });
      });
    });
  });
}
