import 'package:flutter_test/flutter_test.dart';

import 'package:aipet_frontend/features/auth/domain/auth_error.dart';
import 'package:aipet_frontend/features/auth/domain/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create success with value', () {
        // Act
        final result = Result.success('test_value');

        // Assert
        expect(result, isA<Success<String>>());
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.valueOrNull, equals('test_value'));
        expect(result.errorOrNull, isNull);
      });

      test('should return value with valueOr', () {
        // Arrange
        final result = Result.success('test_value');

        // Act
        final value = result.valueOr('default_value');

        // Assert
        expect(value, equals('test_value'));
      });
    });

    group('Failure', () {
      test('should create failure with error', () {
        // Arrange
        const error = NetworkError();

        // Act
        final result = Result.failure(error);

        // Assert
        expect(result, isA<Failure>());
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
        expect(result.valueOrNull, isNull);
        expect(result.errorOrNull, equals(error));
      });

      test('should return default value with valueOr', () {
        // Arrange
        const error = NetworkError();
        final result = Result.failure(error);

        // Act
        final value = result.valueOr('default_value');

        // Assert
        expect(value, equals('default_value'));
      });
    });

    group('fromError', () {
      test('should create failure from AuthError', () {
        // Arrange
        const error = ValidationError(field: 'email', reason: 'Invalid email');

        // Act
        final result = Result.fromError(error);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, equals(error));
      });

      test('should create failure from Exception', () {
        // Arrange
        final exception = Exception('Test exception');

        // Act
        final result = Result.fromError(exception);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<UnknownError>());
      });

      test('should create failure from string', () {
        // Arrange
        const errorString = 'Test error string';

        // Act
        final result = Result.fromError(errorString);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<UnknownError>());
      });
    });

    group('map', () {
      test('should transform value on success', () {
        // Arrange
        final result = Result.success(5);

        // Act
        final mappedResult = result.map((value) => value * 2);

        // Assert
        expect(mappedResult.isSuccess, isTrue);
        expect(mappedResult.valueOrNull, equals(10));
      });

      test('should preserve error on failure', () {
        // Arrange
        const error = NetworkError();
        final result = Result.failure(error);

        // Act
        final mappedResult = result.map((value) => value * 2);

        // Assert
        expect(mappedResult.isFailure, isTrue);
        expect(mappedResult.errorOrNull, equals(error));
      });
    });

    group('flatMap', () {
      test('should transform value on success', () {
        // Arrange
        final result = Result.success(5);

        // Act
        final flatMappedResult = result.flatMap(
          (value) => Result.success(value * 2),
        );

        // Assert
        expect(flatMappedResult.isSuccess, isTrue);
        expect(flatMappedResult.valueOrNull, equals(10));
      });

      test('should preserve error on failure', () {
        // Arrange
        const error = NetworkError();
        final result = Result.failure(error);

        // Act
        final flatMappedResult = result.flatMap(
          (value) => Result.success(value * 2),
        );

        // Assert
        expect(flatMappedResult.isFailure, isTrue);
        expect(flatMappedResult.errorOrNull, equals(error));
      });

      test('should handle nested failure', () {
        // Arrange
        final result = Result.success(5);
        const nestedError = ValidationError(
          field: 'test',
          reason: 'Test error',
        );

        // Act
        final flatMappedResult = result.flatMap(
          (value) => Result.failure(nestedError),
        );

        // Assert
        expect(flatMappedResult.isFailure, isTrue);
        expect(flatMappedResult.errorOrNull, equals(nestedError));
      });
    });

    group('mapError', () {
      test('should preserve value on success', () {
        // Arrange
        final result = Result.success('test');

        // Act
        final mappedResult = result.mapError((error) => const NetworkError());

        // Assert
        expect(mappedResult.isSuccess, isTrue);
        expect(mappedResult.valueOrNull, equals('test'));
      });

      test('should transform error on failure', () {
        // Arrange
        const originalError = ValidationError(
          field: 'email',
          reason: 'Invalid',
        );
        final result = Result.failure(originalError);

        // Act
        final mappedResult = result.mapError((error) => const NetworkError());

        // Assert
        expect(mappedResult.isFailure, isTrue);
        expect(mappedResult.errorOrNull, isA<NetworkError>());
      });
    });

    group('fold', () {
      test('should call onSuccess for success', () {
        // Arrange
        final result = Result.success('test_value');

        // Act
        final folded = result.fold(
          (value) => 'Success: $value',
          (error) => 'Error: ${error.message}',
        );

        // Assert
        expect(folded, equals('Success: test_value'));
      });

      test('should call onFailure for failure', () {
        // Arrange
        const error = NetworkError();
        final result = Result.failure(error);

        // Act
        final folded = result.fold(
          (value) => 'Success: $value',
          (error) => 'Error: ${error.message}',
        );

        // Assert
        expect(folded, equals('Error: インターネット接続を確認してください'));
      });
    });

    group('equality', () {
      test('should be equal for identical success values', () {
        // Arrange
        final result1 = Result.success('test');
        final result2 = Result.success('test');

        // Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal for different success values', () {
        // Arrange
        final result1 = Result.success('test1');
        final result2 = Result.success('test2');

        // Assert
        expect(result1, isNot(equals(result2)));
      });

      test('should be equal for identical failure errors', () {
        // Arrange
        const error = NetworkError();
        final result1 = Result.failure(error);
        final result2 = Result.failure(error);

        // Assert
        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('should not be equal for different failure errors', () {
        // Arrange
        const error1 = NetworkError();
        const error2 = ValidationError(field: 'test', reason: 'Test');
        final result1 = Result.failure(error1);
        final result2 = Result.failure(error2);

        // Assert
        expect(result1, isNot(equals(result2)));
      });
    });

    group('toString', () {
      test('should format success correctly', () {
        // Arrange
        final result = Result.success('test_value');

        // Act
        final string = result.toString();

        // Assert
        expect(string, equals('Success(test_value)'));
      });

      test('should format failure correctly', () {
        // Arrange
        const error = NetworkError();
        final result = Result.failure(error);

        // Act
        final string = result.toString();

        // Assert
        expect(string, contains('Failure'));
        expect(string, contains('NetworkError'));
      });
    });
  });

  group('ResultFuture extension', () {
    group('mapAsync', () {
      test('should transform value on success', () async {
        // Arrange
        final futureResult = Future.value(Result.success(5));

        // Act
        final mappedResult = await futureResult.mapAsync(
          (value) async => value * 2,
        );

        // Assert
        expect(mappedResult.isSuccess, isTrue);
        expect(mappedResult.valueOrNull, equals(10));
      });

      test('should preserve error on failure', () async {
        // Arrange
        const error = NetworkError();
        final futureResult = Future.value(Result.failure(error));

        // Act
        final mappedResult = await futureResult.mapAsync(
          (value) async => value * 2,
        );

        // Assert
        expect(mappedResult.isFailure, isTrue);
        expect(mappedResult.errorOrNull, equals(error));
      });
    });

    group('flatMapAsync', () {
      test('should transform value on success', () async {
        // Arrange
        final futureResult = Future.value(Result.success(5));

        // Act
        final flatMappedResult = await futureResult.flatMapAsync(
          (value) async => Result.success(value * 2),
        );

        // Assert
        expect(flatMappedResult.isSuccess, isTrue);
        expect(flatMappedResult.valueOrNull, equals(10));
      });

      test('should preserve error on failure', () async {
        // Arrange
        const error = NetworkError();
        final futureResult = Future.value(Result.failure(error));

        // Act
        final flatMappedResult = await futureResult.flatMapAsync(
          (value) async => Result.success(value * 2),
        );

        // Assert
        expect(flatMappedResult.isFailure, isTrue);
        expect(flatMappedResult.errorOrNull, equals(error));
      });
    });
  });

  group('ResultUtils', () {
    group('combine2', () {
      test('should combine two success results', () {
        // Arrange
        final result1 = Result.success('value1');
        final result2 = Result.success('value2');

        // Act
        final combined = ResultUtils.combine2(result1, result2);

        // Assert
        expect(combined.isSuccess, isTrue);
        expect(combined.valueOrNull, equals(('value1', 'value2')));
      });

      test('should return first failure when first result fails', () {
        // Arrange
        const error1 = NetworkError();
        const error2 = ValidationError(field: 'test', reason: 'Test');
        final result1 = Result.failure(error1);
        final result2 = Result.failure(error2);

        // Act
        final combined = ResultUtils.combine2(result1, result2);

        // Assert
        expect(combined.isFailure, isTrue);
        expect(combined.errorOrNull, equals(error1));
      });

      test('should return second failure when second result fails', () {
        // Arrange
        final result1 = Result.success('value1');
        const error2 = ValidationError(field: 'test', reason: 'Test');
        final result2 = Result.failure(error2);

        // Act
        final combined = ResultUtils.combine2(result1, result2);

        // Assert
        expect(combined.isFailure, isTrue);
        expect(combined.errorOrNull, equals(error2));
      });
    });

    group('combine3', () {
      test('should combine three success results', () {
        // Arrange
        final result1 = Result.success('value1');
        final result2 = Result.success('value2');
        final result3 = Result.success('value3');

        // Act
        final combined = ResultUtils.combine3(result1, result2, result3);

        // Assert
        expect(combined.isSuccess, isTrue);
        expect(combined.valueOrNull, equals(('value1', 'value2', 'value3')));
      });

      test('should return first failure when first result fails', () {
        // Arrange
        const error1 = NetworkError();
        final result1 = Result.failure(error1);
        final result2 = Result.success('value2');
        final result3 = Result.success('value3');

        // Act
        final combined = ResultUtils.combine3(result1, result2, result3);

        // Assert
        expect(combined.isFailure, isTrue);
        expect(combined.errorOrNull, equals(error1));
      });
    });
  });
}
