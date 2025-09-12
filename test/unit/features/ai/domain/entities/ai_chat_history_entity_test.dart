import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/ai/domain/entities/ai_category_entity.dart';
import '../../../../../lib/features/ai/domain/entities/ai_chat_history_entity.dart';
import '../../../../../lib/features/ai/domain/entities/ai_message_entity.dart';
import '../../../../../lib/features/pet_registor/domain/entities/pet_profile_entity.dart';

void main() {
  group('AiChatHistoryEntity', () {
    late AiChatHistoryEntity testChatHistory;
    late List<AiMessageEntity> testMessages;
    late PetProfileEntity testPet;
    late AiCategoryEntity testCategory;

    setUp(() {
      testMessages = [
        AiMessageEntity(
          id: 'msg-1',
          content: 'こんにちは',
          type: MessageType.user,
          timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        ),
        AiMessageEntity(
          id: 'msg-2',
          content: 'こんにちは！何かお手伝いできることはありますか？',
          type: MessageType.assistant,
          timestamp: DateTime(2024, 1, 1, 10, 1, 0),
        ),
      ];

      testPet = PetProfileEntity(
        id: 'pet-1',
        name: 'テストペット',
        type: PetType.dog,
        breed: '柴犬',
        birthDate: DateTime(2020, 1, 1),
        gender: PetGender.male,
        weight: 10.5,
        microchipNumber: '123456789012345',
        imagePath: '/path/to/image.jpg',
        ownerId: 'owner-1',
        arrivalDate: DateTime(2020, 2, 1),
        additionalInfo: '{"arrivalDate": "2020-02-01T00:00:00.000"}',
      );

      testCategory = AiCategoryEntity(
        id: 'health',
        name: '健康管理',
        description: 'ペットの健康に関する質問',
        icon: Icons.health_and_safety,
        color: Colors.red,
        order: 1,
        isActive: true,
      );

      testChatHistory = AiChatHistoryEntity(
        id: 'history-1',
        title: 'テストチャット',
        summary: 'ペットの健康について相談しました',
        messages: testMessages,
        pet: testPet,
        category: testCategory,
        createdAt: DateTime(2024, 1, 1, 10, 0, 0),
        isManualSaved: true,
        messageCount: 2,
      );
    });

    group('constructor', () {
      test('should create chat history with all parameters', () {
        // Act
        final chatHistory = AiChatHistoryEntity(
          id: 'test-history',
          title: 'テストタイトル',
          summary: 'テストサマリー',
          messages: testMessages,
          pet: testPet,
          category: testCategory,
          createdAt: DateTime(2024, 1, 1),
          isManualSaved: false,
          messageCount: 5,
        );

        // Assert
        expect(chatHistory.id, equals('test-history'));
        expect(chatHistory.title, equals('テストタイトル'));
        expect(chatHistory.summary, equals('テストサマリー'));
        expect(chatHistory.messages, equals(testMessages));
        expect(chatHistory.pet, equals(testPet));
        expect(chatHistory.category, equals(testCategory));
        expect(chatHistory.createdAt, equals(DateTime(2024, 1, 1)));
        expect(chatHistory.isManualSaved, isFalse);
        expect(chatHistory.messageCount, equals(5));
      });

      test('should create chat history with required parameters only', () {
        // Act
        final chatHistory = AiChatHistoryEntity(
          id: 'simple-history',
          title: 'シンプルタイトル',
          summary: 'シンプルサマリー',
          messages: [],
          createdAt: DateTime(2024, 1, 1),
          messageCount: 0,
        );

        // Assert
        expect(chatHistory.id, equals('simple-history'));
        expect(chatHistory.title, equals('シンプルタイトル'));
        expect(chatHistory.summary, equals('シンプルサマリー'));
        expect(chatHistory.messages, isEmpty);
        expect(chatHistory.pet, isNull);
        expect(chatHistory.category, isNull);
        expect(chatHistory.createdAt, equals(DateTime(2024, 1, 1)));
        expect(chatHistory.isManualSaved, isFalse);
        expect(chatHistory.messageCount, equals(0));
      });

      test('should default isManualSaved to false', () {
        // Act
        final chatHistory = AiChatHistoryEntity(
          id: 'default-history',
          title: 'デフォルトタイトル',
          summary: 'デフォルトサマリー',
          messages: [],
          createdAt: DateTime(2024, 1, 1),
          messageCount: 0,
        );

        // Assert
        expect(chatHistory.isManualSaved, isFalse);
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedChatHistory = testChatHistory.copyWith(
          title: 'Updated Title',
          isManualSaved: false,
          messageCount: 10,
        );

        // Assert
        expect(updatedChatHistory.id, equals('history-1')); // unchanged
        expect(updatedChatHistory.title, equals('Updated Title'));
        expect(
          updatedChatHistory.summary,
          equals('ペットの健康について相談しました'),
        ); // unchanged
        expect(updatedChatHistory.messages, equals(testMessages)); // unchanged
        expect(updatedChatHistory.pet, equals(testPet)); // unchanged
        expect(updatedChatHistory.category, equals(testCategory)); // unchanged
        expect(
          updatedChatHistory.createdAt,
          equals(DateTime(2024, 1, 1, 10, 0, 0)),
        ); // unchanged
        expect(updatedChatHistory.isManualSaved, isFalse);
        expect(updatedChatHistory.messageCount, equals(10));
      });

      test('should keep original values when null provided', () {
        // Act
        final updatedChatHistory = testChatHistory.copyWith();

        // Assert
        expect(updatedChatHistory.id, equals(testChatHistory.id));
        expect(updatedChatHistory.title, equals(testChatHistory.title));
        expect(updatedChatHistory.summary, equals(testChatHistory.summary));
        expect(updatedChatHistory.messages, equals(testChatHistory.messages));
        expect(updatedChatHistory.pet, equals(testChatHistory.pet));
        expect(updatedChatHistory.category, equals(testChatHistory.category));
        expect(updatedChatHistory.createdAt, equals(testChatHistory.createdAt));
        expect(
          updatedChatHistory.isManualSaved,
          equals(testChatHistory.isManualSaved),
        );
        expect(
          updatedChatHistory.messageCount,
          equals(testChatHistory.messageCount),
        );
      });
    });

    group('edge cases', () {
      test('should handle empty title and summary', () {
        // Act
        final emptyChatHistory = testChatHistory.copyWith(
          title: '',
          summary: '',
        );

        // Assert
        expect(emptyChatHistory.title, equals(''));
        expect(emptyChatHistory.summary, equals(''));
      });

      test('should handle very long title and summary', () {
        // Arrange
        final longText = 'A' * 1000;

        // Act
        final longChatHistory = testChatHistory.copyWith(
          title: longText,
          summary: longText,
        );

        // Assert
        expect(longChatHistory.title, equals(longText));
        expect(longChatHistory.summary, equals(longText));
        expect(longChatHistory.title.length, equals(1000));
        expect(longChatHistory.summary.length, equals(1000));
      });

      test('should handle special characters in title and summary', () {
        // Arrange
        const specialText = 'スペシャル文字: !@#\$%^&*()🎉🚀';

        // Act
        final specialChatHistory = testChatHistory.copyWith(
          title: specialText,
          summary: specialText,
        );

        // Assert
        expect(specialChatHistory.title, equals(specialText));
        expect(specialChatHistory.summary, equals(specialText));
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
        final manyMessagesChatHistory = testChatHistory.copyWith(
          messages: manyMessages,
          messageCount: 100,
        );

        // Assert
        expect(manyMessagesChatHistory.messages, hasLength(100));
        expect(manyMessagesChatHistory.messageCount, equals(100));
        expect(manyMessagesChatHistory.messages.first.id, equals('msg-0'));
        expect(manyMessagesChatHistory.messages.last.id, equals('msg-99'));
      });

      test('should handle zero message count', () {
        // Act
        final zeroMessagesChatHistory = testChatHistory.copyWith(
          messages: [],
          messageCount: 0,
        );

        // Assert
        expect(zeroMessagesChatHistory.messages, isEmpty);
        expect(zeroMessagesChatHistory.messageCount, equals(0));
      });

      test('should handle negative message count', () {
        // Act
        final negativeCountChatHistory = testChatHistory.copyWith(
          messageCount: -1,
        );

        // Assert
        expect(negativeCountChatHistory.messageCount, equals(-1));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when IDs are same', () {
        // Arrange
        final sameIdChatHistory = testChatHistory.copyWith(
          title: 'Different Title',
          summary: 'Different Summary',
        );

        // Assert
        expect(testChatHistory, equals(sameIdChatHistory));
        expect(testChatHistory.hashCode, equals(sameIdChatHistory.hashCode));
      });

      test('should not be equal when IDs differ', () {
        // Arrange
        final differentIdChatHistory = testChatHistory.copyWith(
          id: 'different-id',
        );

        // Assert
        expect(testChatHistory, isNot(equals(differentIdChatHistory)));
        expect(
          testChatHistory.hashCode,
          isNot(equals(differentIdChatHistory.hashCode)),
        );
      });

      test('should be equal to itself', () {
        // Assert
        expect(testChatHistory, equals(testChatHistory));
        expect(testChatHistory.hashCode, equals(testChatHistory.hashCode));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testChatHistory.toString();

        // Assert
        expect(stringRepresentation, contains('AiChatHistoryEntity'));
        expect(stringRepresentation, contains('history-1'));
        expect(stringRepresentation, contains('テストチャット'));
      });
    });
  });
}
