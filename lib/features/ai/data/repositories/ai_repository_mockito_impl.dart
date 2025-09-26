import 'package:aipet_frontend/features/ai/data/services/openai_service.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_analysis_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_history_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_session_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_summary.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_chat_summary_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_favorite_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_favorite_qa_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/features/ai/domain/entities/ai_suggested_question_entity.dart';
import 'package:aipet_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:aipet_frontend/shared/shared.dart' hide Result;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI Repository Mockito 구현체
///
/// 실제 OpenAI API는 사용하되, 나머지 로직은 Mockito를 통해 테스트 가능하도록 구현
class AiRepositoryMockitoImpl implements AiRepository {
  final OpenAIService _openAIService; // 실제 OpenAI API 사용
  final Ref ref;

  AiRepositoryMockitoImpl({
    required OpenAIService openAIService,
    required this.ref,
  }) : _openAIService = openAIService;

  @override
  Future<List<AiMessageEntity>> getChatHistory() async {
    // Mock 데이터 반환 (실제로는 서버나 로컬 저장소에서 가져와야 함)
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockChatHistory();
  }

  @override
  Future<Result<AiMessageEntity>> sendMessage(String message) async {
    try {
      // AI 로거를 사용한 API 호출 시작 로그
      AiLogger.logApiStart(message);

      // 실제 OpenAI API 호출
      final response = await _openAIService.generateResponse(message);

      // AI 로거를 사용한 응답 성공 로그
      AiLogger.logApiSuccess(response);

      final aiMessage = AiMessageEntity(
        id: _generateId(),
        content: response,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );

      return ResultFactory.success(aiMessage, 'AI 응답이 생성되었습니다').toFuture();
    } catch (error) {
      AiLogger.logApiError(error.toString());
      return ResultFactory.failure<AiMessageEntity>(
        'AI 응답 생성에 실패했습니다: ${error.toString()}',
      ).toFuture();
    }
  }

