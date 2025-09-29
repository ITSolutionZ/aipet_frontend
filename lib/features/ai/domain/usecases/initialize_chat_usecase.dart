import 'package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class InitializeChatUseCase {
  final AiRepository _repository;

  const InitializeChatUseCase(this._repository);

  Future<Result<List<AiSuggestedQuestionEntity>>> call() async {
    try {
      final suggestedQuestions = await _repository.getSuggestedQuestions();
      return Result.success(suggestedQuestions, 'チャットが初期化されました');
    } catch (error) {
      return Result.failure<List<AiSuggestedQuestionEntity>>(
        'チャット初期化に失敗しました: ${error.toString()}',
      );
    }
  }
}
