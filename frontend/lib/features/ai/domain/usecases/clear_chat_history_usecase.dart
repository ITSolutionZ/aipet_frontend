import 'package:aipet_frontend/shared/shared.dart';

import '../repositories/ai_chat_repository.dart';

class ClearChatHistoryUseCase {
  final AiChatRepository _repository;

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
