import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/shared.dart';

/// 채팅 히스토리 조회 UseCase
class GetChatHistoryUseCase {
  final AiRepository _repository;

  const GetChatHistoryUseCase(this._repository);

  /// 채팅 히스토리 조회
  ///
  /// Returns: 채팅 메시지 목록
  Future<Result<List<AiMessageEntity>>> call() async {
    try {
      // Repository를 통한 채팅 히스토리 조회
      final messages = await _repository.getChatHistory();
      return Future.value(ResultFactory.success(messages, 'チャット履歴を取得しました'));
    } catch (error) {
      return Future.value(
        ResultFactory.failure<List<AiMessageEntity>>(
          'チャット履歴の取得に失敗しました: ${error.toString()}',
        ),
      );
    }
  }
}

/// 채팅 히스토리 삭제 UseCase
class ClearChatHistoryUseCase {
  final AiRepository _repository;

  const ClearChatHistoryUseCase(this._repository);

  /// 채팅 히스토리 삭제
  ///
  /// Returns: 삭제 결과
  Future<Result<void>> call() async {
    try {
      // Repository를 통한 채팅 히스토리 삭제
      await _repository.clearChatHistory();
      return Future.value(ResultFactory.success(null, 'チャット履歴をクリアしました'));
    } catch (error) {
      return Future.value(
        ResultFactory.failure<void>('チャット履歴のクリアに失敗しました: ${error.toString()}'),
      );
    }
  }
}
