import 'package:aipet_frontend/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AiRepository repository;
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    repository = AiRepositoryImpl(ref: container);
  });

  tearDown(() {
    container.dispose();
  });

  group('AiRepository - 추천 질문 테스트', () {
    test('추천 질문 목록을 가져올 수 있다', () async {
      // Act
      final questions = await repository.getSuggestedQuestions();

      // Assert
      expect(questions, isA<List<AiSuggestedQuestionEntity>>());
    });

    test('맞춤형 추천 질문을 가져올 수 있다', () async {
      // Arrange
      const category = 'health';

      // Act
      final questions = await repository.getPersonalizedSuggestedQuestions(
        category: category,
      );

      // Assert
      expect(questions, isA<List<AiSuggestedQuestionEntity>>());
      expect(questions.isNotEmpty, true);
    });

    test('파라미터와 함께 추천 질문을 가져올 수 있다', () async {
      // Arrange
      const petId = 'test_pet_id';
      const categoryId = 'health';

      // Act
      final result = await repository.getSuggestedQuestionsWithParams(
        petId: petId,
        categoryId: categoryId,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, isA<List<AiSuggestedQuestionEntity>>());
    });
  });

  group('AiRepository - 즐겨찾기 테스트', () {
    test('즐겨찾기 메시지를 추가할 수 있다', () async {
      // Arrange
      final message = AiMessageEntity(
        id: 'test_message_id',
        content: 'Test message content',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
      const category = 'health';

      // Act
      final favorite = await repository.addFavoriteMessage(
        message,
        category,
        petId: 'test_pet_id',
        petName: 'Test Pet',
      );

      // Assert
      expect(favorite.id, isNotEmpty);
      expect(favorite.message.id, message.id);
      expect(favorite.category, category);
    });

    test('즐겨찾기 메시지 목록을 가져올 수 있다', () async {
      // Act
      final favorites = await repository.getFavoriteMessages();

      // Assert
      expect(favorites, isA<List>());
    });

    test('카테고리별 즐겨찾기를 필터링할 수 있다', () async {
      // Arrange
      const category = 'health';

      // Act
      final favorites = await repository.getFavoriteMessages(
        category: category,
      );

      // Assert
      expect(favorites, isA<List>());
    });

    test('즐겨찾기 QA 목록을 가져올 수 있다', () async {
      // Act
      final favoriteQAs = await repository.getFavoriteQAs();

      // Assert
      expect(favoriteQAs, isA<List>());
    });

    test('즐겨찾기를 토글할 수 있다', () async {
      // Arrange
      const messageId = 'test_message_id';

      // Act
      final result = await repository.toggleFavoriteMessage(messageId);

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, isA<bool>());
    });
  });

  group('AiRepository - 분석 테스트', () {
    test('메시지를 분석할 수 있다', () async {
      // Arrange
      const message = 'ペットの健康について教えてください';
      const petId = 'test_pet_id';

      // Act
      final result = await repository.analyzeMessage(
        message: message,
        petId: petId,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, isNotNull);
      expect(result.dataOrNull!.topics, isNotEmpty);
    });

    test('분석 결과에 주제가 포함된다', () async {
      // Arrange
      const message = 'ペットの散歩について';

      // Act
      final result = await repository.analyzeMessage(message: message);

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull!.topics, isNotEmpty);
    });
  });
}
