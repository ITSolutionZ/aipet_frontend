import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_session_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 채팅 세션 관리 UseCase
class ChatSessionUseCase {
  final AiRepository _repository;

  const ChatSessionUseCase(this._repository);

  /// 채팅 세션 목록 조회
  ///
  /// Returns: 채팅 세션 목록
  Future<Result<List<AiChatSessionEntity>>> getSessions() async {
    try {
      final sessions = await _repository.getChatSessions();
      return Result.success(sessions, 'チャットセッション一覧を取得しました').toFuture();
    } catch (error) {
      return Result.failure<List<AiChatSessionEntity>>(
        'チャットセッション一覧の取得に失敗しました: ${error.toString()}',
      ).toFuture();
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
        return Result.failure<AiChatSessionEntity>(
          'セッションタイトルを入力してください',
        ).toFuture();
      }

      if (title.length > 100) {
        return Result.failure<AiChatSessionEntity>(
          'セッションタイトルは100文字以内で入力してください',
        ).toFuture();
      }

      final session = await _repository.createChatSession(title, petId: petId);
      return Result.success(session, 'チャットセッションを作成しました').toFuture();
    } catch (error) {
      return Result.failure<AiChatSessionEntity>(
        'チャットセッションの作成に失敗しました: ${error.toString()}',
      ).toFuture();
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
        return Result.failure<void>('セッションIDが無効です').toFuture();
      }

      await _repository.deleteChatSession(sessionId);
      return Result.success(null, 'チャットセッションを削除しました').toFuture();
    } catch (error) {
      return Result.failure<void>(
        'チャットセッションの削除に失敗しました: ${error.toString()}',
      ).toFuture();
    }
  }
}
