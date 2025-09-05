import 'package:flutter/material.dart';

import '../../../../shared/mock_data/features/ai/ai_mock_data.dart';
import '../../../../shared/services/mock_data_service.dart';
import '../../domain/domain.dart';

/// AI Mock 데이터 서비스 구현체
///
/// MockDataService 인터페이스를 구현하여 AI 관련 Mock 데이터를 중앙에서 관리합니다.
class AiMockDataServiceImpl implements MockDataService {
  @override
  Future<void> simulateApiDelay({int seconds = 1}) async {
    await AiMockDataService.simulateApiDelay(seconds: seconds);
  }

  @override
  Future<List<AiMessageEntity>> getChatHistory() async {
    // Mock 데이터에서 채팅 히스토리 반환
    // TODO: AiMessageEntity.fromJson 구현 후 사용
    // final mockData = AiMockDataService.getChatHistoryMockData();
    // return mockData.map((json) => AiMessageEntity.fromJson(json)).toList();
    return []; // 임시로 빈 리스트 반환
  }

  @override
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    // Mock 데이터에서 추천 질문 반환
    final mockData = AiMockDataService.getSuggestedQuestions();
    return mockData
        .map(
          (json) => AiSuggestedQuestionEntity(
            id: json['id'] as String,
            question: json['question'] as String,
            category: json['category'] as String,
            icon: _getIconForCategory(json['category'] as String),
            description: json['description'] as String?,
          ),
        )
        .toList();
  }

  @override
  Future<List<AiFavoriteQaEntity>> getFavoriteQAs() async {
    // Mock 데이터에서 즐겨찾기 QA 반환
    final mockData = AiMockDataService.getFavoriteQAsMockData();
    return mockData;
  }

  @override
  Future<List<AiChatSessionEntity>> getChatSessions() async {
    // Mock 데이터에서 채팅 세션 반환
    return AiMockDataService.getChatSessions();
  }

  @override
  Future<Map<String, dynamic>> generateAiResponse(String userMessage) async {
    // Mock 데이터에서 AI 응답 생성
    return AiMockDataService.generateAiResponseMockData(userMessage);
  }

  @override
  Future<Map<String, dynamic>> createChatSession(
    String title, {
    String? petId,
  }) async {
    // Mock 데이터에서 채팅 세션 생성
    return AiMockDataService.createChatSessionMockData(title, petId: petId);
  }

  /// 카테고리별 아이콘 매핑
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'health':
        return Icons.medical_services;
      case 'food':
        return Icons.restaurant;
      case 'behavior':
        return Icons.psychology;
      case 'grooming':
        return Icons.content_cut;
      case 'exercise':
        return Icons.directions_walk;
      default:
        return Icons.help_outline;
    }
  }
}
