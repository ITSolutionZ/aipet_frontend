import 'package:aipet_frontend/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:aipet_frontend/features/ai/data/services/ai_mock_data_service_impl.dart';
import 'package:aipet_frontend/features/ai/data/services/openai_service.dart';
import 'package:aipet_frontend/features/ai/domain/domain.dart';
import 'package:aipet_frontend/features/pet_registor/pet_registor.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../test_helper.dart';
import 'ai_repository_impl_test.mocks.dart';

@GenerateMocks([OpenAIService, AiMockDataServiceImpl, Ref])
void main() {
  group('AiRepositoryImpl', () {
    late AiRepositoryImpl repository;
    late MockOpenAIService mockOpenAIService;
    late MockAiMockDataServiceImpl mockMockDataService;
    late MockRef mockRef;
    late ProviderContainer container;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockOpenAIService = MockOpenAIService();
      mockMockDataService = MockAiMockDataServiceImpl();
      mockRef = MockRef();

      container = ProviderContainer();

      repository = AiRepositoryImpl(
        openAIService: mockOpenAIService,
        aiMockDataService: mockMockDataService,
        ref: mockRef,
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('getChatHistory', () {
      test('should return chat history from mock data service', () async {
        // Arrange
        final expectedMessages = [
          AiMessageEntity(
            id: 'msg-1',
            content: 'こんにちは',
            type: MessageType.user,
            timestamp: DateTime.now(),
          ),
          AiMessageEntity(
            id: 'msg-2',
            content: 'こんにちは！ペットの相談をお手伝いします',
            type: MessageType.assistant,
            timestamp: DateTime.now(),
          ),
        ];

        when(
          mockMockDataService.simulateApiDelay(),
        ).thenAnswer((_) async => Future.value());
        when(
          mockMockDataService.getChatHistory(),
        ).thenAnswer((_) async => expectedMessages);

        // Act
        final result = await repository.getChatHistory();

        // Assert
        expect(result, equals(expectedMessages));
        verify(mockMockDataService.simulateApiDelay()).called(1);
        verify(mockMockDataService.getChatHistory()).called(1);
      });

      test('should handle empty chat history', () async {
        // Arrange
        when(
          mockMockDataService.simulateApiDelay(),
        ).thenAnswer((_) async => Future.value());
        when(
          mockMockDataService.getChatHistory(),
        ).thenAnswer((_) async => <AiMessageEntity>[]);

        // Act
        final result = await repository.getChatHistory();

        // Assert
        expect(result, isEmpty);
        verify(mockMockDataService.simulateApiDelay()).called(1);
        verify(mockMockDataService.getChatHistory()).called(1);
      });
    });

    group('sendMessage', () {
      test('should send message and return AI response', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えて';
        const expectedResponse = 'ペットの健康管理についてお答えします...';

        // Expected message will be created by the repository

        when(
          mockOpenAIService.generateResponse(userMessage),
        ).thenAnswer((_) async => expectedResponse);

        // Act
        final result = await repository.sendMessage(userMessage);

        // Assert
        expect(result, isA<Result<AiMessageEntity>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.content, equals(expectedResponse));
        expect(result.data!.type, equals(MessageType.assistant));
        verify(mockOpenAIService.generateResponse(userMessage)).called(1);
      });

      test('should handle API error and return error message', () async {
        // Arrange
        const userMessage = 'ペットの健康について教えて';
        const errorMessage = 'API接続エラーが発生しました';

        when(
          mockOpenAIService.generateResponse(userMessage),
        ).thenThrow(Exception(errorMessage));

        // Act
        final result = await repository.sendMessage(userMessage);

        // Assert
        expect(result, isA<Result<AiMessageEntity>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('AI応答の生成に失敗しました'));
        verify(mockOpenAIService.generateResponse(userMessage)).called(1);
      });
    });

    group('sendMessageWithPetContext', () {
      test(
        'should send message with pet context and return AI response',
        () async {
          // Arrange
          const userMessage = 'このペットの健康について教えて';
          const expectedResponse = 'あなたのペットの健康管理について...';

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

          when(
            mockOpenAIService.generateResponse(
              userMessage,
              petContext: petContext,
            ),
          ).thenAnswer((_) async => expectedResponse);

          // Act
          final result = await repository.sendMessageWithPetContext(
            userMessage,
            petContext: petContext,
          );

          // Assert
          expect(result, isA<Result<AiMessageEntity>>());
          expect(result.isSuccess, isTrue);
          expect(result.data, isNotNull);
          expect(result.data!.content, equals(expectedResponse));
          expect(result.data!.type, equals(MessageType.assistant));
          verify(
            mockOpenAIService.generateResponse(
              userMessage,
              petContext: petContext,
            ),
          ).called(1);
        },
      );

      test('should handle API error with pet context', () async {
        // Arrange
        const userMessage = 'このペットの健康について教えて';
        const errorMessage = 'API接続エラーが発生しました';

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

        when(
          mockOpenAIService.generateResponse(
            userMessage,
            petContext: petContext,
          ),
        ).thenThrow(Exception(errorMessage));

        // Act
        final result = await repository.sendMessageWithPetContext(
          userMessage,
          petContext: petContext,
        );

        // Assert
        expect(result, isA<Result<AiMessageEntity>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('AI応答の生成に失敗しました'));
        verify(
          mockOpenAIService.generateResponse(
            userMessage,
            petContext: petContext,
          ),
        ).called(1);
      });
    });

    group('getChatSessions', () {
      test('should return chat sessions from mock data service', () async {
        // Arrange
        final expectedSessions = [
          AiChatSessionEntity(
            id: 'session-1',
            title: '健康相談',
            messages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            petId: 'pet-1',
            petName: 'テストペット',
          ),
        ];

        when(
          mockMockDataService.getChatSessions(),
        ).thenAnswer((_) async => expectedSessions);

        // Act
        final result = await repository.getChatSessions();

        // Assert
        expect(result, equals(expectedSessions));
        verify(mockMockDataService.getChatSessions()).called(1);
      });
    });

    group('createChatSession', () {
      test('should create new chat session', () async {
        // Arrange
        const title = '新しい相談';
        const petId = 'pet-1';

        final mockData = {
          'id': 'session-123',
          'title': title,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'petId': petId,
          'petName': 'テストペット',
        };

        when(
          mockMockDataService.createChatSession(title, petId: petId),
        ).thenAnswer((_) async => mockData);

        // Act
        final result = await repository.createChatSession(title, petId: petId);

        // Assert
        expect(result, isA<AiChatSessionEntity>());
        expect(result.title, equals(title));
        expect(result.petId, equals(petId));
        verify(
          mockMockDataService.createChatSession(title, petId: petId),
        ).called(1);
      });
    });

    group('getSuggestedQuestions', () {
      test(
        'should return suggested questions from mock data service',
        () async {
          // Arrange
          final expectedQuestions = [
            const AiSuggestedQuestionEntity(
              id: 'q-1',
              question: 'ペットの健康について教えて',
              category: 'health',
              icon: Icons.health_and_safety,
              description: '健康管理に関する質問',
            ),
          ];

          when(
            mockMockDataService.getSuggestedQuestions(),
          ).thenAnswer((_) async => expectedQuestions);

          // Act
          final result = await repository.getSuggestedQuestions();

          // Assert
          expect(result, equals(expectedQuestions));
          verify(mockMockDataService.getSuggestedQuestions()).called(1);
        },
      );
    });

    group('addFavoriteMessage', () {
      test('should add message to favorites', () async {
        // Arrange
        final message = AiMessageEntity(
          id: 'msg-1',
          content: 'テストメッセージ',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
        );
        const category = 'health';
        const petId = 'pet-1';
        const petName = 'テストペット';
        const userNote = '重要な情報';

        // Act
        final result = await repository.addFavoriteMessage(
          message,
          category,
          petId: petId,
          petName: petName,
          userNote: userNote,
        );

        // Assert
        expect(result, isA<AiFavoriteEntity>());
        expect(result.message, equals(message));
        expect(result.category, equals(category));
        expect(result.petId, equals(petId));
        expect(result.petName, equals(petName));
        expect(result.userNote, equals(userNote));
      });
    });

    group('generateChatSummary', () {
      test('should generate chat summary', () async {
        // Arrange
        const userMessages = ['ペットの健康について', '食事について教えて'];
        const petName = 'テストペット';
        const category = 'health';

        // Act
        final result = await repository.generateChatSummary(
          userMessages: userMessages,
          petName: petName,
          category: category,
        );

        // Assert
        expect(result, isA<AiChatSummary>());
        expect(result.title, isNotEmpty);
        expect(result.content, isNotEmpty);
        expect(result.content, contains(petName));
        expect(result.content, contains(category));
      });
    });
  });
}
