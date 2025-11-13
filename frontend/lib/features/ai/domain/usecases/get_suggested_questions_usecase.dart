import 'package:aipet_frontend/shared/shared.dart';

import '../entities/ai_category_entity.dart';
import '../entities/ai_suggested_question_entity.dart';
import '../repositories/ai_repository.dart';

/// 추천 질문 조회 UseCase
class GetSuggestedQuestionsUseCase {
  final AiRepository _repository;

  const GetSuggestedQuestionsUseCase(this._repository);

  /// 기본 추천 질문 조회
  ///
  /// Returns: 추천 질문 목록
  Future<Result<List<AiSuggestedQuestionEntity>>> call(
    GetSuggestedQuestionsParams params,
  ) async {
    try {
      final questionsResult = await _repository.getSuggestedQuestionsWithParams(
        petId: params.petProfile.id,
        categoryId: params.category?.id,
      );
      if (questionsResult.isSuccess) {
        return Result.success('推奨質問を取得しました', questionsResult.dataOrNull!);
      } else {
        return Result.failure('推奨質問の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('推奨質問の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 펫 정보 기반 맞춤형 추천 질문 조회
  ///
  /// [category] 질문 카테고리 (선택사항)
  /// [pet] 펫 프로필 정보 (선택사항)
  ///
  /// Returns: 맞춤형 추천 질문 목록
  Future<Result<List<AiSuggestedQuestionEntity>>> callPersonalized({
    String? category,
    PetProfileEntity? pet,
  }) async {
    try {
      // Repository를 통한 맞춤형 추천 질문 조회
      final questions = await _repository.getPersonalizedSuggestedQuestions(
        category: category,
        pet: pet,
      );
      return Result.success('カスタマイズされた推奨質問を取得しました', questions);
    } catch (error) {
      return Result.failure(
        '推奨質問の取得に失敗しました (personalized): ${error.toString()}',
      );
    }
  }
}

/// 🎯 추천 질문 조회 파라미터
class GetSuggestedQuestionsParams {
  final PetProfileEntity petProfile;
  final AiCategoryEntity? category;

  const GetSuggestedQuestionsParams({required this.petProfile, this.category});
}
