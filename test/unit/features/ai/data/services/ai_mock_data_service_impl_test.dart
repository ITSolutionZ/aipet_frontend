import 'package:aipet_frontend/features/ai/data/services/ai_mock_data_service_impl.dart';
import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiMockDataServiceImpl', () {
    late AiMockDataServiceImpl service;

    setUp(() {
      service = AiMockDataServiceImpl();
    });

    group('simulateApiDelay', () {
      test('should simulate API delay with default duration', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await service.simulateApiDelay();

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('should simulate API delay with custom duration', () async {
        // Arrange
        const customSeconds = 2;
        final stopwatch = Stopwatch()..start();

        // Act
        await service.simulateApiDelay(seconds: customSeconds);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(2000));
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      });

      test('should handle zero delay', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await service.simulateApiDelay(seconds: 0);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('getChatHistory', () {
      test('should return list of chat messages', () async {
        // Act
        final result = await service.getChatHistory();

        // Assert
        expect(result, isA<List<AiMessageEntity>>());
        expect(result, isNotEmpty);

        // Check message structure
        for (final message in result) {
          expect(message.id, isNotEmpty);
          expect(message.content, isNotEmpty);
          expect(message.type, isA<MessageType>());
          expect(message.timestamp, isA<DateTime>());
        }
      });

      test('should return messages with different types', () async {
        // Act
        final result = await service.getChatHistory();

        // Assert
        final messageTypes = result.map((m) => m.type).toSet();
        expect(messageTypes, contains(MessageType.user));
        expect(messageTypes, contains(MessageType.assistant));
      });

      test('should return messages in chronological order', () async {
        // Act
        final result = await service.getChatHistory();

        // Assert
        for (int i = 1; i < result.length; i++) {
          expect(
            result[i].timestamp.isAfter(result[i - 1].timestamp) ||
                result[i].timestamp.isAtSameMomentAs(result[i - 1].timestamp),
            isTrue,
          );
        }
      });
    });

    group('getSuggestedQuestions', () {
      test('should return list of suggested questions', () async {
        // Act
        final result = await service.getSuggestedQuestions();

        // Assert
        expect(result, isA<List<AiSuggestedQuestionEntity>>());
        expect(result, isNotEmpty);

        // Check question structure
        for (final question in result) {
          expect(question.id, isNotEmpty);
          expect(question.question, isNotEmpty);
          expect(question.category, isNotEmpty);
          expect(question.icon, isA<IconData>());
        }
      });

      test('should return questions with different categories', () async {
        // Act
        final result = await service.getSuggestedQuestions();

        // Assert
        final categories = result.map((q) => q.category).toSet();
        expect(categories.length, greaterThan(1));

        // Check for common categories
        expect(categories, contains('health'));
        expect(categories, contains('nutrition'));
        expect(categories, contains('behavior'));
      });

      test('should return questions with valid icons', () async {
        // Act
        final result = await service.getSuggestedQuestions();

        // Assert
        for (final question in result) {
          expect(question.icon, isNotNull);
          expect(question.icon, isA<IconData>());
        }
      });
    });

    group('getFavoriteQAs', () {
      test('should return list of favorite QAs', () async {
        // Act
        final result = await service.getFavoriteQAs();

        // Assert
        expect(result, isA<List<AiFavoriteQaEntity>>());
        expect(result, isNotEmpty);

        // Check QA structure
        for (final qa in result) {
          expect(qa.id, isNotEmpty);
          expect(qa.question, isNotEmpty);
          expect(qa.answer, isNotEmpty);
          expect(qa.categoryId, isNotEmpty);
          expect(qa.createdAt, isA<DateTime>());
        }
      });

      test('should return QAs with different categories', () async {
        // Act
        final result = await service.getFavoriteQAs();

        // Assert
        final categories = result.map((qa) => qa.categoryId).toSet();
        expect(categories.length, greaterThan(1));
      });
    });

    group('getChatSessions', () {
      test('should return list of chat sessions', () async {
        // Act
        final result = await service.getChatSessions();

        // Assert
        expect(result, isA<List<AiChatSessionEntity>>());
        expect(result, isNotEmpty);

        // Check session structure
        for (final session in result) {
          expect(session.id, isNotEmpty);
          expect(session.title, isNotEmpty);
          expect(session.messages, isA<List<AiMessageEntity>>());
          expect(session.createdAt, isA<DateTime>());
          expect(session.updatedAt, isA<DateTime>());
        }
      });

      test('should return sessions with valid timestamps', () async {
        // Act
        final result = await service.getChatSessions();

        // Assert
        for (final session in result) {
          expect(
            session.createdAt.isBefore(session.updatedAt) ||
                session.createdAt.isAtSameMomentAs(session.updatedAt),
            isTrue,
          );
        }
      });
    });

    group('generateAiResponse', () {
      test('should generate AI response for user message', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えてください';

        // Act
        final result = await service.generateAiResponse(userMessage);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result, containsPair('id', isA<String>()));
        expect(result, containsPair('content', isA<String>()));
        expect(result, containsPair('type', 'assistant'));
        expect(result, containsPair('timestamp', isA<String>()));
      });

      test(
        'should generate different responses for different messages',
        () async {
          // Arrange
          const message1 = 'ペットの健康について教えてください';
          const message2 = 'ペットの食事について教えてください';

          // Act
          final result1 = await service.generateAiResponse(message1);
          final result2 = await service.generateAiResponse(message2);

          // Assert
          expect(result1['content'], isNot(equals(result2['content'])));
          expect(result1['id'], isNot(equals(result2['id'])));
        },
      );

      test('should generate response with valid timestamp', () async {
        // Arrange
        const userMessage = 'テストメッセージ';
        final beforeCall = DateTime.now();

        // Act
        final result = await service.generateAiResponse(userMessage);

        // Assert
        final afterCall = DateTime.now();
        final responseTime = DateTime.parse(result['timestamp'] as String);

        expect(
          responseTime.isAfter(beforeCall) ||
              responseTime.isAtSameMomentAs(beforeCall),
          isTrue,
        );
        expect(
          responseTime.isBefore(afterCall) ||
              responseTime.isAtSameMomentAs(afterCall),
          isTrue,
        );
      });
    });

    group('createChatSession', () {
      test('should create chat session with title', () async {
        // Arrange
        const title = 'テスト相談';

        // Act
        final result = await service.createChatSession(title);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result, containsPair('id', isA<String>()));
        expect(result, containsPair('title', title));
        expect(result, containsPair('createdAt', isA<String>()));
        expect(result, containsPair('updatedAt', isA<String>()));
      });

      test('should create chat session with pet ID', () async {
        // Arrange
        const title = 'テスト相談';
        const petId = 'pet-123';

        // Act
        final result = await service.createChatSession(title, petId: petId);

        // Assert
        expect(result, containsPair('petId', petId));
        expect(result, containsPair('petName', isA<String>()));
      });

      test('should generate unique IDs for different sessions', () async {
        // Arrange
        const title1 = '相談1';
        const title2 = '相談2';

        // Act
        final result1 = await service.createChatSession(title1);
        final result2 = await service.createChatSession(title2);

        // Assert
        expect(result1['id'], isNot(equals(result2['id'])));
      });

      test('should create session with valid timestamps', () async {
        // Arrange
        const title = 'テスト相談';
        final beforeCall = DateTime.now();

        // Act
        final result = await service.createChatSession(title);

        // Assert
        final afterCall = DateTime.now();
        final createdAt = DateTime.parse(result['createdAt'] as String);
        final updatedAt = DateTime.parse(result['updatedAt'] as String);

        expect(
          createdAt.isAfter(beforeCall) ||
              createdAt.isAtSameMomentAs(beforeCall),
          isTrue,
        );
        expect(
          createdAt.isBefore(afterCall) ||
              createdAt.isAtSameMomentAs(afterCall),
          isTrue,
        );
        expect(
          updatedAt.isAfter(beforeCall) ||
              updatedAt.isAtSameMomentAs(beforeCall),
          isTrue,
        );
        expect(
          updatedAt.isBefore(afterCall) ||
              updatedAt.isAtSameMomentAs(afterCall),
          isTrue,
        );
      });
    });

    // Note: _getIconForCategory는 private 메서드이므로
    // getSuggestedQuestions에서 간접적으로 테스트됩니다.

    group('edge cases', () {
      test('should handle empty input gracefully', () async {
        // Act & Assert
        expect(() => service.generateAiResponse(''), returnsNormally);
        expect(() => service.createChatSession(''), returnsNormally);
      });

      test('should handle special characters in input', () async {
        // Arrange
        const specialMessage = 'スペシャル文字: !@#\$%^&*()🎉🚀';

        // Act
        final result = await service.generateAiResponse(specialMessage);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['content'], isA<String>());
      });

      test('should handle very long input', () async {
        // Arrange
        final longMessage = 'テストメッセージ' * 100;

        // Act
        final result = await service.generateAiResponse(longMessage);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['content'], isA<String>());
      });
    });
  });
}
