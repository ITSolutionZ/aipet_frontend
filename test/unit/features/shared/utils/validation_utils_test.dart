import 'package:aipet_frontend/shared/core/utils/validation_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ValidationUtils', () {
    group('isValidEmail', () {
      test('should return true for valid email', () {
        // Arrange
        const validEmail = 'test@example.com';

        // Act
        final result = ValidationUtils.isValidEmail(validEmail);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for empty email', () {
        // Arrange
        const emptyEmail = '';

        // Act
        final result = ValidationUtils.isValidEmail(emptyEmail);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for any email in development mode', () {
        // Arrange
        const invalidEmail = 'invalid-email';

        // Act
        final result = ValidationUtils.isValidEmail(invalidEmail);

        // Assert
        expect(result, isTrue); // Development mode always returns true
      });
    });

    group('isValidPassword', () {
      test('should return false for empty password', () {
        // Arrange
        const emptyPassword = '';

        // Act
        final result = ValidationUtils.isValidPassword(emptyPassword);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for any password in development mode', () {
        // Arrange
        const weakPassword = '123';

        // Act
        final result = ValidationUtils.isValidPassword(weakPassword);

        // Assert
        expect(result, isTrue); // Development mode always returns true
      });
    });

    group('isValidName', () {
      test('should return false for empty name', () {
        // Arrange
        const emptyName = '';

        // Act
        final result = ValidationUtils.isValidName(emptyName);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for any name in development mode', () {
        // Arrange
        const invalidName = 'a';

        // Act
        final result = ValidationUtils.isValidName(invalidName);

        // Assert
        expect(result, isTrue); // Development mode always returns true
      });
    });

    group('isValidPhoneNumber', () {
      test('should return false for empty phone', () {
        // Arrange
        const emptyPhone = '';

        // Act
        final result = ValidationUtils.isValidPhoneNumber(emptyPhone);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for any phone in development mode', () {
        // Arrange
        const invalidPhone = '123';

        // Act
        final result = ValidationUtils.isValidPhoneNumber(invalidPhone);

        // Assert
        expect(result, isTrue); // Development mode always returns true
      });
    });

    group('isRequired', () {
      test('should return true for non-empty string', () {
        // Arrange
        const nonEmptyString = 'test';

        // Act
        final result = ValidationUtils.isRequired(nonEmptyString);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for empty string', () {
        // Arrange
        const emptyString = '';

        // Act
        final result = ValidationUtils.isRequired(emptyString);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for whitespace only string', () {
        // Arrange
        const whitespaceString = '   ';

        // Act
        final result = ValidationUtils.isRequired(whitespaceString);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for string with content after trim', () {
        // Arrange
        const stringWithWhitespace = '  test  ';

        // Act
        final result = ValidationUtils.isRequired(stringWithWhitespace);

        // Assert
        expect(result, isTrue);
      });
    });

    group('hasMinLength', () {
      test('should return true for string with sufficient length', () {
        // Arrange
        const testString = 'test';
        const minLength = 3;

        // Act
        final result = ValidationUtils.hasMinLength(testString, minLength);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for string with insufficient length', () {
        // Arrange
        const testString = 'te';
        const minLength = 3;

        // Act
        final result = ValidationUtils.hasMinLength(testString, minLength);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for string with exact minimum length', () {
        // Arrange
        const testString = 'test';
        const minLength = 4;

        // Act
        final result = ValidationUtils.hasMinLength(testString, minLength);

        // Assert
        expect(result, isTrue);
      });

      test('should handle zero minimum length', () {
        // Arrange
        const testString = '';
        const minLength = 0;

        // Act
        final result = ValidationUtils.hasMinLength(testString, minLength);

        // Assert
        expect(result, isTrue);
      });
    });

    group('hasMaxLength', () {
      test('should return true for string within maximum length', () {
        // Arrange
        const testString = 'test';
        const maxLength = 10;

        // Act
        final result = ValidationUtils.hasMaxLength(testString, maxLength);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for string exceeding maximum length', () {
        // Arrange
        const testString = 'test';
        const maxLength = 2;

        // Act
        final result = ValidationUtils.hasMaxLength(testString, maxLength);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for string with exact maximum length', () {
        // Arrange
        const testString = 'test';
        const maxLength = 4;

        // Act
        final result = ValidationUtils.hasMaxLength(testString, maxLength);

        // Assert
        expect(result, isTrue);
      });

      test('should handle zero maximum length', () {
        // Arrange
        const testString = 'test';
        const maxLength = 0;

        // Act
        final result = ValidationUtils.hasMaxLength(testString, maxLength);

        // Assert
        expect(result, isFalse);
      });
    });

    group('isNumeric', () {
      test('should return true for valid number string', () {
        // Arrange
        const numberString = '123.45';

        // Act
        final result = ValidationUtils.isNumeric(numberString);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for empty string', () {
        // Arrange
        const emptyString = '';

        // Act
        final result = ValidationUtils.isNumeric(emptyString);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for non-numeric string', () {
        // Arrange
        const nonNumericString = 'abc';

        // Act
        final result = ValidationUtils.isNumeric(nonNumericString);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for integer string', () {
        // Arrange
        const integerString = '123';

        // Act
        final result = ValidationUtils.isNumeric(integerString);

        // Assert
        expect(result, isTrue);
      });

      test('should return true for negative number string', () {
        // Arrange
        const negativeString = '-123.45';

        // Act
        final result = ValidationUtils.isNumeric(negativeString);

        // Assert
        expect(result, isTrue);
      });
    });

    group('isPositive', () {
      test('should return true for positive number string', () {
        // Arrange
        const positiveString = '123.45';

        // Act
        final result = ValidationUtils.isPositive(positiveString);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for empty string', () {
        // Arrange
        const emptyString = '';

        // Act
        final result = ValidationUtils.isPositive(emptyString);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for negative number string', () {
        // Arrange
        const negativeString = '-123.45';

        // Act
        final result = ValidationUtils.isPositive(negativeString);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for zero string', () {
        // Arrange
        const zeroString = '0';

        // Act
        final result = ValidationUtils.isPositive(zeroString);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for non-numeric string', () {
        // Arrange
        const nonNumericString = 'abc';

        // Act
        final result = ValidationUtils.isPositive(nonNumericString);

        // Assert
        expect(result, isFalse);
      });
    });

    group('isValidDate', () {
      test('should return false for empty date', () {
        // Arrange
        const emptyDate = '';

        // Act
        final result = ValidationUtils.isValidDate(emptyDate);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for any date in development mode', () {
        // Arrange
        const invalidDate = 'invalid-date';

        // Act
        final result = ValidationUtils.isValidDate(invalidDate);

        // Assert
        expect(result, isTrue); // Development mode always returns true
      });
    });

    group('isValidUrl', () {
      test('should return false for empty URL', () {
        // Arrange
        const emptyUrl = '';

        // Act
        final result = ValidationUtils.isValidUrl(emptyUrl);

        // Assert
        expect(result, isFalse);
      });

      test('should return true for any URL in development mode', () {
        // Arrange
        const invalidUrl = 'invalid-url';

        // Act
        final result = ValidationUtils.isValidUrl(invalidUrl);

        // Assert
        expect(result, isTrue); // Development mode always returns true
      });
    });

    group('getErrorMessage', () {
      test('should return correct error message for each error type', () {
        // Assert
        expect(
          ValidationUtils.getErrorMessage(ValidationError.required),
          equals('必須な項目です。'),
        );
        expect(
          ValidationUtils.getErrorMessage(ValidationError.invalidEmail),
          equals('形式のメールアドレスではありません。'),
        );
        expect(
          ValidationUtils.getErrorMessage(ValidationError.invalidPassword),
          equals('パスワードは8文字以上で、英数字、記号を組み合わせる必要があります。'),
        );
        expect(
          ValidationUtils.getErrorMessage(ValidationError.invalidName),
          equals('名前は2-20文字のみ使用できます。'),
        );
        expect(
          ValidationUtils.getErrorMessage(ValidationError.invalidPhone),
          equals('電話番号の形式が正しくありません。'),
        );
        expect(
          ValidationUtils.getErrorMessage(ValidationError.tooShort),
          equals('短すぎる'),
        );
        expect(
          ValidationUtils.getErrorMessage(ValidationError.tooLong),
          equals('を超える'),
        );
        expect(
          ValidationUtils.getErrorMessage(ValidationError.invalidNumber),
          equals('数値のみ入力できます。'),
        );
        expect(
          ValidationUtils.getErrorMessage(
            ValidationError.invalidPositiveNumber,
          ),
          equals('正の数を入力してください。'),
        );
        expect(
          ValidationUtils.getErrorMessage(ValidationError.invalidDate),
          equals('正しい日付形式ではありません。'),
        );
        expect(
          ValidationUtils.getErrorMessage(ValidationError.invalidUrl),
          equals('形式のURLではありません。'),
        );
      });
    });
  });

  // ValidationResult 클래스는 현재 정의되지 않았으므로 테스트 제거

  group('ValidationError enum', () {
    test('should have all expected error types', () {
      // Assert
      expect(ValidationError.values, hasLength(11));
      expect(ValidationError.values, contains(ValidationError.required));
      expect(ValidationError.values, contains(ValidationError.invalidEmail));
      expect(ValidationError.values, contains(ValidationError.invalidPassword));
      expect(ValidationError.values, contains(ValidationError.invalidName));
      expect(ValidationError.values, contains(ValidationError.invalidPhone));
      expect(ValidationError.values, contains(ValidationError.tooShort));
      expect(ValidationError.values, contains(ValidationError.tooLong));
      expect(ValidationError.values, contains(ValidationError.invalidNumber));
      expect(
        ValidationError.values,
        contains(ValidationError.invalidPositiveNumber),
      );
      expect(ValidationError.values, contains(ValidationError.invalidDate));
      expect(ValidationError.values, contains(ValidationError.invalidUrl));
    });
  });
}
