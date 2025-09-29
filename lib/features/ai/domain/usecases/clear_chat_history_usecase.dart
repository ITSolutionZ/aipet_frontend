import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

class ClearChatHistoryUseCase {
  final AiRepository _repository;

  const ClearChatHistoryUseCase(this._repository);

  Future<Result<void>> call() async {
    try {
      await _repository.clearChatHistory();
      return Result.success('チャット履歴をクリアしました', null);
    } catch (error) {
      return Result.failure('チャット履歴のクリアに失敗しました: ${error.toString()}');
    }
  }
}
