import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';

/// 채팅 히스토리 조회 UseCase
class GetChatHistoryUseCase {
  final AiRepository _repository;

  const GetChatHistoryUseCase(this._repository);

  /// 채팅 히스토리 조회
  ///
  /// Returns: 채팅 메시지 목록
  Future<Result<List<AiMessageEntity>>> call() async {
    try {
      final messages = await _repository.getChatHistory();
      return ResultFactory.success(messages, 'チャット履歴を取得しました').toFuture();
    } catch (error) {
      return ResultFactory.failure<List<AiMessageEntity>>(
        'チャット履歴の取得に失敗しました: ${error.toString()}',
      ).toFuture();
    }
  }
}
