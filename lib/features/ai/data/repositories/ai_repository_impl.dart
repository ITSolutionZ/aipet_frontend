import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../../pet_registor/pet_registor.dart';
import '../../domain/domain.dart';
import '../services/ai_mock_data_service_impl.dart';
import '../services/openai_service.dart';

class AiRepositoryImpl implements AiRepository {
  final OpenAIService _openAIService;
  final AiMockDataServiceImpl _aiMockDataService;
  final Ref ref;

  AiRepositoryImpl({
    required OpenAIService openAIService,
    required AiMockDataServiceImpl aiMockDataService,
    required this.ref,
  })  : _openAIService = openAIService,
        _aiMockDataService = aiMockDataService;
  @override
  Future<List<AiMessageEntity>> getChatHistory() async {
    // TODO: Replace with actual API call
    // final response = await _httpClient.get('/api/ai/chat/history');
    // return response.data.map((json) => AiMessageEntity.fromJson(json)).toList();

    await _aiMockDataService.simulateApiDelay();
    return _aiMockDataService.getChatHistory();
  }

  @override
  Future<AiMessageEntity> sendMessage(String message) async {
    try {
      // AI 로거를 사용한 API 호출 시작 로그
      AiLogger.logApiStart(message);

      // 실제 OpenAI API 호출
      final response = await _openAIService.generateResponse(message);

      // AI 로거를 사용한 응답 성공 로그
      AiLogger.logApiSuccess(response);

      return AiMessageEntity(
        id: _generateId(),
        content: response,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // AI 로거를 사용한 에러 로그
      AiLogger.logApiError(e);

      // 공통 에러 메시지 생성
      return _createErrorMessage(e);
    }
  }

  @override
  Future<AiMessageEntity> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
  }) async {
    try {
      // AI 로거를 사용한 API 호출 시작 로그
      AiLogger.logApiStart(message, context: '펫 컨텍스트');
      AiLogger.logPetContext(petContext?.name, petContext?.typeName);

      // 펫 정보와 함께 OpenAI API 호출
      final response = await _openAIService.generateResponse(
        message,
        petContext: petContext,
      );

      // AI 로거를 사용한 응답 성공 로그
      AiLogger.logApiSuccess(response);

      return AiMessageEntity(
        id: _generateId(),
        content: response,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // AI 로거를 사용한 에러 로그
      AiLogger.logApiError(e);

      // 공통 에러 메시지 생성
      return _createErrorMessage(e);
    }
  }

  @override
  Future<void> clearChatHistory() async {
    // TODO: Replace with actual API call
    // await _httpClient.delete('/api/ai/chat/history');

    await MockHelper.simulateApiCall();
    // Mock implementation: no actual storage to clear
  }

  @override
  Future<List<AiChatSessionEntity>> getChatSessions() async {
    // TODO: Replace with actual API call
    // final response = await _httpClient.get('/api/ai/chat/sessions');
    // return response.data.map((json) => AiChatSessionEntity.fromJson(json)).toList();

    await MockHelper.simulateApiCall();
    // Mock implementation: return empty list
    return [];
  }

  @override
  Future<AiChatSessionEntity> createChatSession(
    String title, {
    String? petId,
  }) async {
    // TODO: Replace with actual API call
    // final response = await _httpClient.post('/api/ai/chat/sessions', {
    //   'title': title,
    //   'petId': petId,
    // });
    // return AiChatSessionEntity.fromJson(response.data);

    await MockHelper.simulateApiCall();
    final mockData = AiMockDataService.createChatSessionMockData(
      title,
      petId: petId,
    );

    return AiChatSessionEntity(
      id: mockData['id'] as String,
      title: mockData['title'] as String,
      messages: [],
      createdAt: DateTime.parse(mockData['createdAt'] as String),
      updatedAt: DateTime.parse(mockData['updatedAt'] as String),
      petId: mockData['petId'] as String?,
      petName: mockData['petName'] as String?,
    );
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    // TODO: Replace with actual API call
    // await _httpClient.delete('/api/ai/chat/sessions/$sessionId');

    await MockHelper.simulateApiCall();
    // Mock implementation: no actual storage to delete from
  }

  @override
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    // TODO: Replace with actual API call
    // final response = await _httpClient.get('/api/ai/suggested-questions');
    // return response.data.map((json) => AiSuggestedQuestionEntity.fromJson(json)).toList();

    await MockHelper.simulateApiCall();

    return AiMockDataService.suggestedQuestions
        .map(
          (data) => AiSuggestedQuestionEntity(
            id: data['id'] as String,
            question: data['question'] as String,
            category: data['category'] as String,
            icon: data['icon'] as IconData,
            description: data['description'] as String?,
          ),
        )
        .toList();
  }


  @override
  Future<AiFavoriteEntity> addFavoriteMessage(
    AiMessageEntity message,
    String category, {
    String? petId,
    String? petName,
    String? userNote,
  }) async {
    // TODO: Replace with actual API call
    await MockHelper.simulateApiCall();

    return AiFavoriteEntity(
      id: _generateId(),
      message: message,
      petId: petId,
      petName: petName,
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userNote: userNote,
    );
  }

  @override
  Future<void> removeFavoriteMessage(String favoriteId) async {
    // TODO: Replace with actual API call
    await AiMockDataService.simulateApiDelay();
    // Mock implementation: no actual storage to delete from
  }

  @override
  Future<List<AiFavoriteEntity>> getFavoriteMessages({
    String? petId,
    String? category,
  }) async {
    // TODO: Replace with actual API call
    await MockHelper.simulateApiCall();
    // Mock implementation: return empty list
    return [];
  }

  @override
  List<AiFavoriteQaEntity> getFavoriteQAs() {
    // Riverpod provider를 사용하여 Mock 데이터 반환
    return ref.read(aiFavoriteMockDataProvider);
  }

  @override
  Future<AiChatSummaryEntity> createChatSummary(
    List<AiMessageEntity> messages,
    String category, {
    String? petId,
    String? petName,
  }) async {
    // TODO: Replace with actual API call
    await MockHelper.simulateApiCall();

    // Mock implementation: create a basic summary
    final summary = messages.length > 1
        ? '${messages[1].content.length > 50 ? messages[1].content.substring(0, 50) : messages[1].content}...'
        : '相談内容';

    return AiChatSummaryEntity(
      id: _generateId(),
      title: '$categoryの相談',
      summary: summary,
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
    // TODO: Replace with actual API call
    await MockHelper.simulateApiCall();
    // Mock implementation: return empty list
    return [];
  }

  @override
  Future<void> deleteChatSummary(String summaryId) async {
    // TODO: Replace with actual API call
    await MockHelper.simulateApiCall();
    // Mock implementation: no actual storage to delete from
  }

  /// 공통 에러 메시지 생성
  AiMessageEntity _createErrorMessage(dynamic error) {
    return AiMessageEntity(
      id: _generateId(),
      content: '${AiConstants.apiErrorMessage}${error.toString()}',
      type: MessageType.assistant,
      timestamp: DateTime.now(),
    );
  }

  /// 고유 ID 생성
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'msg_${timestamp}_$random';
  }
}
