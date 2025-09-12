import 'package:flutter_test/flutter_test.dart';

import 'package:aipet_frontend/features/auth/domain/auth_error.dart';

void main() {
  group('AuthError', () {
    group('NetworkError', () {
      test('should create NetworkError with correct message and code', () {
        // Arrange & Act
        const error = NetworkError();

        // Assert
        expect(error.message, equals('インターネット接続を確認してください'));
        expect(error.code, equals('NETWORK_ERROR'));
      });
    });

    group('ValidationError', () {
      test('should create ValidationError with field and reason', () {
        // Arrange & Act
        const error = ValidationError(
          field: 'email',
          reason: 'Invalid email format',
        );

        // Assert
        expect(error.field, equals('email'));
        expect(error.reason, equals('Invalid email format'));
        expect(error.message, equals('Invalid email format'));
        expect(error.code, equals('VALIDATION_ERROR_email'));
      });
    });

    group('AuthenticationError', () {
      test('should create AuthenticationError with reason', () {
        // Arrange & Act
        const error = AuthenticationError('Wrong credentials');

        // Assert
        expect(error.reason, equals('Wrong credentials'));
        expect(error.message, equals('Wrong credentials'));
        expect(error.code, equals('AUTH_ERROR'));
      });
    });

    group('ServerError', () {
      test('should create ServerError without status code', () {
        // Arrange & Act
        const error = ServerError();

        // Assert
        expect(error.statusCode, isNull);
        expect(error.message, equals('サーバーエラーが発生しました。しばらく経ってから再試行してください'));
        expect(error.code, equals('SERVER_ERROR_UNKNOWN'));
      });

      test('should create ServerError with status code', () {
        // Arrange & Act
        const error = ServerError(statusCode: 500);

        // Assert
        expect(error.statusCode, equals(500));
        expect(error.message, equals('サーバーエラーが発生しました。しばらく経ってから再試行してください'));
        expect(error.code, equals('SERVER_ERROR_500'));
      });
    });

    group('ClientError', () {
      test('should create ClientError with status code and reason', () {
        // Arrange & Act
        const error = ClientError(
          statusCode: 400,
          reason: 'Bad request',
        );

        // Assert
        expect(error.statusCode, equals(400));
        expect(error.reason, equals('Bad request'));
        expect(error.message, equals('Bad request'));
        expect(error.code, equals('CLIENT_ERROR_400'));
      });
    });

    group('TokenError', () {
      test('should create TokenError with expired type', () {
        // Arrange & Act
        const error = TokenError(TokenErrorType.expired);

        // Assert
        expect(error.type, equals(TokenErrorType.expired));
        expect(error.message, equals('セッションが期限切れです。再度ログインしてください'));
        expect(error.code, equals('TOKEN_ERROR_EXPIRED'));
      });

      test('should create TokenError with invalid type', () {
        // Arrange & Act
        const error = TokenError(TokenErrorType.invalid);

        // Assert
        expect(error.type, equals(TokenErrorType.invalid));
        expect(error.message, equals('認証情報が不正です。再度ログインしてください'));
        expect(error.code, equals('TOKEN_ERROR_INVALID'));
      });

      test('should create TokenError with missing type', () {
        // Arrange & Act
        const error = TokenError(TokenErrorType.missing);

        // Assert
        expect(error.type, equals(TokenErrorType.missing));
        expect(error.message, equals('ログインが必要です'));
        expect(error.code, equals('TOKEN_ERROR_MISSING'));
      });

      test('should create TokenError with refreshFailed type', () {
        // Arrange & Act
        const error = TokenError(TokenErrorType.refreshFailed);

        // Assert
        expect(error.type, equals(TokenErrorType.refreshFailed));
        expect(error.message, equals('セッションの更新に失敗しました。再度ログインしてください'));
        expect(error.code, equals('TOKEN_ERROR_REFRESHFAILED'));
      });
    });

    group('StorageError', () {
      test('should create StorageError with operation', () {
        // Arrange & Act
        const error = StorageError('write');

        // Assert
        expect(error.operation, equals('write'));
        expect(error.message, equals('データの保存に失敗しました'));
        expect(error.code, equals('STORAGE_ERROR_write'));
      });
    });

    group('UnknownError', () {
      test('should create UnknownError with details', () {
        // Arrange & Act
        const error = UnknownError('Something went wrong');

        // Assert
        expect(error.details, equals('Something went wrong'));
        expect(error.message, equals('予期しないエラーが発生しました'));
        expect(error.code, equals('UNKNOWN_ERROR'));
      });
    });

    group('AuthErrorMapper', () {
      test('should return same error if already AuthError', () {
        // Arrange
        const originalError = NetworkError();

        // Act
        final mappedError = AuthErrorMapper.fromException(originalError);

        // Assert
        expect(mappedError, equals(originalError));
      });

      test('should map network-related exceptions to NetworkError', () {
        // Act
        final networkError = AuthErrorMapper.fromException(Exception('Network connection failed'));
        final connectionError = AuthErrorMapper.fromException(Exception('Connection timeout'));
        final socketError = AuthErrorMapper.fromException(Exception('Socket exception'));

        // Assert
        expect(networkError, isA<NetworkError>());
        expect(connectionError, isA<NetworkError>());
        expect(socketError, isA<NetworkError>());
      });

      test('should map HTTP exceptions to ServerError', () {
        // Act
        final httpError = AuthErrorMapper.fromException(Exception('HTTP 500 error'));

        // Assert
        expect(httpError, isA<ServerError>());
      });

      test('should map unknown exceptions to UnknownError', () {
        // Act
        final unknownError = AuthErrorMapper.fromException(Exception('Some random error'));

        // Assert
        expect(unknownError, isA<UnknownError>());
        expect((unknownError as UnknownError).details, equals('Exception: Some random error'));
      });

      test('should handle non-Exception objects', () {
        // Act
        final stringError = AuthErrorMapper.fromException('String error');

        // Assert
        expect(stringError, isA<UnknownError>());
        expect((stringError as UnknownError).details, equals('String error'));
      });
    });
  });
}