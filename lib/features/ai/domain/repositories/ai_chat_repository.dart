import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';

import '../entities/ai_chat_history_entity.dart';
import '../entities/ai_chat_session_entity.dart';
import '../entities/ai_message_entity.dart';

/// AI 채팅 관련 Repository
abstract class AiChatRepository {
  /// 채팅 기록 관련
  Future<List<AiMessageEntity>> getChatHistory({String? sessionId});
  Future<Result<List<AiMessageEntity>>> loadChatHistory({
    required String userId,
    String? petId,
    String? sessionId,
    int? limit,
    int? offset,
  });
  Future<void> saveChatHistory(AiChatHistoryEntity chatHistory);
  Future<void> clearChatHistory({String? sessionId});

  /// 메시지 전송
  Future<Result<AiMessageEntity>> sendMessage({
    required String message,
    required String sessionId,
    String? petId,
    String? categoryId,
    List<String>? attachedImages,
    Map<String, dynamic>? context,
  });

  Future<Result<AiMessageEntity>> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
    String? sessionId,
  });

  /// 채팅 세션 관리
  Future<List<AiChatSessionEntity>> getChatSessions({String? petId});
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
    String? petId,
  });
  Future<void> deleteChatHistoryById(String historyId);
}
