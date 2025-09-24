import 'package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 추천 질문 조회 UseCase
class GetSuggestedQuestionsUseCase {
  final AiRepository _repository;

  const GetSuggestedQuestionsUseCase(this._repository);

  /// 기본 추천 질문 조회
  ///
  /// Returns: 추천 질문 목록
  Future<Result<List<AiSuggestedQuestionEntity>>> call() async {
    try {
      // Repository를 통한 추천 질문 조회
      final questions = await _repository.getSuggestedQuestions();
      return ResultFactory.success(questions, '推奨質問を取得しました').toFuture();
    } catch (error) {
      return ResultFactory.failure<List<AiSuggestedQuestionEntity>>(
        '推奨質問の取得に失敗しました: ${error.toString()}',
      ).toFuture();
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
      return ResultFactory.success(questions, 'カスタマイズされた推奨質問を取得しました');
    } catch (error) {
      return ResultFactory.failure<List<AiSuggestedQuestionEntity>>(
        '推奨質問の取得に失敗しました: ${error.toString()}',
      ).toFuture();
    }
  }
}
