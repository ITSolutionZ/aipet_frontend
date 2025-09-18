import 'package:flutter_test/flutter_test.dart';

import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_summary_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';

void main() {
  group('AiChatSummaryEntity', () {
    late AiChatSummaryEntity testChatSummary;
    late List<AiMessageEntity> testMessages;

    setUp(() {
      testMessages = [
        AiMessageEntity(
          id: 'msg-1',
          content: 'ペットの健康について教えて',
          type: MessageType.user,
          timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        ),
        AiMessageEntity(
          id: 'msg-2',
          content: 'ペットの健康管理は定期的な健康診断と適切な食事が重要です。',
          type: MessageType.assistant,
          timestamp: DateTime(2024, 1, 1, 10, 1, 0),
        ),
      ];

      testChatSummary = AiChatSummaryEntity(
        id: 'summary-1',
        title: 'ペットの健康相談',
        summary: 'ペットの健康管理について相談し、定期的な健康診断と適切な食事の重要性について学びました。',
        category: 'health',
        petId: 'pet-123',
        petName: 'テストペット',
        messages: testMessages,
        createdAt: DateTime(2024, 1, 1, 10, 0, 0),
        updatedAt: DateTime(2024, 1, 2, 10, 0, 0),
        messageCount: 2,
        hasFavorites: true,
      );
    });

    group('constructor', () {
      test('should create chat summary with all parameters', () {
        // Act
        final chatSummary = AiChatSummaryEntity(
          id: 'test-summary',
          title: 'テストタイトル',
          summary: 'テストサマリー',
          category: 'test-category',
          petId: 'test-pet',
          petName: 'テストペット',
          messages: testMessages,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          messageCount: 5,
          hasFavorites: false,
        );

        // Assert
        expect(chatSummary.id, equals('test-summary'));
        expect(chatSummary.title, equals('テストタイトル'));
        expect(chatSummary.summary, equals('テストサマリー'));
        expect(chatSummary.category, equals('test-category'));
        expect(chatSummary.petId, equals('test-pet'));
        expect(chatSummary.petName, equals('テストペット'));
        expect(chatSummary.messages, equals(testMessages));
        expect(chatSummary.createdAt, equals(DateTime(2024, 1, 1)));
        expect(chatSummary.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(chatSummary.messageCount, equals(5));
        expect(chatSummary.hasFavorites, isFalse);
      });

      test('should create chat summary with required parameters only', () {
        // Act
        final chatSummary = AiChatSummaryEntity(
          id: 'simple-summary',
          title: 'シンプルタイトル',
          summary: 'シンプルサマリー',
          category: 'simple-category',
          messages: [],
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          messageCount: 0,
        );

        // Assert
        expect(chatSummary.id, equals('simple-summary'));
        expect(chatSummary.title, equals('シンプルタイトル'));
        expect(chatSummary.summary, equals('シンプルサマリー'));
        expect(chatSummary.category, equals('simple-category'));
        expect(chatSummary.petId, isNull);
        expect(chatSummary.petName, isNull);
        expect(chatSummary.messages, isEmpty);
        expect(chatSummary.createdAt, equals(DateTime(2024, 1, 1)));
        expect(chatSummary.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(chatSummary.messageCount, equals(0));
        expect(chatSummary.hasFavorites, isFalse);
      });

      test('should default hasFavorites to false', () {
        // Act
        final chatSummary = AiChatSummaryEntity(
          id: 'default-summary',
          title: 'デフォルトタイトル',
          summary: 'デフォルトサマリー',
          category: 'default-category',
          messages: [],
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          messageCount: 0,
        );

        // Assert
        expect(chatSummary.hasFavorites, isFalse);
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedChatSummary = testChatSummary.copyWith(
          title: 'Updated Title',
          hasFavorites: false,
          messageCount: 10,
        );

        // Assert
        expect(updatedChatSummary.id, equals('summary-1')); // unchanged
        expect(updatedChatSummary.title, equals('Updated Title'));
        expect(
          updatedChatSummary.summary,
          equals('ペットの健康管理について相談し、定期的な健康診断と適切な食事の重要性について学びました。'),
        ); // unchanged
        expect(updatedChatSummary.category, equals('health')); // unchanged
        expect(updatedChatSummary.petId, equals('pet-123')); // unchanged
        expect(updatedChatSummary.petName, equals('テストペット')); // unchanged
        expect(updatedChatSummary.messages, equals(testMessages)); // unchanged
        expect(
          updatedChatSummary.createdAt,
          equals(DateTime(2024, 1, 1, 10, 0, 0)),
        ); // unchanged
        expect(
          updatedChatSummary.updatedAt,
          equals(DateTime(2024, 1, 2, 10, 0, 0)),
        ); // unchanged
        expect(updatedChatSummary.messageCount, equals(10));
        expect(updatedChatSummary.hasFavorites, isFalse);
      });

      test('should keep original values when null provided', () {
        // Act
        final updatedChatSummary = testChatSummary.copyWith();

        // Assert
        expect(updatedChatSummary.id, equals(testChatSummary.id));
        expect(updatedChatSummary.title, equals(testChatSummary.title));
        expect(updatedChatSummary.summary, equals(testChatSummary.summary));
        expect(updatedChatSummary.category, equals(testChatSummary.category));
        expect(updatedChatSummary.petId, equals(testChatSummary.petId));
        expect(updatedChatSummary.petName, equals(testChatSummary.petName));
        expect(updatedChatSummary.messages, equals(testChatSummary.messages));
        expect(updatedChatSummary.createdAt, equals(testChatSummary.createdAt));
        expect(updatedChatSummary.updatedAt, equals(testChatSummary.updatedAt));
        expect(
          updatedChatSummary.messageCount,
          equals(testChatSummary.messageCount),
        );
        expect(
          updatedChatSummary.hasFavorites,
          equals(testChatSummary.hasFavorites),
        );
      });
    });

    group('edge cases', () {
      test('should handle empty title and summary', () {
        // Act
        final emptyChatSummary = testChatSummary.copyWith(
          title: '',
          summary: '',
        );

        // Assert
        expect(emptyChatSummary.title, equals(''));
        expect(emptyChatSummary.summary, equals(''));
      });

      test('should handle very long title and summary', () {
        // Arrange
        final longText = 'A' * 1000;

        // Act
        final longChatSummary = testChatSummary.copyWith(
          title: longText,
          summary: longText,
        );

        // Assert
        expect(longChatSummary.title, equals(longText));
        expect(longChatSummary.summary, equals(longText));
        expect(longChatSummary.title.length, equals(1000));
        expect(longChatSummary.summary.length, equals(1000));
      });

      test('should handle special characters in title and summary', () {
        // Arrange
        const specialText = 'スペシャル文字: !@#\$%^&*()🎉🚀';

        // Act
        final specialChatSummary = testChatSummary.copyWith(
          title: specialText,
          summary: specialText,
        );

        // Assert
        expect(specialChatSummary.title, equals(specialText));
        expect(specialChatSummary.summary, equals(specialText));
      });

      test('should handle many messages', () {
        // Arrange
        final manyMessages = List.generate(
          100,
          (index) => AiMessageEntity(
            id: 'msg-$index',
            content: 'Message $index',
            type: MessageType.user,
            timestamp: DateTime(2024, 1, 1, 10, index),
          ),
        );

        // Act
        final manyMessagesChatSummary = testChatSummary.copyWith(
          messages: manyMessages,
          messageCount: 100,
        );

        // Assert
        expect(manyMessagesChatSummary.messages, hasLength(100));
        expect(manyMessagesChatSummary.messageCount, equals(100));
        expect(manyMessagesChatSummary.messages.first.id, equals('msg-0'));
        expect(manyMessagesChatSummary.messages.last.id, equals('msg-99'));
      });

      test('should handle zero message count', () {
        // Act
        final zeroMessagesChatSummary = testChatSummary.copyWith(
          messages: [],
          messageCount: 0,
        );

        // Assert
        expect(zeroMessagesChatSummary.messages, isEmpty);
        expect(zeroMessagesChatSummary.messageCount, equals(0));
      });

      test('should handle negative message count', () {
        // Act
        final negativeCountChatSummary = testChatSummary.copyWith(
          messageCount: -1,
        );

        // Assert
        expect(negativeCountChatSummary.messageCount, equals(-1));
      });

      test('should handle null petId and petName', () {
        // Act
        final nullPetChatSummary = testChatSummary.copyWith(
          petId: null,
          petName: null,
        );

        // Assert
        expect(nullPetChatSummary.petId, isNull);
        expect(nullPetChatSummary.petName, isNull);
      });
    });

    group('equality and hashCode', () {
      test('should be equal when IDs are same', () {
        // Arrange
        final sameIdChatSummary = testChatSummary.copyWith(
          title: 'Different Title',
          summary: 'Different Summary',
        );

        // Assert
        expect(testChatSummary, equals(sameIdChatSummary));
        expect(testChatSummary.hashCode, equals(sameIdChatSummary.hashCode));
      });

      test('should not be equal when IDs differ', () {
        // Arrange
        final differentIdChatSummary = testChatSummary.copyWith(
          id: 'different-id',
        );

        // Assert
        expect(testChatSummary, isNot(equals(differentIdChatSummary)));
        expect(
          testChatSummary.hashCode,
          isNot(equals(differentIdChatSummary.hashCode)),
        );
      });

      test('should be equal to itself', () {
        // Assert
        expect(testChatSummary, equals(testChatSummary));
        expect(testChatSummary.hashCode, equals(testChatSummary.hashCode));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testChatSummary.toString();

        // Assert
        expect(stringRepresentation, contains('AiChatSummaryEntity'));
        expect(stringRepresentation, contains('summary-1'));
        expect(stringRepresentation, contains('ペットの健康相談'));
      });
    });
  });
}
