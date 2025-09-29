import 'package:aipet_frontend/features/auth/domain/auth_constants.dart';
import 'package:aipet_frontend/features/auth/utils/auth_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidator', () {
    group('isValidEmail', () {
      test('should return true for valid email addresses', () {
        // Valid email addresses
        expect(AuthValidator.isValidEmail('test@example.com'), true);
        expect(AuthValidator.isValidEmail('user.name@domain.co.jp'), true);
        expect(AuthValidator.isValidEmail('test-tag@example.org'), true);
        expect(AuthValidator.isValidEmail('123@456.789'), true);
      });

      test('should return false for invalid email addresses', () {
        // Invalid email addresses
        expect(AuthValidator.isValidEmail(''), false);
        expect(AuthValidator.isValidEmail('invalid-email'), false);
        expect(AuthValidator.isValidEmail('@example.com'), false);
        expect(AuthValidator.isValidEmail('test@'), false);
        expect(AuthValidator.isValidEmail('test.example.com'), false);
        expect(AuthValidator.isValidEmail('test@.com'), false);
        expect(AuthValidator.isValidEmail('test@example.'), false);
      });
    });

    group('isValidPassword', () {
      test('should return true for valid passwords', () {
        // Valid passwords (6-128 characters)
        expect(AuthValidator.isValidPassword('123456'), true); // Minimum length
        expect(AuthValidator.isValidPassword('password123'), true);
        expect(AuthValidator.isValidPassword('P@ssw0rd!'), true);
        expect(
          AuthValidator.isValidPassword('a' * 128),
          true,
        ); // Maximum length
      });

      test('should return false for invalid passwords', () {
        // Too short
        expect(AuthValidator.isValidPassword(''), false);
        expect(
          AuthValidator.isValidPassword('12345'),
          false,
        ); // Less than 6 characters

        // Too long
        expect(
          AuthValidator.isValidPassword('a' * 129),
          false,
        ); // More than 128 characters
      });
    });

    group('isValidUsername', () {
      test('should return true for valid usernames', () {
        // Valid usernames (2-20 characters)
        expect(AuthValidator.isValidUsername('ab'), true); // Minimum length
        expect(AuthValidator.isValidUsername('testuser'), true);
        expect(AuthValidator.isValidUsername('user123'), true);
        expect(AuthValidator.isValidUsername('a' * 20), true); // Maximum length
      });

      test('should return false for invalid usernames', () {
        // Too short
        expect(AuthValidator.isValidUsername(''), false);
        expect(
          AuthValidator.isValidUsername('a'),
          false,
        ); // Less than 2 characters

        // Too long
        expect(
          AuthValidator.isValidUsername('a' * 21),
          false,
        ); // More than 20 characters
      });
    });

    group('doPasswordsMatch', () {
      test('should return true when passwords match', () {
        expect(
          AuthValidator.doPasswordsMatch('password123', 'password123'),
          true,
        );
        expect(AuthValidator.doPasswordsMatch('P@ssw0rd!', 'P@ssw0rd!'), true);
        expect(AuthValidator.doPasswordsMatch('123456', '123456'), true);
      });

      test('should return false when passwords do not match', () {
        expect(
          AuthValidator.doPasswordsMatch('password123', 'password456'),
          false,
        );
        expect(
          AuthValidator.doPasswordsMatch('password123', 'Password123'),
          false,
        );
        expect(AuthValidator.doPasswordsMatch('password123', ''), false);
        expect(AuthValidator.doPasswordsMatch('', 'password123'), false);
        expect(AuthValidator.doPasswordsMatch('', ''), false);
      });
    });

    group('isSupportedProvider', () {
      test('should return true for supported providers', () {
        expect(AuthValidator.isSupportedProvider('google'), true);
        expect(AuthValidator.isSupportedProvider('apple'), true);
        expect(AuthValidator.isSupportedProvider('line'), true);
        expect(
          AuthValidator.isSupportedProvider('Google'),
          true,
        ); // Case insensitive
        expect(
          AuthValidator.isSupportedProvider('APPLE'),
          true,
        ); // Case insensitive
        expect(
          AuthValidator.isSupportedProvider('Line'),
          true,
        ); // Case insensitive
      });

      test('should return false for unsupported providers', () {
        expect(AuthValidator.isSupportedProvider('facebook'), false);
        expect(AuthValidator.isSupportedProvider('twitter'), false);
        expect(AuthValidator.isSupportedProvider('github'), false);
        expect(AuthValidator.isSupportedProvider(''), false);
      });
    });

    group('getEmailErrorMessage', () {
      test('should return null for valid emails', () {
        expect(AuthValidator.getEmailErrorMessage('test@example.com'), null);
        expect(
          AuthValidator.getEmailErrorMessage('user.name@domain.co.jp'),
          null,
        );
      });

      test('should return required message for empty email', () {
        final result = AuthValidator.getEmailErrorMessage('');
        expect(result, AuthConstants.errorMessages['email_required']);
      });

      test('should return invalid message for invalid email', () {
        final result = AuthValidator.getEmailErrorMessage('invalid-email');
        expect(result, AuthConstants.errorMessages['email_invalid']);
      });
    });

    group('getPasswordErrorMessage', () {
      test('should return null for valid passwords', () {
        expect(AuthValidator.getPasswordErrorMessage('password123'), null);
        expect(AuthValidator.getPasswordErrorMessage('P@ssw0rd!'), null);
      });

      test('should return required message for empty password', () {
        final result = AuthValidator.getPasswordErrorMessage('');
        expect(result, AuthConstants.errorMessages['password_required']);
      });

      test('should return too short message for short password', () {
        final result = AuthValidator.getPasswordErrorMessage('12345');
        expect(result, AuthConstants.errorMessages['password_too_short']);
      });
    });

    group('getUsernameErrorMessage', () {
      test('should return null for valid usernames', () {
        expect(AuthValidator.getUsernameErrorMessage('testuser'), null);
        expect(AuthValidator.getUsernameErrorMessage('user123'), null);
      });

      test('should return required message for empty username', () {
        final result = AuthValidator.getUsernameErrorMessage('');
        expect(result, AuthConstants.errorMessages['username_required']);
      });

      test('should return too short message for short username', () {
        final result = AuthValidator.getUsernameErrorMessage('a');
        expect(result, AuthConstants.errorMessages['username_too_short']);
      });
    });

    group('getConfirmPasswordErrorMessage', () {
      test('should return null when passwords match', () {
        final result = AuthValidator.getConfirmPasswordErrorMessage(
          'password123',
          'password123',
        );
        expect(result, null);
      });

      test('should return required message for empty confirm password', () {
        final result = AuthValidator.getConfirmPasswordErrorMessage(
          'password123',
          '',
        );
        expect(result, AuthConstants.errorMessages['password_required']);
      });

      test('should return mismatch message when passwords do not match', () {
        final result = AuthValidator.getConfirmPasswordErrorMessage(
          'password123',
          'password456',
        );
        expect(result, AuthConstants.errorMessages['password_mismatch']);
      });
    });

    group('Edge cases and boundary testing', () {
      test('should handle email with special characters', () {
        expect(AuthValidator.isValidEmail('test-tag@example.com'), true);
        expect(AuthValidator.isValidEmail('test_tag@example.com'), true);
        expect(AuthValidator.isValidEmail('test.tag@example.com'), true);
      });

      test('should handle password with special characters', () {
        expect(AuthValidator.isValidPassword('P@ssw0rd!'), true);
        expect(AuthValidator.isValidPassword('password-with-dash'), true);
        expect(AuthValidator.isValidPassword('password_with_underscore'), true);
        expect(AuthValidator.isValidPassword('password.with.dots'), true);
      });

      test('should handle username with various characters', () {
        expect(AuthValidator.isValidUsername('user123'), true);
        expect(AuthValidator.isValidUsername('user-name'), true);
        expect(AuthValidator.isValidUsername('user_name'), true);
        expect(AuthValidator.isValidUsername('user.name'), true);
      });

      test('should handle very long strings', () {
        // Very long email (regex pattern allows long emails, so this is valid)
        final longEmail = 'a' * 100 + '@example.com';
        expect(AuthValidator.isValidEmail(longEmail), true);

        // Very long password (should be invalid)
        final longPassword = 'a' * 200;
        expect(AuthValidator.isValidPassword(longPassword), false);

        // Very long username (should be invalid)
        final longUsername = 'a' * 50;
        expect(AuthValidator.isValidUsername(longUsername), false);
      });

      test('should handle null and whitespace inputs', () {
        // These should be handled by the calling code, but let's test edge cases
        expect(AuthValidator.isValidEmail(' '), false);
        expect(AuthValidator.isValidPassword(' '), false);
        expect(AuthValidator.isValidUsername(' '), false);
      });
    });

    group('Constants validation', () {
      test('should use correct minimum password length', () {
        expect(AuthConstants.minPasswordLength, 6);
        expect(
          AuthValidator.isValidPassword(
            'a' * (AuthConstants.minPasswordLength - 1),
          ),
          false,
        );
        expect(
          AuthValidator.isValidPassword('a' * AuthConstants.minPasswordLength),
          true,
        );
      });

      test('should use correct maximum password length', () {
        expect(AuthConstants.maxPasswordLength, 128);
        expect(
          AuthValidator.isValidPassword('a' * AuthConstants.maxPasswordLength),
          true,
        );
        expect(
          AuthValidator.isValidPassword(
            'a' * (AuthConstants.maxPasswordLength + 1),
          ),
          false,
        );
      });

      test('should use correct minimum username length', () {
        expect(AuthConstants.minUsernameLength, 2);
        expect(
          AuthValidator.isValidUsername(
            'a' * (AuthConstants.minUsernameLength - 1),
          ),
          false,
        );
        expect(
          AuthValidator.isValidUsername('a' * AuthConstants.minUsernameLength),
          true,
        );
      });

      test('should use correct maximum username length', () {
        expect(AuthConstants.maxUsernameLength, 20);
        expect(
          AuthValidator.isValidUsername('a' * AuthConstants.maxUsernameLength),
          true,
        );
        expect(
          AuthValidator.isValidUsername(
            'a' * (AuthConstants.maxUsernameLength + 1),
          ),
          false,
        );
      });
    });
  });
}
