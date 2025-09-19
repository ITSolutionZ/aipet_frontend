import '../../../../shared/shared.dart';
import '../../../pet_registor/pet_registor.dart';
import '../entities/entities.dart';

abstract class AiRepository {
  /// 채팅 기록 가져오기
  Future<List<AiMessageEntity>> getChatHistory();

  /// 메시지 전송하기
  Future<Result<AiMessageEntity>> sendMessage(String message);

  /// 펫 정보와 함께 메시지 전송하기
  Future<Result<AiMessageEntity>> sendMessageWithPetContext(
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

  /// 펫 정보 기반 맞춤형 추천 질문 가져오기
  Future<List<AiSuggestedQuestionEntity>> getPersonalizedSuggestedQuestions({
    String? category,
    PetProfileEntity? pet,
  });

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

  /// 채팅 히스토리 저장
  Future<void> saveChatHistory(AiChatHistoryEntity chatHistory);

  /// AI를 사용하여 채팅 요약 생성
  Future<AiChatSummary> generateChatSummary({
    required List<String> userMessages,
    required String petName,
    required String category,
  });

  /// 채팅 히스토리 목록 가져오기 (최대 30개, 최근 순)
  Future<List<AiChatHistoryEntity>> getChatHistories({
    int limit = 30,
    bool onlyManualSaved = false,
  });

  /// 채팅 히스토리 삭제
  Future<void> deleteChatHistory(String historyId);
}
