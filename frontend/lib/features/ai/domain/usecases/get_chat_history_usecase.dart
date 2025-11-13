import 'package:aipet_frontend/shared/shared.dart';

import '../entities/ai_message_entity.dart';
import '../repositories/ai_chat_repository.dart';

/// 채팅 히스토리 조회 UseCase
class GetChatHistoryUseCase {
  final AiChatRepository _repository;

  const GetChatHistoryUseCase(this._repository);

  /// 채팅 히스토리 조회
  ///
  /// Returns: 채팅 메시지 목록
  Future<Result<List<AiMessageEntity>>> call() async {
    try {
      final messages = await _repository.getChatHistory();
      return Result.success('チャット履歴を取得しました', messages);
    } catch (error) {
      return Result.failure('チャット履歴の取得に失敗しました: ${error.toString()}');
    }
  }
}
