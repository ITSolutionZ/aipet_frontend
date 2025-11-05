import '../../../../shared/shared.dart';

import '../entities/ai_chat_session_entity.dart';
import '../repositories/ai_chat_repository.dart';


/// 채팅 세션 관리 UseCase
class ChatSessionUseCase {
  final AiChatRepository _repository;

  const ChatSessionUseCase(this._repository);

  /// 채팅 세션 목록 조회
  ///
  /// Returns: 채팅 세션 목록
  Future<Result<List<AiChatSessionEntity>>> getSessions() async {
    try {
      final sessions = await _repository.getChatSessions();
      return Result.success('チャットセッション一覧を取得しました', sessions);
    } catch (error) {
      return Result.failure('チャットセッション一覧の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 채팅 세션 생성
  ///
  /// [title] 세션 제목
  /// [petId] 펫 ID (선택사항)
  ///
  /// Returns: 생성된 채팅 세션
  Future<Result<AiChatSessionEntity>> createSession({
    required String title,
    String? petId,
  }) async {
    try {
      // 입력 유효성 검사
      if (title.trim().isEmpty) {
        return Result.failure('セッションタイトルを入力してください');
      }

      if (title.length > 100) {
        return Result.failure('セッションタイトルは100文字以内で入力してください');
      }

      final session = await _repository.createChatSession(title, petId: petId);
      return Result.success('チャットセッションを作成しました', session);
    } catch (error) {
      return Result.failure('チャットセッションの作成に失敗しました: ${error.toString()}');
    }
  }

  /// 채팅 세션 삭제
  ///
  /// [sessionId] 삭제할 세션 ID
  ///
  /// Returns: 삭제 결과
  Future<Result<void>> deleteSession(String sessionId) async {
    try {
      // 입력 유효성 검사
      if (sessionId.trim().isEmpty) {
        return Result.failure('セッションIDが無効です');
      }

      await _repository.deleteChatSession(sessionId);
      return Result.success('チャットセッションを削除しました', null);
    } catch (error) {
      return Result.failure('チャットセッションの削除に失敗しました: ${error.toString()}');
    }
  }
}
