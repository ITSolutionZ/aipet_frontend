import '../../../../shared/shared.dart';

import '../entities/ai_suggested_question_entity.dart';
import '../repositories/ai_repository.dart';


class InitializeChatUseCase {
  final AiRepository _repository;

  const InitializeChatUseCase(this._repository);

  Future<Result<List<AiSuggestedQuestionEntity>>> call() async {
    try {
      final suggestedQuestions = await _repository.getSuggestedQuestions();
      return Result.success('チャットが初期化されました', suggestedQuestions);
    } catch (error) {
      return Result.failure('チャット初期化に失敗しました: ${error.toString()}');
    }
  }
}
