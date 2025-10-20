import 'package:aipet_frontend/shared/shared.dart';

import '../entities/ai_chat_history_entity.dart';
import '../entities/ai_chat_session_entity.dart';
import '../entities/ai_chat_summary.dart';
import '../entities/ai_chat_summary_entity.dart';
import '../entities/ai_message_entity.dart';

/// AI 채팅 관련 Repository
///
/// ⚠️ 현재 미사용 (Future Use)
/// 추후 채팅 기능을 AiRepository에서 분리할 때 사용 예정
/// 현재는 AiRepository를 통해 모든 AI 기능 제공
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

  /// 채팅 요약 관련
  Future<AiChatSummaryEntity> createChatSummary(
    List<AiMessageEntity> messages,
    String category, {
    String? petId,
    String? petName,
  });

  Future<List<AiChatSummaryEntity>> getChatSummaries({
    String? petId,
    String? category,
  });

  Future<void> deleteChatSummary(String summaryId);

  Future<AiChatSummary> generateChatSummary({
    required List<String> userMessages,
    required String petName,
    required String category,
  });
}
