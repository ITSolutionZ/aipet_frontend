import 'package:aipet_frontend/shared/services/encryption_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('EncryptionService Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await prefs.clear();
    });

    group('encryptAndSave', () {
      test('should encrypt and save data successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = 'sensitive_data';

        // Act
        final result = await EncryptionService.encryptAndSave(
          key,
          value,
          prefs,
        );

        // Assert
        expect(result, isTrue);
        expect(prefs.containsKey('encryption_key_$key'), isTrue);
      });

      test('should handle empty value', () async {
        // Arrange
        const key = 'test_key';
        const value = '';

        // Act
        final result = await EncryptionService.encryptAndSave(
          key,
          value,
          prefs,
        );

        // Assert
        expect(result, isTrue);
        expect(prefs.containsKey('encryption_key_$key'), isTrue);
      });

      test('should handle special characters', () async {
        // Arrange
        const key = 'test_key';
        const value = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

        // Act
        final result = await EncryptionService.encryptAndSave(
          key,
          value,
          prefs,
        );

        // Assert
        expect(result, isTrue);
        expect(prefs.containsKey('encryption_key_$key'), isTrue);
      });
    });

    group('decryptAndLoad', () {
      test('should decrypt and load data successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = 'sensitive_data';
        await EncryptionService.encryptAndSave(key, value, prefs);

        // Act
        final result = await EncryptionService.decryptAndLoad(key, prefs);

        // Assert
        expect(result, equals(value));
      });

      test('should return null for non-existent key', () async {
        // Arrange
        const key = 'non_existent_key';

        // Act
        final result = await EncryptionService.decryptAndLoad(key, prefs);

        // Assert
        expect(result, isNull);
      });

      test('should handle empty encrypted data', () async {
        // Arrange
        const key = 'test_key';
        const value = '';
        await EncryptionService.encryptAndSave(key, value, prefs);

        // Act
        final result = await EncryptionService.decryptAndLoad(key, prefs);

        // Assert
        expect(result, equals(value));
      });

      test('should handle special characters in decryption', () async {
        // Arrange
        const key = 'test_key';
        const value = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
        await EncryptionService.encryptAndSave(key, value, prefs);

        // Act
        final result = await EncryptionService.decryptAndLoad(key, prefs);

        // Assert
        expect(result, equals(value));
      });
    });

    group('deleteEncryptedData', () {
      test('should delete encrypted data successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = 'sensitive_data';
        await EncryptionService.encryptAndSave(key, value, prefs);
        expect(prefs.containsKey('encryption_key_$key'), isTrue);

        // Act
        final result = await EncryptionService.deleteEncryptedData(key, prefs);

        // Assert
        expect(result, isTrue);
        expect(prefs.containsKey('encryption_key_$key'), isFalse);
      });

      test('should handle deleting non-existent key', () async {
        // Arrange
        const key = 'non_existent_key';

        // Act
        final result = await EncryptionService.deleteEncryptedData(key, prefs);

        // Assert
        expect(result, isTrue);
      });
    });

    group('isEncrypted', () {
      test('should return true for encrypted data', () async {
        // Arrange
        const key = 'test_key';
        const value = 'sensitive_data';
        await EncryptionService.encryptAndSave(key, value, prefs);

        // Act
        final result = EncryptionService.isEncrypted(key, prefs);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for non-encrypted data', () async {
        // Arrange
        const key = 'test_key';

        // Act
        final result = EncryptionService.isEncrypted(key, prefs);

        // Assert
        expect(result, isFalse);
      });
    });

    group('clearAllEncryptedData', () {
      test('should clear all encrypted data', () async {
        // Arrange
        const key1 = 'test_key_1';
        const key2 = 'test_key_2';
        const value = 'sensitive_data';

        await EncryptionService.encryptAndSave(key1, value, prefs);
        await EncryptionService.encryptAndSave(key2, value, prefs);

        expect(prefs.containsKey('encryption_key_$key1'), isTrue);
        expect(prefs.containsKey('encryption_key_$key2'), isTrue);

        // Act
        final result = await EncryptionService.clearAllEncryptedData(prefs);

        // Assert
        expect(result, isTrue);
        expect(prefs.containsKey('encryption_key_$key1'), isFalse);
        expect(prefs.containsKey('encryption_key_$key2'), isFalse);
      });

      test('should handle clearing when no encrypted data exists', () async {
        // Act
        final result = await EncryptionService.clearAllEncryptedData(prefs);

        // Assert
        expect(result, isTrue);
      });
    });

    group('encryption consistency', () {
      test(
        'should maintain data integrity through encrypt-decrypt cycle',
        () async {
          // Arrange
          const key = 'test_key';
          const originalValue =
              'This is a test string with numbers 123 and symbols !@#';

          // Act
          await EncryptionService.encryptAndSave(key, originalValue, prefs);
          final decryptedValue = await EncryptionService.decryptAndLoad(
            key,
            prefs,
          );

          // Assert
          expect(decryptedValue, equals(originalValue));
        },
      );

      test('should handle multiple encrypt-decrypt cycles', () async {
        // Arrange
        const key = 'test_key';
        const originalValue = 'Test data';

        // Act & Assert
        for (int i = 0; i < 3; i++) {
          await EncryptionService.encryptAndSave(key, originalValue, prefs);
          final decryptedValue = await EncryptionService.decryptAndLoad(
            key,
            prefs,
          );
          expect(decryptedValue, equals(originalValue));
        }
      });

      test('should handle different keys independently', () async {
        // Arrange
        const key1 = 'key1';
        const key2 = 'key2';
        const value1 = 'value1';
        const value2 = 'value2';

        // Act
        await EncryptionService.encryptAndSave(key1, value1, prefs);
        await EncryptionService.encryptAndSave(key2, value2, prefs);

        final decryptedValue1 = await EncryptionService.decryptAndLoad(
          key1,
          prefs,
        );
        final decryptedValue2 = await EncryptionService.decryptAndLoad(
          key2,
          prefs,
        );

        // Assert
        expect(decryptedValue1, equals(value1));
        expect(decryptedValue2, equals(value2));
        expect(decryptedValue1, isNot(equals(decryptedValue2)));
      });
    });
  });
}
