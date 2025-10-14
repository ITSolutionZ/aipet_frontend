import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

import '../entities/ai_suggested_question_entity.dart';

/// AI 제안 관련 Repository
abstract class AiSuggestionRepository {
  /// 추천 질문 관련
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions({
    String? categoryId,
    String? petId,
  });

  Future<List<AiSuggestedQuestionEntity>> getPersonalizedSuggestedQuestions({
    String? category,
    PetProfileEntity? pet,
  });

  Future<Result<List<AiSuggestedQuestionEntity>>>
  getSuggestedQuestionsWithParams({String? petId, String? categoryId});

  /// 후속 질문 생성
  Future<List<AiSuggestedQuestionEntity>> generateFollowUpQuestions({
    required String conversationContext,
    String? petId,
    String? categoryId,
  });

  /// 카테고리별 질문 템플릿
  Future<List<AiSuggestedQuestionEntity>> getQuestionTemplates(
    String categoryId,
  );

  /// 사용자 맞춤 질문 생성
  Future<List<AiSuggestedQuestionEntity>> generatePersonalizedQuestions({
    required String userId,
    String? petId,
    List<String>? recentTopics,
  });
}