  @override
  Future<Result<AiMessageEntity>> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
  }) async {
    try {
      // AI 로거를 사용한 API 호출 시작 로그 (펫 컨텍스트 포함)
      AiLogger.logApiStart(message, context: '펫 컨텍스트');
      AiLogger.logPetContext(petContext?.name, petContext?.type);

      // 실제 OpenAI API 호출 (펫 컨텍스트 포함)
      final response = await _openAIService.generateResponse(
        message,
        petContext: petContext,
      );

      // AI 로거를 사용한 응답 성공 로그
      AiLogger.logApiSuccess(response);

      final aiMessage = AiMessageEntity(
        id: _generateId(),
        content: response,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );

      return ResultFactory.success(
        aiMessage,
        '펫 컨텍스트와 함께 AI 응답이 생성되었습니다',
      ).toFuture();
    } catch (error) {
      AiLogger.logApiError(error.toString());
      return ResultFactory.failure<AiMessageEntity>(
        'AI 응답 생성에 실패했습니다: ${error.toString()}',
      ).toFuture();
    }
  }

  @override
  Future<void> clearChatHistory() async {
    // Mock 구현 - 실제로는 로컬 저장소나 서버에서 삭제
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<AiChatSessionEntity>> getChatSessions() async {
    // Mock 데이터 반환
    await Future.delayed(const Duration(milliseconds: 200));
    return _getMockChatSessions();
  }

  @override
  Future<AiChatSessionEntity> createChatSession(
    String title, {
    String? petId,
  }) async {
    // Mock 구현
    await Future.delayed(const Duration(milliseconds: 150));
    return AiChatSessionEntity(
      id: _generateId(),
      title: title,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      petId: petId,
    );
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    // Mock 구현
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    // Mock 데이터 반환
    await Future.delayed(const Duration(milliseconds: 200));
    return _getMockSuggestedQuestions();
  }

  @override
  Future<List<AiSuggestedQuestionEntity>> getPersonalizedSuggestedQuestions({
    String? category,
    PetProfileEntity? pet,
  }) async {
    // Mock 데이터 반환 (펫 정보 기반)
    await Future.delayed(const Duration(milliseconds: 250));
    return _getMockPersonalizedQuestions(category, pet);
  }

  @override
  Future<AiFavoriteEntity> addFavoriteMessage(
    AiMessageEntity message,
    String category, {
    String? petId,
    String? petName,
    String? userNote,
  }) async {
    // Mock 구현
    await Future.delayed(const Duration(milliseconds: 150));
    return AiFavoriteEntity(
      id: _generateId(),
      message: message,
      category: category,
      petId: petId,
      petName: petName,
      userNote: userNote,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeFavoriteMessage(String favoriteId) async {
    // Mock 구현
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<List<AiFavoriteEntity>> getFavoriteMessages({
    String? petId,
    String? category,
  }) async {
    // Mock 데이터 반환
    await Future.delayed(const Duration(milliseconds: 200));
    return _getMockFavoriteMessages(petId, category);
  }

  @override
  List<AiFavoriteQaEntity> getFavoriteQAs() {
    // Mock 데이터 반환
    return _getMockFavoriteQAs();
  }

  @override
  Future<AiChatSummaryEntity> createChatSummary(
    List<AiMessageEntity> messages,
    String category, {
    String? petId,
    String? petName,
  }) async {
    // Mock 구현
    await Future.delayed(const Duration(milliseconds: 300));
    return AiChatSummaryEntity(
      id: _generateId(),
      title: '${petName ?? 'ペット'}の$category相談',
      summary: '대화 요약: ${messages.length}개의 메시지',
      category: category,
      petId: petId,
      petName: petName,
      messages: messages,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messageCount: messages.length,
      hasFavorites: false,
    );
  }

  @override
  Future<List<AiChatSummaryEntity>> getChatSummaries({
    String? petId,
    String? category,
  }) async {
    // Mock 데이터 반환
    await Future.delayed(const Duration(milliseconds: 200));
    return _getMockChatSummaries(petId, category);
  }

  @override
  Future<void> deleteChatSummary(String summaryId) async {
    // Mock 구현
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> saveChatHistory(AiChatHistoryEntity chatHistory) async {
    // Mock 구현
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<AiChatSummary> generateChatSummary({
    required List<String>? userMessages,
    required String? petName,
    required String? category,
  }) async {
    // Mock 구현
    await Future.delayed(const Duration(milliseconds: 250));
    return AiChatSummary(
      title: '${petName ?? 'Unknown Pet'}の${category ?? 'general'}相談',
      content: 'Generated summary for ${userMessages?.length ?? 0} messages',
    );
  }

  @override
  Future<List<AiChatHistoryEntity>> getChatHistories({
    int? limit = 30,
    bool? onlyManualSaved = false,
  }) async {
    // Mock 데이터 반환
    await Future.delayed(const Duration(milliseconds: 200));
    return _getMockChatHistories(limit, onlyManualSaved);
  }

  @override
  Future<void> deleteChatHistory(String historyId) async {
    // Mock 구현
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Helper methods for mock data
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  List<AiMessageEntity> _getMockChatHistory() {
    return [
      AiMessageEntity(
        id: 'msg-1',
        content: 'こんにちは！ペットについて何かお手伝いできることはありますか？',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      AiMessageEntity(
        id: 'msg-2',
        content: 'ペットの健康について相談したいです',
        type: MessageType.user,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  List<AiChatSessionEntity> _getMockChatSessions() {
    return [
      AiChatSessionEntity(
        id: 'session-1',
        title: 'ペットの健康相談',
        messages: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        petId: 'pet-1',
      ),
    ];
  }

  List<AiSuggestedQuestionEntity> _getMockSuggestedQuestions() {
    return [
      const AiSuggestedQuestionEntity(
        id: 'q-1',
        question: 'ペットの健康管理について教えてください',
        category: 'health',
        icon: Icons.medical_services,
      ),
      const AiSuggestedQuestionEntity(
        id: 'q-2',
        question: 'おすすめのペットフードは何ですか？',
        category: 'feeding',
        icon: Icons.restaurant,
      ),
    ];
  }

  List<AiSuggestedQuestionEntity> _getMockPersonalizedQuestions(
    String? category,
    PetProfileEntity? pet,
  ) {
    return [
      AiSuggestedQuestionEntity(
        id: 'pq-1',
        question: '${pet?.name ?? 'ペット'}の年齢に適した運動は何ですか？',
        category: category ?? 'exercise',
        icon: Icons.directions_walk,
      ),
    ];
  }

  List<AiFavoriteEntity> _getMockFavoriteMessages(
    String? petId,
    String? category,
  ) {
    return [
      AiFavoriteEntity(
        id: 'fav-1',
        message: AiMessageEntity(
          id: 'msg-1',
          content: '便利な情報',
          type: MessageType.assistant,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
        category: category ?? 'general',
        petId: petId,
        petName: 'Mock Pet',
        userNote: '便利な情報',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<AiFavoriteQaEntity> _getMockFavoriteQAs() {
    return [
      AiFavoriteQaEntity(
        id: 'qa-1',
        question: 'ペットの健康管理について',
        answer: '定期的な健康診断が重要です',
        categoryId: 'health',
        categoryName: '健康',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        originalTimestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<AiChatSummaryEntity> _getMockChatSummaries(
    String? petId,
    String? category,
  ) {
    return [
      AiChatSummaryEntity(
        id: 'summary-1',
        title: 'ペットの健康管理に関する相談',
        summary: 'ペットの健康管理に関する相談',
        category: category ?? 'general',
        petId: petId,
        petName: 'Mock Pet',
        messages: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        messageCount: 0,
        hasFavorites: false,
      ),
    ];
  }

  List<AiChatHistoryEntity> _getMockChatHistories(
    int? limit,
    bool? onlyManualSaved,
  ) {
    return [
      AiChatHistoryEntity(
        id: 'history-1',
        title: 'ペットの健康相談',
        summary: 'ペットの健康管理に関する相談',
        messages: _getMockChatHistory(),
        category: null, // AiCategoryEntity는 null로 설정
        pet: null, // PetProfileEntity는 null로 설정
        isManualSaved: onlyManualSaved ?? false,
        messageCount: _getMockChatHistory().length,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  /// 채팅 히스토리 로드 (UseCase용)
  @override
  Future<Result<List<AiMessageEntity>>> loadChatHistory({
    required String userId,
    String? petId,
    int? limit,
    int? offset,
  }) async {
    final messages = _getMockChatHistory();
    return ResultFactory.success(messages);
  }

  /// 메시지 분석 (UseCase용)
  @override
  Future<Result<AiAnalysisEntity>> analyzeMessage({
    required String message,
    String? petId,
    Map<String, dynamic>? context,
  }) async {
    final analysis = AiAnalysisEntity.fromMessage(
      message: message,
      analysis: 'Mock 메시지 분석 결과',
      topics: ['Mock'],
    );
    return ResultFactory.success(analysis);
  }

  /// 파라미터와 함께 메시지 전송
  @override
  Future<Result<AiMessageEntity>> sendMessageWithParams({
    required String message,
    required String petId,
    String? categoryId,
    List<String>? attachedImages,
  }) async {
    return await sendMessage(message);
  }

  /// 즐겨찾기 토글
  @override
  Future<Result<bool>> toggleFavoriteMessage(String messageId) async {
    return ResultFactory.success(true);
  }

  /// 파라미터와 함께 제안 질문 가져오기
  @override
  Future<Result<List<AiSuggestedQuestionEntity>>> getSuggestedQuestionsWithParams({
    String? petId,
    String? categoryId,
  }) async {
    final suggestions = await getSuggestedQuestions();
    return ResultFactory.success(suggestions);
  }
}
