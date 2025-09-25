import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/features/ai/domain/usecases/get_chat_history_usecase.dart';
import 'package:aipet_frontend/features/ai/domain/usecases/initialize_chat_usecase.dart';
import 'package:aipet_frontend/features/ai/domain/usecases/send_message_usecase.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ai_chat_flow_test.mocks.dart';

@GenerateMocks([AiRepository])
void main() {
  group('AI Chat Flow Integration Tests', () {
    late MockAiRepository mockRepository;
    late InitializeChatUseCase initializeChatUseCase;
    late SendMessageUseCase sendMessageUseCase;
    late GetChatHistoryUseCase getChatHistoryUseCase;

    setUp(() {
      mockRepository = MockAiRepository();
      initializeChatUseCase = InitializeChatUseCase(mockRepository);
      sendMessageUseCase = SendMessageUseCase(mockRepository);
      getChatHistoryUseCase = GetChatHistoryUseCase(mockRepository);
    });

    group('Complete Chat Flow', () {
      test(
        'should handle complete chat flow from initialization to message exchange',
        () async {
          // Arrange
          final petContext = PetProfileEntity(
            id: 'pet_1',
            name: 'ポチ',
            type: PetType.dog,
            breed: '柴犬',
            age: 3,
            birthDate: DateTime(2021, 1, 1),
            createdAt: DateTime.now(),
          );

          final initialMessages = [
            AiMessageEntity(
              id: 'msg_1',
              content: 'こんにちは！ペットについて何かお手伝いできることはありますか？',
              type: MessageType.assistant,
              timestamp: DateTime.now(),
            ),
          ];

          const userMessage = '散歩について相談したいです';
          final aiResponse = AiMessageEntity(
            id: 'msg_2',
            content: 'ポチの散歩についてお手伝いできます。柴犬の特性を考慮したアドバイスを提供します。',
            type: MessageType.assistant,
            timestamp: DateTime.now(),
            petId: 'pet_1',
            petName: 'ポチ',
          );

          // Mock repository responses
          when(
            mockRepository.getChatHistory(),
          ).thenAnswer((_) async => initialMessages);

          when(
            mockRepository.sendMessageWithPetContext(
              userMessage,
              petContext: petContext,
            ),
          ).thenAnswer(
            (_) async => ResultFactory.success(aiResponse, 'メッセージを送信しました'),
          );

          when(
            mockRepository.getChatHistory(),
          ).thenAnswer((_) async => [...initialMessages, aiResponse]);

          // Act & Assert - Step 1: Initialize chat
          final initResult = await initializeChatUseCase.call();
          expect(initResult.isSuccess, true);
          expect(initResult.dataOrNull, initialMessages);
          verify(mockRepository.getChatHistory()).called(1);

          // Act & Assert - Step 2: Send message with pet context
          final sendResult = await sendMessageUseCase.call(
            userMessage,
            petContext: petContext,
          );
          expect(sendResult.isSuccess, true);
          expect(sendResult.dataOrNull, aiResponse);
          expect(sendResult.dataOrNull?.petId, 'pet_1');
          expect(sendResult.dataOrNull?.petName, 'ポチ');
          verify(
            mockRepository.sendMessageWithPetContext(
              userMessage,
              petContext: petContext,
            ),
          ).called(1);

          // Act & Assert - Step 3: Get updated chat history
          final historyResult = await getChatHistoryUseCase.call();
          expect(historyResult.isSuccess, true);
          expect(historyResult.dataOrNull?.length, 2);
          expect(historyResult.dataOrNull?.last.content, aiResponse.content);
          verify(mockRepository.getChatHistory()).called(1);
        },
      );

      test('should handle chat flow with multiple message exchanges', () async {
        // Arrange
        final petContext = PetProfileEntity(
          id: 'pet_2',
          name: 'ミケ',
          type: PetType.cat,
          breed: 'アメリカンショートヘア',
          age: 2,
          birthDate: DateTime(2022, 3, 15),
          createdAt: DateTime.now(),
        );

        final messages = <AiMessageEntity>[];

        // Mock repository to simulate conversation
        when(mockRepository.getChatHistory()).thenAnswer((_) async => messages);

        when(
          mockRepository.sendMessageWithPetContext(
            any,
            petContext: anyNamed('petContext'),
          ),
        ).thenAnswer((invocation) async {
          final userMessage = invocation.positionalArguments[0] as String;
          final petContext =
              invocation.namedArguments[#petContext] as PetProfileEntity;

          final aiResponse = AiMessageEntity(
            id: 'msg_${messages.length + 1}',
            content: '${petContext.name}についての$userMessageについてお手伝いできます。',
            type: MessageType.assistant,
            timestamp: DateTime.now(),
            petId: petContext.id,
            petName: petContext.name,
          );

          messages.add(aiResponse);
          return ResultFactory.success(aiResponse, 'メッセージを送信しました');
        });

        // Act & Assert - Multiple message exchanges
        final messagesToSend = [
          '健康管理について教えてください',
          '餌の量はどのくらいが適切ですか？',
          '運動不足の解消方法はありますか？',
        ];

        for (int i = 0; i < messagesToSend.length; i++) {
          final message = messagesToSend[i];

          // Send message
          final sendResult = await sendMessageUseCase.call(
            message,
            petContext: petContext,
          );

          expect(sendResult.isSuccess, true);
          expect(sendResult.dataOrNull?.petId, petContext.id);
          expect(sendResult.dataOrNull?.petName, petContext.name);

          // Verify message was added to history
          final historyResult = await getChatHistoryUseCase.call();
          expect(historyResult.isSuccess, true);
          expect(historyResult.dataOrNull?.length, i + 1);
        }

        // Verify final conversation state
        final finalHistory = await getChatHistoryUseCase.call();
        expect(finalHistory.isSuccess, true);
        expect(finalHistory.dataOrNull?.length, 3);

        // Verify all messages are about the correct pet
        for (final message in finalHistory.dataOrNull!) {
          expect(message.petId, petContext.id);
          expect(message.petName, petContext.name);
        }
      });

      test('should handle chat flow with error recovery', () async {
        // Arrange
        final petContext = PetProfileEntity(
          id: 'pet_3',
          name: 'タロウ',
          type: PetType.dog,
          breed: 'ゴールデンレトリバー',
          age: 5,
          birthDate: DateTime(2019, 6, 10),
          createdAt: DateTime.now(),
        );

        const userMessage = '病気の症状について相談したいです';

        // Mock repository to simulate error then recovery
        when(
          mockRepository.getChatHistory(),
        ).thenAnswer((_) async => <AiMessageEntity>[]);

        when(
          mockRepository.sendMessageWithPetContext(
            userMessage,
            petContext: petContext,
          ),
        ).thenThrow(Exception('Network error')).thenAnswer((_) async {
          final aiResponse = AiMessageEntity(
            id: 'msg_recovery',
            content: 'タロウの健康についてお手伝いできます。症状を詳しく教えてください。',
            type: MessageType.assistant,
            timestamp: DateTime.now(),
            petId: petContext.id,
            petName: petContext.name,
          );
          return ResultFactory.success(aiResponse, 'メッセージを送信しました');
        });

        // Act & Assert - First attempt should fail
        final firstResult = await sendMessageUseCase.call(
          userMessage,
          petContext: petContext,
        );
        expect(firstResult.isFailure, true);
        expect(firstResult.errorOrNull, contains('メッセージの送信に失敗しました'));

        // Act & Assert - Second attempt should succeed
        final secondResult = await sendMessageUseCase.call(
          userMessage,
          petContext: petContext,
        );
        expect(secondResult.isSuccess, true);
        expect(secondResult.dataOrNull?.petId, petContext.id);
        expect(secondResult.dataOrNull?.petName, petContext.name);
      });
    });

    group('Chat History Management', () {
      test('should maintain chat history across multiple sessions', () async {
        // Arrange
        final initialHistory = [
          AiMessageEntity(
            id: 'msg_1',
            content: 'こんにちは！',
            type: MessageType.assistant,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          AiMessageEntity(
            id: 'msg_2',
            content: 'ペットについて何かお手伝いできることはありますか？',
            type: MessageType.assistant,
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ];

        when(
          mockRepository.getChatHistory(),
        ).thenAnswer((_) async => initialHistory);

        // Act & Assert - Initialize chat should return existing history
        final initResult = await initializeChatUseCase.call();
        expect(initResult.isSuccess, true);
        expect(initResult.dataOrNull?.length, 2);
        expect(initResult.dataOrNull?.first.content, 'こんにちは！');
        expect(
          initResult.dataOrNull?.last.content,
          'ペットについて何かお手伝いできることはありますか？',
        );
      });

      test('should handle empty chat history', () async {
        // Arrange
        when(
          mockRepository.getChatHistory(),
        ).thenAnswer((_) async => <AiMessageEntity>[]);

        // Act & Assert
        final initResult = await initializeChatUseCase.call();
        expect(initResult.isSuccess, true);
        expect(initResult.dataOrNull, isEmpty);
      });
    });

    group('Pet Context Integration', () {
      test('should maintain pet context throughout conversation', () async {
        // Arrange
        final petContext = PetProfileEntity(
          id: 'pet_4',
          name: 'ハナ',
          type: PetType.cat,
          breed: 'ペルシャ',
          age: 4,
          birthDate: DateTime(2020, 2, 14),
          createdAt: DateTime.now(),
        );

        final conversationMessages = [
          'こんにちは、ハナについて相談があります',
          'ハナの毛玉ケアについて教えてください',
          'ハナの運動不足が心配です',
        ];

        when(
          mockRepository.getChatHistory(),
        ).thenAnswer((_) async => <AiMessageEntity>[]);

        when(
          mockRepository.sendMessageWithPetContext(
            any,
            petContext: anyNamed('petContext'),
          ),
        ).thenAnswer((invocation) async {
          final userMessage = invocation.positionalArguments[0] as String;
          final petContext =
              invocation.namedArguments[#petContext] as PetProfileEntity;

          final aiResponse = AiMessageEntity(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            content: '${petContext.name}についての$userMessageについてお手伝いできます。',
            type: MessageType.assistant,
            timestamp: DateTime.now(),
            petId: petContext.id,
            petName: petContext.name,
          );

          return ResultFactory.success(aiResponse, 'メッセージを送信しました');
        });

        // Act & Assert - Send multiple messages with pet context
        for (final message in conversationMessages) {
          final result = await sendMessageUseCase.call(
            message,
            petContext: petContext,
          );

          expect(result.isSuccess, true);
          expect(result.dataOrNull?.petId, petContext.id);
          expect(result.dataOrNull?.petName, petContext.name);
          expect(result.dataOrNull?.content, contains(petContext.name));
        }
      });
    });
  });
}
