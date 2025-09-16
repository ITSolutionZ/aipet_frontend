import 'package:aipet_frontend/features/auth/domain/auth_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthError', () {
    group('NetworkError', () {
      test('should have correct message and code', () {
        // Act
        const error = NetworkError();

        // Assert
        expect(error.message, equals('インターネット接続を確認してください'));
        expect(error.code, equals('NETWORK_ERROR'));
      });
    });

    group('ValidationError', () {
      test('should have correct message and code', () {
        // Act
        const error = ValidationError(
          field: 'email',
          reason: 'メールアドレスが正しくありません',
        );

        // Assert
        expect(error.message, equals('メールアドレスが正しくありません'));
        expect(error.code, equals('VALIDATION_ERROR_email'));
      });

      test('should handle different fields', () {
        // Act
        const passwordError = ValidationError(
          field: 'password',
          reason: 'パスワードが短すぎます',
        );

        // Assert
        expect(passwordError.message, equals('パスワードが短すぎます'));
        expect(passwordError.code, equals('VALIDATION_ERROR_password'));
      });
    });

    group('AuthenticationError', () {
      test('should have correct message and code', () {
        // Act
        const error = AuthenticationError('ログインに失敗しました');

        // Assert
        expect(error.message, equals('ログインに失敗しました'));
        expect(error.code, equals('AUTH_ERROR'));
      });
    });

    group('ServerError', () {
      test('should have correct message and code without status code', () {
        // Act
        const error = ServerError();

        // Assert
        expect(error.message, equals('サーバーエラーが発生しました。しばらく経ってから再試行してください'));
        expect(error.code, equals('SERVER_ERROR_UNKNOWN'));
      });

      test('should have correct message and code with status code', () {
        // Act
        const error = ServerError(statusCode: 500);

        // Assert
        expect(error.message, equals('サーバーエラーが発生しました。しばらく経ってから再試行してください'));
        expect(error.code, equals('SERVER_ERROR_500'));
      });
    });

    group('ClientError', () {
      test('should have correct message and code', () {
        // Act
        const error = ClientError(statusCode: 400, reason: 'リクエストが無効です');

        // Assert
        expect(error.message, equals('リクエストが無効です'));
        expect(error.code, equals('CLIENT_ERROR_400'));
      });
    });

    group('TokenError', () {
      test('should have correct message and code for expired token', () {
        // Act
        const error = TokenError(TokenErrorType.expired);

        // Assert
        expect(error.message, equals('セッションが期限切れです。再度ログインしてください'));
        expect(error.code, equals('TOKEN_ERROR_EXPIRED'));
      });

      test('should have correct message and code for invalid token', () {
        // Act
        const error = TokenError(TokenErrorType.invalid);

        // Assert
        expect(error.message, equals('認証情報が不正です。再度ログインしてください'));
        expect(error.code, equals('TOKEN_ERROR_INVALID'));
      });

      test('should have correct message and code for missing token', () {
        // Act
        const error = TokenError(TokenErrorType.missing);

        // Assert
        expect(error.message, equals('ログインが必要です'));
        expect(error.code, equals('TOKEN_ERROR_MISSING'));
      });

      test('should have correct message and code for refresh failed', () {
        // Act
        const error = TokenError(TokenErrorType.refreshFailed);

        // Assert
        expect(error.message, equals('セッションの更新に失敗しました。再度ログインしてください'));
        expect(error.code, equals('TOKEN_ERROR_REFRESHFAILED'));
      });
    });

    group('StorageError', () {
      test('should have correct message and code', () {
        // Act
        const error = StorageError('save');

        // Assert
        expect(error.message, equals('データの保存に失敗しました'));
        expect(error.code, equals('STORAGE_ERROR_save'));
      });
    });

    group('UnknownError', () {
      test('should have correct message and code', () {
        // Act
        const error = UnknownError('Some unexpected error');

        // Assert
        expect(error.message, equals('予期しないエラーが発生しました'));
        expect(error.code, equals('UNKNOWN_ERROR'));
      });
    });

    group('AuthErrorMapper', () {
      test('should return same error if already AuthError', () {
        // Arrange
        const originalError = NetworkError();

        // Act
        final result = AuthErrorMapper.fromException(originalError);

        // Assert
        expect(result, equals(originalError));
      });

      test('should map network-related exceptions to NetworkError', () {
        // Act
        final result1 = AuthErrorMapper.fromException(
          Exception('Network error'),
        );
        final result2 = AuthErrorMapper.fromException(
          Exception('Connection failed'),
        );
        final result3 = AuthErrorMapper.fromException(
          Exception('Socket timeout'),
        );

        // Assert
        expect(result1, isA<NetworkError>());
        expect(result2, isA<NetworkError>());
        expect(result3, isA<NetworkError>());
      });

      test('should map HTTP-related exceptions to ServerError', () {
        // Act
        final result = AuthErrorMapper.fromException(
          Exception('HTTP 500 error'),
        );

        // Assert
        expect(result, isA<ServerError>());
      });

      test('should map unknown exceptions to UnknownError', () {
        // Act
        final result = AuthErrorMapper.fromException(
          Exception('Some random error'),
        );

        // Assert
        expect(result, isA<UnknownError>());
        expect(result.message, equals('予期しないエラーが発生しました'));
      });

      test('should handle string exceptions', () {
        // Act
        final result = AuthErrorMapper.fromException('String error');

        // Assert
        expect(result, isA<UnknownError>());
        expect(result.message, equals('予期しないエラーが発生しました'));
      });
    });
  });
}
