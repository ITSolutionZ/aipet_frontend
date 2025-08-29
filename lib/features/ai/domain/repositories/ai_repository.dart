import '../../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../entities/entities.dart';

abstract class AiRepository {
  /// 채팅 기록 가져오기
  Future<List<AiMessageEntity>> getChatHistory();

  /// 메시지 전송하기
  Future<AiMessageEntity> sendMessage(String message);
  
  /// 펫 정보와 함께 메시지 전송하기
  Future<AiMessageEntity> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
  });

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

  /// 즐겨찾기 메시지 추가
  Future<AiFavoriteEntity> addFavoriteMessage(
    AiMessageEntity message,
    String category, {
    String? petId,
    String? petName,
    String? userNote,
  });

  /// 즐겨찾기 메시지 제거
  Future<void> removeFavoriteMessage(String favoriteId);

  /// 즐겨찾기 목록 가져오기
  Future<List<AiFavoriteEntity>> getFavoriteMessages({
    String? petId,
    String? category,
  });

  /// 즐겨찾기 QA 목록 가져오기
  List<AiFavoriteQaEntity> getFavoriteQAs();

  /// 채팅 요약 생성
  Future<AiChatSummaryEntity> createChatSummary(
    List<AiMessageEntity> messages,
    String category, {
    String? petId,
    String? petName,
  });

  /// 채팅 요약 목록 가져오기
  Future<List<AiChatSummaryEntity>> getChatSummaries({
    String? petId,
    String? category,
  });

  /// 채팅 요약 삭제
  Future<void> deleteChatSummary(String summaryId);
}
