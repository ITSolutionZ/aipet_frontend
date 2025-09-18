import 'package:flutter_test/flutter_test.dart';

import 'package:aipet_frontend/features/auth/domain/auth_token.dart';

void main() {
  group('AuthToken', () {
    late AuthToken testToken;

    setUp(() {
      testToken = AuthToken(
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
        tokenType: 'Bearer',
      );
    });

    group('constructor', () {
      test('should create token with all parameters', () {
        // Act
        final token = AuthToken(
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          expiresAt: DateTime(2024, 12, 31),
          tokenType: 'Bearer',
        );

        // Assert
        expect(token.accessToken, equals('access_token'));
        expect(token.refreshToken, equals('refresh_token'));
        expect(token.expiresAt, equals(DateTime(2024, 12, 31)));
        expect(token.tokenType, equals('Bearer'));
      });

      test('should create token with default tokenType', () {
        // Act
        final token = AuthToken(
          accessToken: 'access_token',
          expiresAt: DateTime(2024, 12, 31),
        );

        // Assert
        expect(token.accessToken, equals('access_token'));
        expect(token.refreshToken, isNull);
        expect(token.expiresAt, equals(DateTime(2024, 12, 31)));
        expect(token.tokenType, equals('Bearer'));
      });
    });

    group('isExpired', () {
      test('should return false for future expiration', () {
        // Arrange
        final futureToken = AuthToken(
          accessToken: 'token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        // Assert
        expect(futureToken.isExpired, isFalse);
      });

      test('should return true for past expiration', () {
        // Arrange
        final expiredToken = AuthToken(
          accessToken: 'token',
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Assert
        expect(expiredToken.isExpired, isTrue);
      });

      test('should return true for current time expiration', () {
        // Arrange
        final currentToken = AuthToken(
          accessToken: 'token',
          expiresAt: DateTime.now(),
        );

        // Assert
        expect(currentToken.isExpired, isTrue);
      });
    });

    group('isExpiringSoon', () {
      test('should return false for token expiring in more than 5 minutes', () {
        // Arrange
        final futureToken = AuthToken(
          accessToken: 'token',
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        );

        // Assert
        expect(futureToken.isExpiringSoon, isFalse);
      });

      test('should return true for token expiring in less than 5 minutes', () {
        // Arrange
        final soonExpiringToken = AuthToken(
          accessToken: 'token',
          expiresAt: DateTime.now().add(const Duration(minutes: 3)),
        );

        // Assert
        expect(soonExpiringToken.isExpiringSoon, isTrue);
      });

      test('should return true for token expiring in exactly 5 minutes', () {
        // Arrange
        final exactly5MinToken = AuthToken(
          accessToken: 'token',
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        );

        // Assert
        expect(exactly5MinToken.isExpiringSoon, isTrue);
      });

      test('should return true for expired token', () {
        // Arrange
        final expiredToken = AuthToken(
          accessToken: 'token',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        // Assert
        expect(expiredToken.isExpiringSoon, isTrue);
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedToken = testToken.copyWith(
          accessToken: 'new_access_token',
          tokenType: 'JWT',
        );

        // Assert
        expect(updatedToken.accessToken, equals('new_access_token'));
        expect(updatedToken.refreshToken, equals('test_refresh_token'));
        expect(
          updatedToken.expiresAt,
          equals(DateTime(2024, 12, 31, 23, 59, 59)),
        );
        expect(updatedToken.tokenType, equals('JWT'));
      });

      test('should keep original values when null provided', () {
        // Act
        final updatedToken = testToken.copyWith();

        // Assert
        expect(updatedToken.accessToken, equals('test_access_token'));
        expect(updatedToken.refreshToken, equals('test_refresh_token'));
        expect(
          updatedToken.expiresAt,
          equals(DateTime(2024, 12, 31, 23, 59, 59)),
        );
        expect(updatedToken.tokenType, equals('Bearer'));
      });

      test('should keep original refreshToken when null provided', () {
        // Act
        final updatedToken = testToken.copyWith(refreshToken: null);

        // Assert
        expect(updatedToken.refreshToken, equals('test_refresh_token'));
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        // Act
        final json = testToken.toJson();

        // Assert
        expect(json['accessToken'], equals('test_access_token'));
        expect(json['refreshToken'], equals('test_refresh_token'));
        expect(json['expiresAt'], equals('2024-12-31T23:59:59.000'));
        expect(json['tokenType'], equals('Bearer'));
      });

      test('should handle null refreshToken in JSON', () {
        // Arrange
        final tokenWithoutRefresh = AuthToken(
          accessToken: 'test_access_token',
          refreshToken: null,
          expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
          tokenType: 'Bearer',
        );

        // Act
        final json = tokenWithoutRefresh.toJson();

        // Assert
        expect(json['accessToken'], equals('test_access_token'));
        expect(json['refreshToken'], isNull);
        expect(json['expiresAt'], equals('2024-12-31T23:59:59.000'));
        expect(json['tokenType'], equals('Bearer'));
      });
    });

    group('fromJson', () {
      test('should create token from JSON correctly', () {
        // Arrange
        final json = {
          'accessToken': 'json_access_token',
          'refreshToken': 'json_refresh_token',
          'expiresAt': '2024-12-31T23:59:59.000',
          'tokenType': 'JWT',
        };

        // Act
        final token = AuthToken.fromJson(json);

        // Assert
        expect(token.accessToken, equals('json_access_token'));
        expect(token.refreshToken, equals('json_refresh_token'));
        expect(token.expiresAt, equals(DateTime(2024, 12, 31, 23, 59, 59)));
        expect(token.tokenType, equals('JWT'));
      });

      test('should create token with default tokenType when missing', () {
        // Arrange
        final json = {
          'accessToken': 'json_access_token',
          'refreshToken': 'json_refresh_token',
          'expiresAt': '2024-12-31T23:59:59.000',
        };

        // Act
        final token = AuthToken.fromJson(json);

        // Assert
        expect(token.accessToken, equals('json_access_token'));
        expect(token.refreshToken, equals('json_refresh_token'));
        expect(token.expiresAt, equals(DateTime(2024, 12, 31, 23, 59, 59)));
        expect(token.tokenType, equals('Bearer'));
      });

      test('should handle null refreshToken in JSON', () {
        // Arrange
        final json = {
          'accessToken': 'json_access_token',
          'refreshToken': null,
          'expiresAt': '2024-12-31T23:59:59.000',
          'tokenType': 'Bearer',
        };

        // Act
        final token = AuthToken.fromJson(json);

        // Assert
        expect(token.accessToken, equals('json_access_token'));
        expect(token.refreshToken, isNull);
        expect(token.expiresAt, equals(DateTime(2024, 12, 31, 23, 59, 59)));
        expect(token.tokenType, equals('Bearer'));
      });
    });

    group('equality', () {
      test('should be equal to identical token', () {
        // Arrange
        final identicalToken = AuthToken(
          accessToken: 'test_access_token',
          refreshToken: 'test_refresh_token',
          expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
          tokenType: 'Bearer',
        );

        // Assert
        expect(testToken, equals(identicalToken));
        expect(testToken.hashCode, equals(identicalToken.hashCode));
      });

      test('should not be equal to different token', () {
        // Arrange
        final differentToken = AuthToken(
          accessToken: 'different_access_token',
          refreshToken: 'test_refresh_token',
          expiresAt: DateTime(2024, 12, 31, 23, 59, 59),
          tokenType: 'Bearer',
        );

        // Assert
        expect(testToken, isNot(equals(differentToken)));
      });

      test('should not be equal to token with different refreshToken', () {
        // Arrange
        final differentRefreshToken = testToken.copyWith(
          refreshToken: 'different_refresh_token',
        );

        // Assert
        expect(testToken, isNot(equals(differentRefreshToken)));
      });

      test('should not be equal to token with different expiresAt', () {
        // Arrange
        final differentExpiresAt = testToken.copyWith(
          expiresAt: DateTime(2025, 1, 1),
        );

        // Assert
        expect(testToken, isNot(equals(differentExpiresAt)));
      });

      test('should not be equal to token with different tokenType', () {
        // Arrange
        final differentTokenType = testToken.copyWith(tokenType: 'JWT');

        // Assert
        expect(testToken, isNot(equals(differentTokenType)));
      });
    });

    group('round trip JSON conversion', () {
      test('should maintain data integrity through JSON conversion', () {
        // Act
        final json = testToken.toJson();
        final recreatedToken = AuthToken.fromJson(json);

        // Assert
        expect(recreatedToken, equals(testToken));
      });

      test('should handle null refreshToken through JSON conversion', () {
        // Arrange
        final tokenWithoutRefresh = testToken.copyWith(refreshToken: null);

        // Act
        final json = tokenWithoutRefresh.toJson();
        final recreatedToken = AuthToken.fromJson(json);

        // Assert
        expect(recreatedToken, equals(tokenWithoutRefresh));
      });
    });
  });
}
