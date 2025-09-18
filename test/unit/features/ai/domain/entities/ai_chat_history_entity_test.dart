import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_history_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiChatHistoryEntity', () {
    late AiChatHistoryEntity testChatHistory;
    late List<AiMessageEntity> testMessages;
    late PetProfileEntity testPet;
    late AiCategoryEntity testCategory;
    final testDateTime = DateTime(2024, 1, 1, 12, 0);

    setUp(() {
      testMessages = [
        AiMessageEntity(
          id: 'msg-1',
          content: 'こんにちは',
          type: MessageType.user,
          timestamp: testDateTime,
          petId: 'pet-1',
          petName: 'テストペット',
        ),
        AiMessageEntity(
          id: 'msg-2',
          content: 'こんにちは！どのようなことでお手伝いできますか？',
          type: MessageType.assistant,
          timestamp: testDateTime.add(const Duration(seconds: 5)),
          petId: 'pet-1',
          petName: 'テストペット',
        ),
      ];

      testPet = PetProfileEntity(
        id: 'pet-1',
        name: 'テストペット',
        type: 'dog',
        breed: 'ゴールデンレトリバー',
        birthDate: DateTime(2020, 1, 1),
        ownerId: 'owner-1',
        createdAt: DateTime(2020, 1, 1),
        updatedAt: DateTime(2020, 1, 1),
      );

      testCategory = const AiCategoryEntity(
        id: 'health',
        name: '健康管理',
        description: 'ペットの健康に関する質問',
        icon: Icons.health_and_safety,
        color: Colors.red,
      );

      testChatHistory = AiChatHistoryEntity(
        id: 'chat-1',
        title: 'ペットの健康相談',
        summary: 'ペットの健康について相談した内容',
        messages: testMessages,
        pet: testPet,
        category: testCategory,
        createdAt: testDateTime,
        isManualSaved: true,
        messageCount: testMessages.length,
      );
    });

    group('constructor', () {
      test('should create AiChatHistoryEntity with all parameters', () {
        // Assert
        expect(testChatHistory.id, equals('chat-1'));
        expect(testChatHistory.title, equals('ペットの健康相談'));
        expect(testChatHistory.summary, equals('ペットの健康について相談した内容'));
        expect(testChatHistory.messages, equals(testMessages));
        expect(testChatHistory.pet, equals(testPet));
        expect(testChatHistory.category, equals(testCategory));
        expect(testChatHistory.createdAt, equals(testDateTime));
        expect(testChatHistory.isManualSaved, isTrue);
        expect(testChatHistory.messageCount, equals(2));
      });

      test('should create AiChatHistoryEntity with minimal required parameters', () {
        // Act
        final minimalChatHistory = AiChatHistoryEntity(
          id: 'chat-2',
          title: 'シンプルな相談',
          summary: 'シンプルな相談内容',
          messages: [],
          createdAt: testDateTime,
          messageCount: 0,
        );

        // Assert
        expect(minimalChatHistory.id, equals('chat-2'));
        expect(minimalChatHistory.title, equals('シンプルな相談'));
        expect(minimalChatHistory.summary, equals('シンプルな相談内容'));
        expect(minimalChatHistory.messages, isEmpty);
        expect(minimalChatHistory.pet, isNull);
        expect(minimalChatHistory.category, isNull);
        expect(minimalChatHistory.createdAt, equals(testDateTime));
        expect(minimalChatHistory.isManualSaved, isFalse); // default value
        expect(minimalChatHistory.messageCount, equals(0));
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedChatHistory = testChatHistory.copyWith(
          title: '更新されたタイトル',
          messageCount: 5,
          isManualSaved: false,
        );

        // Assert
        expect(updatedChatHistory.id, equals('chat-1')); // unchanged
        expect(updatedChatHistory.title, equals('更新されたタイトル'));
        expect(updatedChatHistory.summary, equals('ペットの健康について相談した内容')); // unchanged
        expect(updatedChatHistory.messages, equals(testMessages)); // unchanged
        expect(updatedChatHistory.pet, equals(testPet)); // unchanged
        expect(updatedChatHistory.category, equals(testCategory)); // unchanged
        expect(updatedChatHistory.createdAt, equals(testDateTime)); // unchanged
        expect(updatedChatHistory.isManualSaved, isFalse);
        expect(updatedChatHistory.messageCount, equals(5));
      });

      test('should keep original values when no parameters provided', () {
        // Act
        final copiedChatHistory = testChatHistory.copyWith();

        // Assert
        expect(copiedChatHistory.id, equals(testChatHistory.id));
        expect(copiedChatHistory.title, equals(testChatHistory.title));
        expect(copiedChatHistory.summary, equals(testChatHistory.summary));
        expect(copiedChatHistory.messages, equals(testChatHistory.messages));
        expect(copiedChatHistory.pet, equals(testChatHistory.pet));
        expect(copiedChatHistory.category, equals(testChatHistory.category));
        expect(copiedChatHistory.createdAt, equals(testChatHistory.createdAt));
        expect(copiedChatHistory.isManualSaved, equals(testChatHistory.isManualSaved));
        expect(copiedChatHistory.messageCount, equals(testChatHistory.messageCount));
      });

      test('should handle updating to null values', () {
        // Act
        final chatHistoryWithNulls = testChatHistory.copyWith(
          pet: null,
          category: null,
        );

        // Assert
        expect(chatHistoryWithNulls.pet, isNull);
        expect(chatHistoryWithNulls.category, isNull);
        expect(chatHistoryWithNulls.id, equals(testChatHistory.id)); // other fields unchanged
        expect(chatHistoryWithNulls.title, equals(testChatHistory.title));
      });
    });

    group('edge cases', () {
      test('should handle empty messages list', () {
        // Act
        final emptyChatHistory = testChatHistory.copyWith(
          messages: [],
          messageCount: 0,
        );

        // Assert
        expect(emptyChatHistory.messages, isEmpty);
        expect(emptyChatHistory.messageCount, equals(0));
      });

      test('should handle many messages', () {
        // Arrange
        final manyMessages = List.generate(
          100,
          (index) => AiMessageEntity(
            id: 'msg-$index',
            content: 'メッセージ $index',
            type: index % 2 == 0 ? MessageType.user : MessageType.assistant,
            timestamp: testDateTime.add(Duration(seconds: index)),
          ),
        );

        // Act
        final chatHistoryWithManyMessages = testChatHistory.copyWith(
          messages: manyMessages,
          messageCount: manyMessages.length,
        );

        // Assert
        expect(chatHistoryWithManyMessages.messages, hasLength(100));
        expect(chatHistoryWithManyMessages.messageCount, equals(100));
        expect(chatHistoryWithManyMessages.messages.first.content, equals('メッセージ 0'));
        expect(chatHistoryWithManyMessages.messages.last.content, equals('メッセージ 99'));
      });

      test('should handle special characters in title and summary', () {
        // Act
        final specialCharChatHistory = testChatHistory.copyWith(
          title: 'スペシャルタイトル: !@#\$%^&*()🎉',
          summary: '特殊文字を含む要約: 日本語、English、한국어、中文',
        );

        // Assert
        expect(specialCharChatHistory.title, equals('スペシャルタイトル: !@#\$%^&*()🎉'));
        expect(specialCharChatHistory.summary, equals('特殊文字を含む要約: 日本語、English、한국어、中文'));
      });

      test('should handle very long title and summary', () {
        // Arrange
        const longTitle = 'とても長いタイトルでペットの健康に関する詳細な相談内容を含んでいます。'
            'これは通常のタイトルよりもはるかに長く、複数の文章で構成されています。';
        const longSummary = 'とても長い要約でペットの健康に関する詳細な相談内容を含んでいます。'
            'これは通常の要約よりもはるかに長く、複数の段落で構成されており、'
            '様々な健康問題や相談内容を詳細に記述しています。';

        // Act
        final longChatHistory = testChatHistory.copyWith(
          title: longTitle,
          summary: longSummary,
        );

        // Assert
        expect(longChatHistory.title, equals(longTitle));
        expect(longChatHistory.summary, equals(longSummary));
      });

      test('should handle future and past dates', () {
        // Arrange
        final futureDate = DateTime(2030, 12, 31);
        final pastDate = DateTime(1990, 1, 1);

        // Act
        final futureChatHistory = testChatHistory.copyWith(createdAt: futureDate);
        final pastChatHistory = testChatHistory.copyWith(createdAt: pastDate);

        // Assert
        expect(futureChatHistory.createdAt, equals(futureDate));
        expect(pastChatHistory.createdAt, equals(pastDate));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when ids are same', () {
        // Arrange
        final sameChatHistory = AiChatHistoryEntity(
          id: 'chat-1', // same id
          title: '異なるタイトル',
          summary: '異なる要約',
          messages: [],
          createdAt: DateTime(2023, 1, 1),
          messageCount: 0,
        );

        // Assert
        expect(testChatHistory, equals(sameChatHistory));
        expect(testChatHistory.hashCode, equals(sameChatHistory.hashCode));
      });

      test('should not be equal when ids are different', () {
        // Arrange
        final differentChatHistory = testChatHistory.copyWith(id: 'different-id');

        // Assert
        expect(testChatHistory, isNot(equals(differentChatHistory)));
        expect(testChatHistory.hashCode, isNot(equals(differentChatHistory.hashCode)));
      });
    });

    group('type validation', () {
      test('should be of correct type', () {
        // Assert
        expect(testChatHistory, isA<AiChatHistoryEntity>());
        expect(testChatHistory.messages, isA<List<AiMessageEntity>>());
        expect(testChatHistory.pet, isA<PetProfileEntity>());
        expect(testChatHistory.category, isA<AiCategoryEntity>());
        expect(testChatHistory.createdAt, isA<DateTime>());
        expect(testChatHistory.isManualSaved, isA<bool>());
      });
    });
  });
}