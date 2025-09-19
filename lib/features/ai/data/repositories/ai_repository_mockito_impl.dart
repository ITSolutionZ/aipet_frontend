import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../../pet_registor/pet_registor.dart';
import '../../domain/domain.dart';
import '../services/openai_service.dart';

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

      return Result.success('AI 응답이 생성되었습니다', aiMessage);
    } catch (error) {
      AiLogger.logApiError(error.toString());
      return Result.failure('AI 응답 생성에 실패했습니다: ${error.toString()}');
    }
  }

  @override
  Future<Result<AiMessageEntity>> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
  }) async {
    try {
      // AI 로거를 사용한 API 호출 시작 로그 (펫 컨텍스트 포함)
      AiLogger.logApiStartWithPet(message, petContext);

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

      return Result.success('펫 컨텍스트와 함께 AI 응답이 생성되었습니다', aiMessage);
    } catch (error) {
      AiLogger.logApiError(error.toString());
      return Result.failure('AI 응답 생성에 실패했습니다: ${error.toString()}');
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
}
