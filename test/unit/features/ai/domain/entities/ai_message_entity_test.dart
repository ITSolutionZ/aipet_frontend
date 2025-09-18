import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageType', () {
    test('should have correct enum values', () {
      expect(MessageType.values, hasLength(3));
      expect(MessageType.values, contains(MessageType.user));
      expect(MessageType.values, contains(MessageType.assistant));
      expect(MessageType.values, contains(MessageType.system));
    });
  });

  group('AiMessageEntity', () {
    late AiMessageEntity testMessage;

    setUp(() {
      testMessage = AiMessageEntity(
        id: 'test-message-1',
        content: 'テストメッセージ',
        type: MessageType.user,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        isTyping: false,
        petId: 'pet-1',
        petName: 'テストペット',
        metadata: {'key': 'value'},
      );
    });

    group('constructor', () {
      test('should create message with all parameters', () {
        // Act
        final message = AiMessageEntity(
          id: 'test-id',
          content: 'Test content',
          type: MessageType.assistant,
          timestamp: DateTime(2024, 1, 1),
          isTyping: true,
          petId: 'pet-123',
          petName: 'Test Pet',
          metadata: {'test': 'data'},
        );

        // Assert
        expect(message.id, equals('test-id'));
        expect(message.content, equals('Test content'));
        expect(message.type, equals(MessageType.assistant));
        expect(message.timestamp, equals(DateTime(2024, 1, 1)));
        expect(message.isTyping, isTrue);
        expect(message.petId, equals('pet-123'));
        expect(message.petName, equals('Test Pet'));
        expect(message.metadata, equals({'test': 'data'}));
      });

      test('should create message with required parameters only', () {
        // Act
        final message = AiMessageEntity(
          id: 'test-id',
          content: 'Test content',
          type: MessageType.user,
          timestamp: DateTime(2024, 1, 1),
        );

        // Assert
        expect(message.id, equals('test-id'));
        expect(message.content, equals('Test content'));
        expect(message.type, equals(MessageType.user));
        expect(message.timestamp, equals(DateTime(2024, 1, 1)));
        expect(message.isTyping, isFalse);
        expect(message.petId, isNull);
        expect(message.petName, isNull);
        expect(message.metadata, isNull);
      });
    });

    group('type checks', () {
      test('isUser should return true for user message', () {
        // Arrange
        final userMessage = testMessage.copyWith(type: MessageType.user);

        // Assert
        expect(userMessage.isUser, isTrue);
        expect(userMessage.isAssistant, isFalse);
        expect(userMessage.isSystem, isFalse);
      });

      test('isAssistant should return true for assistant message', () {
        // Arrange
        final assistantMessage = testMessage.copyWith(
          type: MessageType.assistant,
        );

        // Assert
        expect(assistantMessage.isUser, isFalse);
        expect(assistantMessage.isAssistant, isTrue);
        expect(assistantMessage.isSystem, isFalse);
      });

      test('isSystem should return true for system message', () {
        // Arrange
        final systemMessage = testMessage.copyWith(type: MessageType.system);

        // Assert
        expect(systemMessage.isUser, isFalse);
        expect(systemMessage.isAssistant, isFalse);
        expect(systemMessage.isSystem, isTrue);
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedMessage = testMessage.copyWith(
          content: 'Updated content',
          type: MessageType.assistant,
          isTyping: true,
        );

        // Assert
        expect(updatedMessage.id, equals('test-message-1')); // unchanged
        expect(updatedMessage.content, equals('Updated content'));
        expect(updatedMessage.type, equals(MessageType.assistant));
        expect(
          updatedMessage.timestamp,
          equals(DateTime(2024, 1, 1, 12, 0, 0)),
        ); // unchanged
        expect(updatedMessage.isTyping, isTrue);
        expect(updatedMessage.petId, equals('pet-1')); // unchanged
        expect(updatedMessage.petName, equals('テストペット')); // unchanged
        expect(updatedMessage.metadata, equals({'key': 'value'})); // unchanged
      });

      test('should keep original values when null provided', () {
        // Act
        final updatedMessage = testMessage.copyWith();

        // Assert
        expect(updatedMessage.id, equals(testMessage.id));
        expect(updatedMessage.content, equals(testMessage.content));
        expect(updatedMessage.type, equals(testMessage.type));
        expect(updatedMessage.timestamp, equals(testMessage.timestamp));
        expect(updatedMessage.isTyping, equals(testMessage.isTyping));
        expect(updatedMessage.petId, equals(testMessage.petId));
        expect(updatedMessage.petName, equals(testMessage.petName));
        expect(updatedMessage.metadata, equals(testMessage.metadata));
      });
    });

    group('edge cases', () {
      test('should handle empty content', () {
        // Act
        final emptyMessage = AiMessageEntity(
          id: 'test-id',
          content: '',
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        // Assert
        expect(emptyMessage.content, equals(''));
      });

      test('should handle long content', () {
        // Arrange
        final longContent = 'A' * 1000;

        // Act
        final longMessage = AiMessageEntity(
          id: 'test-id',
          content: longContent,
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        );

        // Assert
        expect(longMessage.content, equals(longContent));
        expect(longMessage.content.length, equals(1000));
      });

      test('should handle special characters in content', () {
        // Arrange
        const specialContent = 'こんにちは世界！🎉🚀';

        // Act
        final specialMessage = AiMessageEntity(
          id: 'test-id',
          content: specialContent,
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        // Assert
        expect(specialMessage.content, equals(specialContent));
      });

      test('should handle complex metadata', () {
        // Arrange
        final complexMetadata = {
          'nested': {'key': 'value'},
          'list': [1, 2, 3],
          'boolean': true,
          'number': 42.5,
        };

        // Act
        final complexMessage = AiMessageEntity(
          id: 'test-id',
          content: 'Test',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
          metadata: complexMetadata,
        );

        // Assert
        expect(complexMessage.metadata, equals(complexMetadata));
      });
    });
  });

  group('AiChatSessionEntity', () {
    late AiChatSessionEntity testSession;
    late List<AiMessageEntity> testMessages;

    setUp(() {
      testMessages = [
        AiMessageEntity(
          id: 'msg-1',
          content: 'Hello',
          type: MessageType.user,
          timestamp: DateTime(2024, 1, 1, 10, 0, 0),
        ),
        AiMessageEntity(
          id: 'msg-2',
          content: 'Hi there!',
          type: MessageType.assistant,
          timestamp: DateTime(2024, 1, 1, 10, 1, 0),
        ),
      ];

      testSession = AiChatSessionEntity(
        id: 'session-1',
        title: 'Test Chat',
        messages: testMessages,
        createdAt: DateTime(2024, 1, 1, 10, 0, 0),
        updatedAt: DateTime(2024, 1, 1, 10, 1, 0),
        petId: 'pet-1',
        petName: 'テストペット',
      );
    });

    group('constructor', () {
      test('should create session with all parameters', () {
        // Act
        final session = AiChatSessionEntity(
          id: 'test-session',
          title: 'Test Title',
          messages: testMessages,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          petId: 'pet-123',
          petName: 'Test Pet',
        );

        // Assert
        expect(session.id, equals('test-session'));
        expect(session.title, equals('Test Title'));
        expect(session.messages, equals(testMessages));
        expect(session.createdAt, equals(DateTime(2024, 1, 1)));
        expect(session.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(session.petId, equals('pet-123'));
        expect(session.petName, equals('Test Pet'));
      });

      test('should create session with required parameters only', () {
        // Act
        final session = AiChatSessionEntity(
          id: 'test-session',
          title: 'Test Title',
          messages: [],
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        );

        // Assert
        expect(session.id, equals('test-session'));
        expect(session.title, equals('Test Title'));
        expect(session.messages, isEmpty);
        expect(session.createdAt, equals(DateTime(2024, 1, 1)));
        expect(session.updatedAt, equals(DateTime(2024, 1, 2)));
        expect(session.petId, isNull);
        expect(session.petName, isNull);
      });
    });

    group('addMessage', () {
      test('should add message to session', () {
        // Arrange
        final newMessage = AiMessageEntity(
          id: 'msg-3',
          content: 'New message',
          type: MessageType.user,
          timestamp: DateTime(2024, 1, 1, 10, 2, 0),
        );

        // Act
        final updatedSession = testSession.addMessage(newMessage);

        // Assert
        expect(updatedSession.messages, hasLength(3));
        expect(updatedSession.messages.last, equals(newMessage));
        expect(updatedSession.updatedAt, isNot(equals(testSession.updatedAt)));
      });

      test('should not modify original session', () {
        // Arrange
        final newMessage = AiMessageEntity(
          id: 'msg-3',
          content: 'New message',
          type: MessageType.user,
          timestamp: DateTime(2024, 1, 1, 10, 2, 0),
        );

        // Act
        testSession.addMessage(newMessage);

        // Assert
        expect(testSession.messages, hasLength(2));
      });
    });

    group('lastMessage', () {
      test('should return last message when messages exist', () {
        // Act
        final lastMessage = testSession.lastMessage;

        // Assert
        expect(lastMessage, equals(testMessages.last));
      });

      test('should return null when no messages', () {
        // Arrange
        final emptySession = testSession.copyWith(messages: []);

        // Act
        final lastMessage = emptySession.lastMessage;

        // Assert
        expect(lastMessage, isNull);
      });
    });

    group('messageCount', () {
      test('should return correct message count', () {
        // Assert
        expect(testSession.messageCount, equals(2));
      });

      test('should return zero for empty session', () {
        // Arrange
        final emptySession = testSession.copyWith(messages: []);

        // Assert
        expect(emptySession.messageCount, equals(0));
      });
    });

    group('copyWith', () {
      test('should update only provided fields', () {
        // Act
        final updatedSession = testSession.copyWith(
          title: 'Updated Title',
          petName: 'Updated Pet',
        );

        // Assert
        expect(updatedSession.id, equals('session-1')); // unchanged
        expect(updatedSession.title, equals('Updated Title'));
        expect(updatedSession.messages, equals(testMessages)); // unchanged
        expect(
          updatedSession.createdAt,
          equals(DateTime(2024, 1, 1, 10, 0, 0)),
        ); // unchanged
        expect(
          updatedSession.updatedAt,
          equals(DateTime(2024, 1, 1, 10, 1, 0)),
        ); // unchanged
        expect(updatedSession.petId, equals('pet-1')); // unchanged
        expect(updatedSession.petName, equals('Updated Pet'));
      });
    });
  });

  group('AiSuggestedQuestionEntity', () {
    test('should create suggested question with all parameters', () {
      // Act
      const question = AiSuggestedQuestionEntity(
        id: 'q-1',
        question: 'ペットの健康について教えて',
        category: 'health',
        icon: Icons.health_and_safety,
        description: 'ペットの健康管理に関する質問',
      );

      // Assert
      expect(question.id, equals('q-1'));
      expect(question.question, equals('ペットの健康について教えて'));
      expect(question.category, equals('health'));
      expect(question.icon, equals(Icons.health_and_safety));
      expect(question.description, equals('ペットの健康管理に関する質問'));
    });

    test('should create suggested question without description', () {
      // Act
      const question = AiSuggestedQuestionEntity(
        id: 'q-2',
        question: 'ペットの食事について',
        category: 'nutrition',
        icon: Icons.restaurant,
      );

      // Assert
      expect(question.id, equals('q-2'));
      expect(question.question, equals('ペットの食事について'));
      expect(question.category, equals('nutrition'));
      expect(question.icon, equals(Icons.restaurant));
      expect(question.description, isNull);
    });
  });
}
