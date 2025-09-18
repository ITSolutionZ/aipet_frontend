import 'package:flutter_test/flutter_test.dart';

import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_summary.dart';
import 'package:aipet_frontend/shared/mock_data/test/test_data_helper.dart';

void main() {
  group('AiChatSummary', () {
    late AiChatSummary testSummary;

    setUp(() {
      testSummary = TestDataHelper.aiChatSummary;
    });

    group('constructor', () {
      test('should create summary with all parameters', () {
        // Act
        final summary = TestDataHelper.aiChatSummary;

        // Assert
        expect(summary.title, equals('ペットの健康相談'));
        expect(summary.content, equals('ペットの健康管理について相談し、定期的な健康診断と適切な食事の重要性について学びました。'));
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedSummary = testSummary.copyWith(title: 'Updated Title');

        // Assert
        expect(updatedSummary.title, equals('Updated Title'));
        expect(
          updatedSummary.content,
          equals('ペットの健康管理について相談し、定期的な健康診断と適切な食事の重要性について学びました。'),
        ); // unchanged
      });

      test('should keep original values when null provided', () {
        // Act
        final updatedSummary = testSummary.copyWith();

        // Assert
        expect(updatedSummary.title, equals(testSummary.title));
        expect(updatedSummary.content, equals(testSummary.content));
      });
    });

    group('edge cases', () {
      test('should handle empty title and content', () {
        // Act
        final emptySummary = testSummary.copyWith(title: '', content: '');

        // Assert
        expect(emptySummary.title, equals(''));
        expect(emptySummary.content, equals(''));
      });

      test('should handle very long title and content', () {
        // Arrange
        final longText = 'A' * 1000;

        // Act
        final longSummary = testSummary.copyWith(
          title: longText,
          content: longText,
        );

        // Assert
        expect(longSummary.title, equals(longText));
        expect(longSummary.content, equals(longText));
        expect(longSummary.title.length, equals(1000));
        expect(longSummary.content.length, equals(1000));
      });

      test('should handle special characters in title and content', () {
        // Arrange
        const specialText = 'スペシャル文字: !@#\$%^&*()🎉🚀';

        // Act
        final specialSummary = testSummary.copyWith(
          title: specialText,
          content: specialText,
        );

        // Assert
        expect(specialSummary.title, equals(specialText));
        expect(specialSummary.content, equals(specialText));
      });

      test('should handle multiline content', () {
        // Arrange
        const multilineContent = '''ペットの健康管理について相談しました。

主なポイント：
1. 定期的な健康診断
2. 適切な食事
3. 運動の重要性

これらの点を心がけることで、ペットの健康を維持できます。''';

        // Act
        final multilineSummary = testSummary.copyWith(
          content: multilineContent,
        );

        // Assert
        expect(multilineSummary.content, equals(multilineContent));
        expect(multilineSummary.content, contains('\n'));
        expect(multilineSummary.content, contains('1. 定期的な健康診断'));
        expect(multilineSummary.content, contains('2. 適切な食事'));
        expect(multilineSummary.content, contains('3. 運動の重要性'));
      });

      test('should handle content with emojis', () {
        // Arrange
        const emojiContent = 'ペットの健康管理について相談しました 🐕💊🏥 定期的な健康診断が重要です！';

        // Act
        final emojiSummary = testSummary.copyWith(content: emojiContent);

        // Assert
        expect(emojiSummary.content, equals(emojiContent));
        expect(emojiSummary.content, contains('🐕'));
        expect(emojiSummary.content, contains('💊'));
        expect(emojiSummary.content, contains('🏥'));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when title and content are same', () {
        // Arrange
        const sameSummary = AiChatSummary(
          title: 'ペットの健康相談',
          content: 'ペットの健康管理について相談し、定期的な健康診断と適切な食事の重要性について学びました。',
        );

        // Assert
        expect(testSummary, equals(sameSummary));
        expect(testSummary.hashCode, equals(sameSummary.hashCode));
      });

      test('should not be equal when title differs', () {
        // Arrange
        final differentTitleSummary = testSummary.copyWith(
          title: 'Different Title',
        );

        // Assert
        expect(testSummary, isNot(equals(differentTitleSummary)));
        expect(
          testSummary.hashCode,
          isNot(equals(differentTitleSummary.hashCode)),
        );
      });

      test('should not be equal when content differs', () {
        // Arrange
        final differentContentSummary = testSummary.copyWith(
          content: 'Different Content',
        );

        // Assert
        expect(testSummary, isNot(equals(differentContentSummary)));
        expect(
          testSummary.hashCode,
          isNot(equals(differentContentSummary.hashCode)),
        );
      });

      test('should be equal to itself', () {
        // Assert
        expect(testSummary, equals(testSummary));
        expect(testSummary.hashCode, equals(testSummary.hashCode));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testSummary.toString();

        // Assert
        expect(stringRepresentation, contains('AiChatSummary'));
        expect(stringRepresentation, contains('ペットの健康相談'));
        expect(stringRepresentation, contains('ペットの健康管理について相談し'));
      });
    });

    group('content analysis', () {
      test('should handle content with different lengths', () {
        // Test short content
        final shortSummary = testSummary.copyWith(content: '短い内容');
        expect(shortSummary.content, equals('短い内容'));

        // Test medium content
        final mediumSummary = testSummary.copyWith(
          content: '中程度の長さの内容です。これくらいの長さなら問題ないでしょう。',
        );
        expect(
          mediumSummary.content,
          equals('中程度の長さの内容です。これくらいの長さなら問題ないでしょう。'),
        );

        // Test long content
        final longContent = 'A' * 5000;
        final longSummary = testSummary.copyWith(content: longContent);
        expect(longSummary.content, equals(longContent));
        expect(longSummary.content.length, equals(5000));
      });

      test('should handle content with various characters', () {
        // Arrange
        const variousContent =
            'Mixed content: 日本語 English 123 !@# \$%^ &*() 🎉🚀';

        // Act
        final variousSummary = testSummary.copyWith(content: variousContent);

        // Assert
        expect(variousSummary.content, equals(variousContent));
        expect(variousSummary.content, contains('日本語'));
        expect(variousSummary.content, contains('English'));
        expect(variousSummary.content, contains('123'));
        expect(variousSummary.content, contains('!@#'));
        expect(variousSummary.content, contains('🎉'));
        expect(variousSummary.content, contains('🚀'));
      });
    });
  });
}
