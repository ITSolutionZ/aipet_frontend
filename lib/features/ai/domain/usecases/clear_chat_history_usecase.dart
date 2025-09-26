import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

class ClearChatHistoryUseCase {
  final AiRepository _repository;

  const ClearChatHistoryUseCase(this._repository);

  Future<Result<void>> call() async {
    try {
      await _repository.clearChatHistory();
      return ResultFactory.success(null, 'チャット履歴をクリアしました');
    } catch (error) {
      return ResultFactory.failure<void>(
        'チャット履歴のクリアに失敗しました: ${error.toString()}',
      );
    }
  }
}
