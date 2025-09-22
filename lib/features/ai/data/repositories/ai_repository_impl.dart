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
  }) : _openAIService = openAIService,
       _aiMockDataService = aiMockDataService;
  @override
  Future<List<AiMessageEntity>> getChatHistory() async {
    // 실제 API 호출로 채팅 히스토리 가져오기
    // 현재는 로컬 저장소나 서버에서 히스토리를 가져와야 하지만,
    // 실제 구현에서는 SharedPreferences나 서버 API를 사용
    await _aiMockDataService.simulateApiDelay();
    return _aiMockDataService.getChatHistoryEntities();
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

      return Result.success('AI応答を生成しました', aiMessage);
    } catch (e) {
      // AI 로거를 사용한 에러 로그
      AiLogger.logApiError(e);

      return Result.failure(
        'AI応答の生成に失敗しました: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<Result<AiMessageEntity>> sendMessageWithPetContext(
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

      final aiMessage = AiMessageEntity(
        id: _generateId(),
        content: response,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );

      return Result.success('ペット情報を含むAI応答を生成しました', aiMessage);
    } catch (e) {
      // AI 로거를 사용한 에러 로그
      AiLogger.logApiError(e);

      return Result.failure(
        'AI応答の生成に失敗しました: ${e.toString()}',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<void> clearChatHistory() async {
    // 실제 API 호출로 채팅 히스토리 삭제
    // await _httpClient.delete('/api/ai/chat/history');

    await MockHelper.simulateApiCall();
    // 실제 구현에서는 서버 API나 로컬 저장소에서 삭제
  }

  @override
  Future<List<AiChatSessionEntity>> getChatSessions() async {
    // 실제 API 호출로 채팅 세션 목록 가져오기
    // final response = await _httpClient.get('/api/ai/chat/sessions');
    // return response.data.map((json) => AiChatSessionEntity.fromJson(json)).toList();

    await MockHelper.simulateApiCall();
    return _aiMockDataService.getChatSessionEntities();
  }

  @override
  Future<AiChatSessionEntity> createChatSession(
    String title, {
    String? petId,
  }) async {
    // 실제 API 호출로 채팅 세션 생성
    // final response = await _httpClient.post('/api/ai/chat/sessions', {
    //   'title': title,
    //   'petId': petId,
    // });
    // return AiChatSessionEntity.fromJson(response.data);

    await MockHelper.simulateApiCall();
    final mockData = await _aiMockDataService.createChatSession(
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
    // 실제 API 호출로 채팅 세션 삭제
    // await _httpClient.delete('/api/ai/chat/sessions/$sessionId');

    await MockHelper.simulateApiCall();
    // 실제 구현에서는 서버 API나 로컬 저장소에서 삭제
  }

  @override
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    // 실제 API 호출로 추천 질문 가져오기
    await MockHelper.simulateApiCall();
    return _aiMockDataService.getSuggestedQuestionEntities();
  }

  /// 펫 정보 기반 맞춤형 추천 질문 가져오기
  @override
  Future<List<AiSuggestedQuestionEntity>> getPersonalizedSuggestedQuestions({
    String? category,
    PetProfileEntity? pet,
  }) async {
    await MockHelper.simulateApiCall();

    return AiConfigMockData.getPersonalizedQuestions(
      category: category,
      petType: pet?.type,
      petAge: pet?.age,
    );
  }

  @override
  Future<AiFavoriteEntity> addFavoriteMessage(
    AiMessageEntity message,
    String category, {
    String? petId,
    String? petName,
    String? userNote,
  }) async {
    // 실제 API 호출로 즐겨찾기 메시지 추가
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
    // 실제 API 호출로 즐겨찾기 메시지 삭제
    await _aiMockDataService.simulateApiDelay();
    // 실제 구현에서는 서버 API나 로컬 저장소에서 삭제
  }

  @override
  Future<List<AiFavoriteEntity>> getFavoriteMessages({
    String? petId,
    String? category,
  }) async {
    // 실제 API 호출로 즐겨찾기 메시지 목록 가져오기
    await MockHelper.simulateApiCall();
    // 실제 구현에서는 서버 API나 로컬 저장소에서 데이터 가져오기
    return [];
  }

  @override
  List<AiFavoriteQaEntity> getFavoriteQAs() {
    // 실제 API 호출로 즐겨찾기 QA 가져오기
    // 동기적으로 반환해야 하므로 Mock 데이터를 직접 반환
    // 실제 구현에서는 로컬 저장소나 캐시에서 동기적으로 가져오기
    return [];
  }

  @override
  Future<AiChatSummaryEntity> createChatSummary(
    List<AiMessageEntity> messages,
    String category, {
    String? petId,
    String? petName,
  }) async {
    // 실제 API 호출로 채팅 요약 생성
    await MockHelper.simulateApiCall();

    // 실제 구현에서는 OpenAI API를 사용하여 요약 생성
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
    // 실제 API 호출로 채팅 요약 목록 가져오기
    await MockHelper.simulateApiCall();
    // 실제 구현에서는 서버 API나 로컬 저장소에서 데이터 가져오기
    return [];
  }

  @override
  Future<void> deleteChatSummary(String summaryId) async {
    // 실제 API 호출로 채팅 요약 삭제
    await MockHelper.simulateApiCall();
    // 실제 구현에서는 서버 API나 로컬 저장소에서 삭제
  }

  @override
  Future<void> saveChatHistory(AiChatHistoryEntity chatHistory) async {
    // 실제 API 호출로 채팅 히스토리 저장
    await MockHelper.simulateApiCall();
    // 실제 구현에서는 서버 API나 로컬 저장소에 저장
    debugPrint('채팅 히스토리 저장: ${chatHistory.title}');
  }

  @override
  Future<AiChatSummary> generateChatSummary({
    required List<String> userMessages,
    required String petName,
    required String category,
  }) async {
    // 실제 ChatGPT API 호출로 요약 생성
    await MockHelper.simulateApiCall();

    // Mock 요약 생성
    final combinedMessages = userMessages.join(' ');
    final title = combinedMessages.length > 20
        ? '${combinedMessages.substring(0, 20)}...'
        : combinedMessages;

    return AiChatSummary(
      title: title.isNotEmpty ? title : '$petNameの$category相談',
      content: '$petNameの$categoryについて相談した内容',
    );
  }

  @override
  Future<List<AiChatHistoryEntity>> getChatHistories({
    int limit = 30,
    bool onlyManualSaved = false,
  }) async {
    // 실제 API 호출로 채팅 히스토리 목록 가져오기
    await MockHelper.simulateApiCall();
    // 실제 구현에서는 서버 API나 로컬 저장소에서 데이터 가져오기
    // 최대 30개, 최근 순으로 정렬하여 반환
    return [];
  }

  @override
  Future<void> deleteChatHistory(String historyId) async {
    // 실제 API 호출로 채팅 히스토리 삭제
    await MockHelper.simulateApiCall();
    // 실제 구현에서는 서버 API나 로컬 저장소에서 삭제
  }

  /// 고유 ID 생성
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'msg_${timestamp}_$random';
  }
}
