import '../entities/ai_message_entity.dart';

abstract class AiRepository {
  /// 채팅 기록 가져오기
  Future<List<AiMessageEntity>> getChatHistory();

  /// 메시지 전송하기
  Future<AiMessageEntity> sendMessage(String message);

  /// 채팅 기록 지우기
  Future<void> clearChatHistory();

  /// 채팅 세션 목록 가져오기
  Future<List<AiChatSessionEntity>> getChatSessions();

  /// 새 채팅 세션 생성
  Future<AiChatSessionEntity> createChatSession(String title, {String? petId});

  /// 채팅 세션 삭제
  Future<void> deleteChatSession(String sessionId);

  /// 추천 질문 가져오기
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions();
}