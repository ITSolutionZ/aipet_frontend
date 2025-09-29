import 'package:aipet_frontend/features/home/presentation/controllers/home_dashboard_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'home_dashboard_controller_test.mocks.dart';

@GenerateMocks([WidgetRef])
void main() {
  group('HomeDashboardController', () {
    late HomeDashboardController controller;
    late MockWidgetRef mockRef;

    setUpAll(() async {
      // Test environment setup
    });

    setUp(() {
      mockRef = MockWidgetRef();
      controller = HomeDashboardController(mockRef);
    });

    group('basic functionality', () {
      test('should initialize correctly', () {
        // Assert
        expect(controller, isNotNull);
      });

      test('should have proper result types', () {
        // Act & Assert
        final successResult = Result.success('テスト成功');
        final failureResult = Result.failure('テスト失敗');

        expect(successResult.isSuccess, isTrue);
        expect(successResult.message, equals('テスト成功'));
        expect(successResult.data, isNull);

        expect(failureResult.isSuccess, isFalse);
        expect(failureResult.message, equals('テスト失敗'));
        expect(failureResult.data, isNull);
      });

      test('should create success result with data', () {
        // Act
        final result = Result.success('テスト成功', {'key': 'value'});

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('テスト成功'));
        expect(result.data, equals({'key': 'value'}));
      });
    });

    group('result creation', () {
      test('should create success result without data', () {
        // Act
        final result = Result.success('成功メッセージ');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('成功メッセージ'));
        expect(result.data, isNull);
      });

      test('should create failure result', () {
        // Act
        final result = Result.failure('エラーメッセージ');

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('エラーメッセージ'));
        expect(result.data, isNull);
      });
    });
  });
}
