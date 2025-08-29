import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../../pet_registor/domain/entities/pet_profile_entity.dart';
import '../../domain/domain.dart';
import '../services/openai_service.dart';

class AiRepositoryImpl implements AiRepository {
  final OpenAIService _openAIService = OpenAIService();
  @override
  Future<List<AiMessageEntity>> getChatHistory() async {
    // TODO: Replace with actual API call
    // final response = await _httpClient.get('/api/ai/chat/history');
    // return response.data.map((json) => AiMessageEntity.fromJson(json)).toList();
    
    await AiMockDataService.simulateApiDelay();
    final mockData = AiMockDataService.getChatHistoryMockData();
    
    return mockData.map((json) => AiMessageEntity(
      id: json['id'] as String,
      content: json['content'] as String,
      type: _parseMessageType(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    )).toList();
  }

  @override
  Future<AiMessageEntity> sendMessage(String message) async {
    try {
      // 디버그 로그 추가
      print('🔄 API 호출 시작: $message');
      
      // 실제 OpenAI API 호출
      final response = await _openAIService.generateResponse(message);
      
      print('✅ API 응답 성공: ${response.substring(0, 50)}...');
      
      return AiMessageEntity(
        id: _generateId(),
        content: response,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // 오류 로그 추가
      print('❌ API 호출 실패: $e');
      
      // API 호출 실패 시 에러 메시지 반환
      return AiMessageEntity(
        id: _generateId(),
        content: '申し訳ございません。現在サービスに一時的な問題が発生しています。しばらくしてから再度お試しください。\n\nエラー: ${e.toString()}',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
    }
  }
  
  @override
  Future<AiMessageEntity> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
  }) async {
    try {
      // 디버그 로그 추가
      print('🔄 API 호출 시작 (펫 컨텍스트): $message');
      print('   펫 정보: ${petContext?.name} (${petContext?.typeName})');
      
      // 펫 정보와 함께 OpenAI API 호출
      final response = await _openAIService.generateResponse(message, petContext: petContext);
      
      print('✅ API 응답 성공: ${response.substring(0, 50)}...');
      
      return AiMessageEntity(
        id: _generateId(),
        content: response,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // 오류 로그 추가
      print('❌ API 호출 실패: $e');
      
      // API 호출 실패 시 에러 메시지 반환
      return AiMessageEntity(
        id: _generateId(),
        content: '申し訳ございません。現在サービスに一時的な問題が発生しています。しばらくしてから再度お試しください。\n\nエラー: ${e.toString()}',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<void> clearChatHistory() async {
    // TODO: Replace with actual API call
    // await _httpClient.delete('/api/ai/chat/history');
    
    await AiMockDataService.simulateApiDelay();
    // Mock implementation: no actual storage to clear
  }

  @override
  Future<List<AiChatSessionEntity>> getChatSessions() async {
    // TODO: Replace with actual API call
    // final response = await _httpClient.get('/api/ai/chat/sessions');
    // return response.data.map((json) => AiChatSessionEntity.fromJson(json)).toList();
    
    await AiMockDataService.simulateApiDelay();
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
    
    await AiMockDataService.simulateApiDelay();
    final mockData = AiMockDataService.createChatSessionMockData(title, petId: petId);
    
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
    
    await AiMockDataService.simulateApiDelay();
    // Mock implementation: no actual storage to delete from
  }

  @override
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    // TODO: Replace with actual API call
    // final response = await _httpClient.get('/api/ai/suggested-questions');
    // return response.data.map((json) => AiSuggestedQuestionEntity.fromJson(json)).toList();
    
    await AiMockDataService.simulateApiDelay();
    
    return AiMockDataService.suggestedQuestions.map((data) => 
      AiSuggestedQuestionEntity(
        id: data['id'] as String,
        question: data['question'] as String,
        category: data['category'] as String,
        icon: data['icon'] as IconData,
        description: data['description'] as String?,
      ),
    ).toList();
  }

  /// MessageType 문자열을 enum으로 파싱
  MessageType _parseMessageType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'user':
        return MessageType.user;
      case 'assistant':
        return MessageType.assistant;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.assistant;
    }
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
    await AiMockDataService.simulateApiDelay();
    
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
    await AiMockDataService.simulateApiDelay();
    // Mock implementation: return empty list
    return [];
  }

  @override
  List<AiFavoriteQaEntity> getFavoriteQAs() {
    // Mock implementation: return mock favorite QAs
    return AiMockDataService.getFavoriteQAsMockData();
  }

  @override
  Future<AiChatSummaryEntity> createChatSummary(
    List<AiMessageEntity> messages,
    String category, {
    String? petId,
    String? petName,
  }) async {
    // TODO: Replace with actual API call
    await AiMockDataService.simulateApiDelay();
    
    // Mock implementation: create a basic summary
    final summary = messages.length > 1 
        ? '${messages[1].content.substring(0, 50)}...'
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
    await AiMockDataService.simulateApiDelay();
    // Mock implementation: return empty list
    return [];
  }

  @override
  Future<void> deleteChatSummary(String summaryId) async {
    // TODO: Replace with actual API call
    await AiMockDataService.simulateApiDelay();
    // Mock implementation: no actual storage to delete from
  }

  /// 고유 ID 생성
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'msg_${timestamp}_$random';
  }
}
