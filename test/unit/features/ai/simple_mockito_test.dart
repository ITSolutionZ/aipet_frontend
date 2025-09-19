import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'simple_mockito_test.mocks.dart';

@GenerateMocks([AiRepository])
void main() {
  group('AI Mockito Simple Tests', () {
    late MockAiRepository mockRepository;

    setUp(() {
      mockRepository = MockAiRepository();
    });

    test('should mock repository method call', () async {
      // Arrange
      final expectedMessages = [
        AiMessageEntity(
          id: 'msg-1',
          content: 'テストメッセージ',
          type: MessageType.user,
          timestamp: DateTime.now(),
        ),
      ];

      when(
        mockRepository.getChatHistory(),
      ).thenAnswer((_) async => expectedMessages);

      // Act
      final result = await mockRepository.getChatHistory();

      // Assert
      expect(result, equals(expectedMessages));
      verify(mockRepository.getChatHistory()).called(1);
    });

    test('should mock sendMessage method', () async {
      // Arrange
      const userMessage = 'ペットの健康について教えて';
      const expectedResponse = 'ペットの健康管理について...';

      final expectedMessage = AiMessageEntity(
        id: 'ai-msg-1',
        content: expectedResponse,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );

      when(
        mockRepository.sendMessage(userMessage),
      ).thenAnswer((_) async => expectedMessage);

      // Act
      final result = await mockRepository.sendMessage(userMessage);

      // Assert
      expect(result, equals(expectedMessage));
      verify(mockRepository.sendMessage(userMessage)).called(1);
    });

    test('should mock sendMessageWithPetContext method', () async {
      // Arrange
      const userMessage = 'このペットについて教えて';
      const expectedResponse = 'あなたのペットについて...';

      final expectedMessage = AiMessageEntity(
        id: 'ai-msg-1',
        content: expectedResponse,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );

      when(
        mockRepository.sendMessageWithPetContext(userMessage, petContext: null),
      ).thenAnswer((_) async => expectedMessage);

      // Act
      final result = await mockRepository.sendMessageWithPetContext(
        userMessage,
        petContext: null,
      );

      // Assert
      expect(result, equals(expectedMessage));
      verify(
        mockRepository.sendMessageWithPetContext(userMessage, petContext: null),
      ).called(1);
    });

    test('should mock error scenario', () async {
      // Arrange
      const userMessage = 'テストメッセージ';
      const errorMessage = 'APIエラーが発生しました';

      when(
        mockRepository.sendMessage(userMessage),
      ).thenThrow(Exception(errorMessage));

      // Act & Assert
      expect(
        () => mockRepository.sendMessage(userMessage),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.sendMessage(userMessage)).called(1);
    });

    test('should mock multiple calls', () async {
      // Arrange
      final messages = [
        AiMessageEntity(
          id: 'msg-1',
          content: 'メッセージ1',
          type: MessageType.user,
          timestamp: DateTime.now(),
        ),
      ];

      when(mockRepository.getChatHistory()).thenAnswer((_) async => messages);

      // Act
      final result1 = await mockRepository.getChatHistory();
      final result2 = await mockRepository.getChatHistory();

      // Assert
      expect(result1, equals(messages));
      expect(result2, equals(messages));
      verify(mockRepository.getChatHistory()).called(2);
    });

    test('should verify no interactions', () {
      // Act & Assert
      verifyNever(mockRepository.getChatHistory());
      verifyZeroInteractions(mockRepository);
    });
  });
}
