import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';

class AiRepositoryImpl implements AiRepository {
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
    // TODO: Replace with actual API call
    // final response = await _httpClient.post('/api/ai/chat/send', {
    //   'message': message,
    // });
    // return AiMessageEntity.fromJson(response.data);
    
    await AiMockDataService.simulateApiDelay(seconds: 2);
    final mockData = AiMockDataService.generateAiResponseMockData(message);
    
    return AiMessageEntity(
      id: mockData['id'] as String,
      content: mockData['content'] as String,
      type: _parseMessageType(mockData['type'] as String),
      timestamp: DateTime.parse(mockData['timestamp'] as String),
    );
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
}
