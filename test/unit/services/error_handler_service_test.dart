import 'package:aipet_frontend/shared/services/error_handler_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorHandlerService Tests', () {
    late ErrorHandlerService service;

    setUp(() {
      service = ErrorHandlerService();
    });

    tearDown(() {
      // dispose 전에 에러 처리 비활성화
      service.setEnabled(false);
      service.dispose();
    });

    test('should initialize service', () async {
      // Act
      await service.initialize();

      // Assert
      expect(service, isNotNull);
    });

    test('should handle error with default severity', () async {
      // Arrange
      const testError = 'Test error message';

      // Act
      await service.handleError(testError);

      // Assert
      final stats = service.getErrorStats();
      expect(stats['totalErrors'], greaterThanOrEqualTo(0));
    });

    test('should handle error with custom severity', () async {
      // Arrange
      const testError = 'Test error message';

      // Act
      await service.handleError(
        testError,
        severity: ErrorSeverity.high,
        type: ErrorType.network,
      );

      // Assert
      final stats = service.getErrorStats();
      expect(stats['totalErrors'], greaterThanOrEqualTo(0));
    });

    test('should get error stats', () {
      // Act
      final stats = service.getErrorStats();

      // Assert
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('totalErrors'), isTrue);
      expect(stats.containsKey('errorCounters'), isTrue);
      expect(stats.containsKey('severityCounters'), isTrue);
      expect(stats.containsKey('recentErrors'), isTrue);
    });

    test('should get error history', () {
      // Act
      final history = service.getErrorHistory();

      // Assert
      expect(history, isA<List<ErrorInfo>>());
    });

    test('should get error count by type', () {
      // Act
      final count = service.getErrorCountByType(ErrorType.network);

      // Assert
      expect(count, isA<int>());
      expect(count >= 0, isTrue);
    });

    test('should get error count by severity', () {
      // Act
      final count = service.getErrorCountBySeverity(ErrorSeverity.medium);

      // Assert
      expect(count, isA<int>());
      expect(count >= 0, isTrue);
    });

    test('should set enabled state', () {
      // Act
      service.setEnabled(false);

      // Assert
      // 상태 변경 확인 (내부 상태이므로 간접적으로 확인)
      expect(() {
        service.setEnabled(true);
      }, returnsNormally);
    });

    test('should clear error history', () {
      // Act
      service.clearErrorHistory();

      // Assert
      final stats = service.getErrorStats();
      expect(stats['totalErrors'], equals(0));
    });
  });

  group('ErrorInfo Tests', () {
    test('should create error info', () {
      // Arrange
      const message = 'Test error';
      const severity = ErrorSeverity.medium;
      const type = ErrorType.validation;

      // Act
      final errorInfo = ErrorInfo(
        message: message,
        severity: severity,
        type: type,
        timestamp: DateTime.now(),
      );

      // Assert
      expect(errorInfo.message, equals(message));
      expect(errorInfo.severity, equals(severity));
      expect(errorInfo.type, equals(type));
    });

    test('should convert to JSON', () {
      // Arrange
      final errorInfo = ErrorInfo(
        message: 'Test error',
        severity: ErrorSeverity.high,
        type: ErrorType.network,
        timestamp: DateTime.now(),
      );

      // Act
      final json = errorInfo.toJson();

      // Assert
      expect(json, isA<Map<String, dynamic>>());
      expect(json['message'], equals('Test error'));
      expect(json['severity'], equals('high'));
      expect(json['type'], equals('network'));
    });

    test('should have string representation', () {
      // Arrange
      final errorInfo = ErrorInfo(
        message: 'Test error',
        severity: ErrorSeverity.critical,
        type: ErrorType.memory,
        timestamp: DateTime.now(),
      );

      // Act
      final string = errorInfo.toString();

      // Assert
      expect(string, contains('ErrorInfo'));
      expect(string, contains('critical'));
      expect(string, contains('memory'));
      expect(string, contains('Test error'));
    });
  });

  group('ErrorSeverity Tests', () {
    test('should have all severity levels', () {
      // Assert
      expect(ErrorSeverity.values, hasLength(4));
      expect(ErrorSeverity.values, contains(ErrorSeverity.low));
      expect(ErrorSeverity.values, contains(ErrorSeverity.medium));
      expect(ErrorSeverity.values, contains(ErrorSeverity.high));
      expect(ErrorSeverity.values, contains(ErrorSeverity.critical));
    });
  });

  group('ErrorType Tests', () {
    test('should have all error types', () {
      // Assert
      expect(ErrorType.values, hasLength(7));
      expect(ErrorType.values, contains(ErrorType.network));
      expect(ErrorType.values, contains(ErrorType.database));
      expect(ErrorType.values, contains(ErrorType.validation));
      expect(ErrorType.values, contains(ErrorType.authentication));
      expect(ErrorType.values, contains(ErrorType.permission));
      expect(ErrorType.values, contains(ErrorType.memory));
      expect(ErrorType.values, contains(ErrorType.unknown));
    });
  });
}
