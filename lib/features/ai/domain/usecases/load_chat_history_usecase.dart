import 'package:aipet_frontend/shared/shared.dart';

import '../entities/ai_message_entity.dart';
import '../repositories/ai_chat_repository.dart';

/// 📜 채팅 히스토리 로드 UseCase
class LoadChatHistoryUseCase {
  final AiChatRepository _repository;

  const LoadChatHistoryUseCase(this._repository);

  Future<Result<List<AiMessageEntity>>> call(
    LoadChatHistoryParams params,
  ) async {
    try {
      final result = await _repository.loadChatHistory(
        userId: params.userId,
        petId: params.petId,
        limit: params.limit,
        offset: params.offset,
      );

      if (result.isSuccess) {
        return Result.success('チャット履歴を読み込みました', result.dataOrNull!);
      } else {
        return Result.failure('チャット履歴の読み込みに失敗しました');
      }
    } catch (error) {
      return Result.failure('チャット履歴の読み込みに失敗しました: ${error.toString()}');
    }
  }
}

/// 📜 채팅 히스토리 로드 파라미터
class LoadChatHistoryParams {
  final String userId;
  final String? petId;
  final int? limit;
  final int? offset;

  const LoadChatHistoryParams({
    required this.userId,
    this.petId,
    this.limit,
    this.offset,
  });
}
