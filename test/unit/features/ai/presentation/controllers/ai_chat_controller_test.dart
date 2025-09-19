import 'package:aipet_frontend/features/ai/data/providers/ai_providers.dart';
import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/features/ai/presentation/controllers/ai_chat_controller.dart';
import 'package:aipet_frontend/features/pet_registor/pet_registor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ai_chat_controller_test.mocks.dart';

// 테스트용 임시 Provider 정의
final aiChatControllerProvider =
    NotifierProvider<AiChatController, AiChatState>(() => AiChatController());

@GenerateMocks([AiRepository])
void main() {
  group('AiChatController', () {
    late MockAiRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockAiRepository();
      container = ProviderContainer(
        overrides: [
          // Repository를 Mock으로 오버라이드
          aiRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('sendMessage', () {
      test('should send message and add to chat history', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えてください';
        const aiResponse = 'ペットの健康管理についてお答えします...';

        final userMessageEntity = AiMessageEntity(
          id: 'user-msg-1',
          content: userMessage,
          type: MessageType.user,
          timestamp: DateTime.now(),
        );

        final aiMessageEntity = AiMessageEntity(
          id: 'ai-msg-1',
          content: aiResponse,
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        );

        when(
          mockRepository.sendMessage(userMessage),
        ).thenAnswer((_) async => aiMessageEntity);

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        await controller.sendMessage(userMessage);

        // Assert
        verify(mockRepository.sendMessage(userMessage)).called(1);

        final state = container.read(aiChatControllerProvider);
        expect(state.messages, hasLength(2));
        expect(state.messages.first.content, equals(userMessage));
        expect(state.messages.first.type, equals(MessageType.user));
        expect(state.messages.last.content, equals(aiResponse));
        expect(state.messages.last.type, equals(MessageType.assistant));
      });

      test('should handle API error gracefully', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えてください';
        const errorMessage = 'API接続エラーが発生しました';

        when(
          mockRepository.sendMessage(userMessage),
        ).thenThrow(Exception(errorMessage));

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        await controller.sendMessage(userMessage);

        // Assert
        verify(mockRepository.sendMessage(userMessage)).called(1);

        final state = container.read(aiChatControllerProvider);
        expect(state.messages, hasLength(2));
        expect(state.messages.first.content, equals(userMessage));
        expect(state.messages.first.type, equals(MessageType.user));
        expect(state.messages.last.content, contains(errorMessage));
        expect(state.messages.last.type, equals(MessageType.assistant));
      });

      test('should set typing state during API call', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えてください';
        const aiResponse = 'ペットの健康管理についてお答えします...';

        final aiMessageEntity = AiMessageEntity(
          id: 'ai-msg-1',
          content: aiResponse,
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        );

        when(mockRepository.sendMessage(userMessage)).thenAnswer((_) async {
          // API 호출 중에는 typing 상태가 true여야 함
          await Future.delayed(const Duration(milliseconds: 100));
          return aiMessageEntity;
        });

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);

        // API 호출 시작
        final sendMessageFuture = controller.sendMessage(userMessage);

        // API 호출 중 상태 확인
        final typingState = container.read(aiChatControllerProvider);
        expect(typingState.isTyping, isTrue);

        // API 호출 완료 대기
        await sendMessageFuture;

        // API 호출 완료 후 상태 확인
        final finalState = container.read(aiChatControllerProvider);
        expect(finalState.isTyping, isFalse);
      });
    });

    group('sendMessageWithPetContext', () {
      test('should send message with pet context', () async {
        // Arrange
        const userMessage = 'このペットの健康について教えて';
        const aiResponse = 'あなたのペットの健康管理について...';

        final petContext = PetProfileEntity(
          id: 'pet-1',
          name: 'テストペット',
          type: 'dog',
          breed: '柴犬',
          age: 3,
          weight: 10.0,
          gender: 'male',
          birthDate: DateTime(2021, 1, 1),
          ownerId: 'owner-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final aiMessageEntity = AiMessageEntity(
          id: 'ai-msg-1',
          content: aiResponse,
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        );

        when(
          mockRepository.sendMessageWithPetContext(
            userMessage,
            petContext: petContext,
          ),
        ).thenAnswer((_) async => aiMessageEntity);

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        await controller.sendMessageWithPetContext(
          userMessage,
          petContext: petContext,
        );

        // Assert
        verify(
          mockRepository.sendMessageWithPetContext(
            userMessage,
            petContext: petContext,
          ),
        ).called(1);

        final state = container.read(aiChatControllerProvider);
        expect(state.messages, hasLength(2));
        expect(state.messages.last.content, equals(aiResponse));
      });
    });

    group('loadChatHistory', () {
      test('should load chat history from repository', () async {
        // Arrange
        final expectedMessages = [
          AiMessageEntity(
            id: 'msg-1',
            content: 'こんにちは',
            type: MessageType.user,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          AiMessageEntity(
            id: 'msg-2',
            content: 'こんにちは！ペットの相談をお手伝いします',
            type: MessageType.assistant,
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ];

        when(
          mockRepository.getChatHistory(),
        ).thenAnswer((_) async => expectedMessages);

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        await controller.loadChatHistory();

        // Assert
        verify(mockRepository.getChatHistory()).called(1);

        final state = container.read(aiChatControllerProvider);
        expect(state.messages, equals(expectedMessages));
      });

      test('should handle empty chat history', () async {
        // Arrange
        when(
          mockRepository.getChatHistory(),
        ).thenAnswer((_) async => <AiMessageEntity>[]);

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        await controller.loadChatHistory();

        // Assert
        verify(mockRepository.getChatHistory()).called(1);

        final state = container.read(aiChatControllerProvider);
        expect(state.messages, isEmpty);
      });
    });

    group('loadSuggestedQuestions', () {
      test('should load suggested questions from repository', () async {
        // Arrange
        final expectedQuestions = [
          const AiSuggestedQuestionEntity(
            id: 'q-1',
            question: 'ペットの健康について教えて',
            category: 'health',
            icon: Icons.health_and_safety,
            description: '健康管理に関する質問',
          ),
          const AiSuggestedQuestionEntity(
            id: 'q-2',
            question: 'ペットの食事について',
            category: 'nutrition',
            icon: Icons.restaurant,
            description: '栄養管理に関する質問',
          ),
        ];

        when(
          mockRepository.getSuggestedQuestions(),
        ).thenAnswer((_) async => expectedQuestions);

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        await controller.loadSuggestedQuestions();

        // Assert
        verify(mockRepository.getSuggestedQuestions()).called(1);

        final state = container.read(aiChatControllerProvider);
        expect(state.suggestedQuestions, equals(expectedQuestions));
      });
    });

    group('selectPet', () {
      test('should select pet and update state', () {
        // Arrange
        final pet = PetProfileEntity(
          id: 'pet-1',
          name: 'テストペット',
          type: 'dog',
          breed: '柴犬',
          age: 3,
          weight: 10.0,
          birthDate: DateTime(2021, 1, 1),
          createdAt: DateTime.now(),
        );

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        controller.selectPet(pet);

        // Assert
        final state = container.read(aiChatControllerProvider);
        expect(state.selectedPet, equals(pet));
        expect(state.hasPetSelected, isTrue);
      });

      test('should clear pet selection', () {
        // Arrange
        final pet = PetProfileEntity(
          id: 'pet-1',
          name: 'テストペット',
          type: 'dog',
          breed: '柴犬',
          age: 3,
          weight: 10.0,
          birthDate: DateTime(2021, 1, 1),
          createdAt: DateTime.now(),
        );

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        controller.selectPet(pet);
        controller.clearPetSelection();

        // Assert
        final state = container.read(aiChatControllerProvider);
        expect(state.selectedPet, isNull);
        expect(state.hasPetSelected, isFalse);
      });
    });

    group('selectCategory', () {
      test('should select category and update state', () {
        // Arrange
        const category = 'health';

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        controller.selectCategory(category);

        // Assert
        final state = container.read(aiChatControllerProvider);
        expect(state.selectedCategory, equals(category));
        expect(state.hasCategorySelected, isTrue);
      });

      test('should clear category selection', () {
        // Arrange
        const category = 'health';

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        controller.selectCategory(category);
        controller.clearCategorySelection();

        // Assert
        final state = container.read(aiChatControllerProvider);
        expect(state.selectedCategory, isNull);
        expect(state.hasCategorySelected, isFalse);
      });
    });

    group('toggleFavoriteMessage', () {
      test('should add message to favorites', () async {
        // Arrange
        final message = AiMessageEntity(
          id: 'msg-1',
          content: 'テストメッセージ',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        );

        when(
          mockRepository.addFavoriteMessage(
            message,
            any,
            petId: anyNamed('petId'),
            petName: anyNamed('petName'),
            userNote: anyNamed('userNote'),
          ),
        ).thenAnswer(
          (_) async => AiFavoriteEntity(
            id: 'fav-1',
            message: message,
            category: 'health',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        // Act
        final controller = container.read(aiChatControllerProvider.notifier);
        await controller.toggleFavoriteMessage(message);

        // Assert
        verify(
          mockRepository.addFavoriteMessage(
            message,
            any,
            petId: anyNamed('petId'),
            petName: anyNamed('petName'),
            userNote: anyNamed('userNote'),
          ),
        ).called(1);

        final state = container.read(aiChatControllerProvider);
        expect(state.favoriteMessageIds, contains(message.id));
      });
    });

    group('clearChat', () {
      test('should clear all messages and reset state', () {
        // Arrange
        final controller = container.read(aiChatControllerProvider.notifier);

        // Add some messages first
        controller.addMessage(
          AiMessageEntity(
            id: 'msg-1',
            content: 'テストメッセージ',
            type: MessageType.user,
            timestamp: DateTime.now(),
          ),
        );

        // Act
        controller.clearChat();

        // Assert
        final state = container.read(aiChatControllerProvider);
        expect(state.messages, isEmpty);
        expect(state.isTyping, isFalse);
        expect(state.selectedPet, isNull);
        expect(state.selectedCategory, isNull);
        expect(state.hasPetSelected, isFalse);
        expect(state.hasCategorySelected, isFalse);
      });
    });
  });
}
