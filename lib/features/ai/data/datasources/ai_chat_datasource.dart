import '../../../../shared/domain/entities/entities.dart';
import '../../domain/entities/ai_chat_history_entity.dart';
import '../../domain/entities/ai_chat_session_entity.dart';
import '../../domain/entities/ai_message_entity.dart';

/// AI 채팅 데이터소스 인터페이스
abstract class AiChatDatasource {
  /// 채팅 기록 관련
  Future<List<AiMessageEntity>> getChatHistory({String? sessionId});

  Future<List<AiMessageEntity>> loadChatHistory({
    required String userId,
    String? petId,
    String? sessionId,
    int? limit,
    int? offset,
  });

  Future<void> saveChatHistory(AiChatHistoryEntity chatHistory);
  Future<void> clearChatHistory({String? sessionId});

  /// 메시지 전송
  Future<AiMessageEntity> sendMessage({
    required String message,
    required String sessionId,
    String? petId,
    String? categoryId,
    List<String>? attachedImages,
    Map<String, dynamic>? context,
  });

  Future<AiMessageEntity> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
    String? sessionId,
  });

  /// 채팅 세션 관리
  Future<List<AiChatSessionEntity>> getChatSessions();
  Future<AiChatSessionEntity> createChatSession(
    String title, {
    String? petId,
    String? categoryId,
  });
  Future<void> deleteChatSession(String sessionId);
  Future<AiChatSessionEntity> updateChatSession(AiChatSessionEntity session);

  /// 채팅 히스토리 관리
  Future<List<AiChatHistoryEntity>> getChatHistories({
    int limit = 30,
    bool onlyManualSaved = false,
  });
  Future<void> deleteChatHistory(String historyId);
}
