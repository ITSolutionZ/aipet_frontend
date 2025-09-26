import 'package:flutter/material.dart';

import '../../../../shared/core/services/mock_data_service.dart';
import '../../../../shared/testing/mock_data/features/ai/ai_chat_messages_mock_data.dart';
import '../../../../shared/testing/mock_data/features/ai/ai_mock_data.dart';
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
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final entities = AiChatMessagesMockData.getChatHistory();
    return entities
        .map(
          (entity) => {
            'id': entity.id,
            'content': entity.content,
            'type': entity.type.name,
            'timestamp': entity.timestamp.toIso8601String(),
            'isTyping': entity.isTyping,
            'petId': entity.petId,
            'petName': entity.petName,
            'metadata': entity.metadata,
          },
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSuggestedQuestions() async {
    // Mock 데이터에서 추천 질문 반환
    final mockData = AiMockDataService.getSuggestedQuestions();
    return mockData;
  }

  @override
  Future<List<Map<String, dynamic>>> getFavoriteQAs() async {
    // Mock 데이터에서 즐겨찾기 QA 반환
    final entities = await getFavoriteQAEntities();
    return entities
        .map(
          (entity) => {
            'id': entity.id,
            'question': entity.question,
            'answer': entity.answer,
            'categoryId': entity.categoryId,
            'categoryName': entity.categoryName,
            'createdAt': entity.createdAt.toIso8601String(),
            'originalTimestamp': entity.originalTimestamp.toIso8601String(),
            'pet': entity.pet != null
                ? {'id': entity.pet!.id, 'name': entity.pet!.name}
                : null,
          },
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getChatSessions() async {
    // Mock 데이터에서 채팅 세션 반환
    final entities = await getChatSessionEntities();
    return entities
        .map(
          (entity) => {
            'id': entity.id,
            'title': entity.title,
            'messages': entity.messages
                .map(
                  (msg) => {
                    'id': msg.id,
                    'content': msg.content,
                    'type': msg.type.name,
                    'timestamp': msg.timestamp.toIso8601String(),
                    'isTyping': msg.isTyping,
                    'petId': msg.petId,
                    'petName': msg.petName,
                    'metadata': msg.metadata,
                  },
                )
                .toList(),
            'createdAt': entity.createdAt.toIso8601String(),
            'updatedAt': entity.updatedAt.toIso8601String(),
            'petId': entity.petId,
            'petName': entity.petName,
          },
        )
        .toList();
  }

  // AI 전용 메서드들 (엔티티 타입 직접 반환)
  Future<List<AiMessageEntity>> getChatHistoryEntities() async {
    return AiChatMessagesMockData.getChatHistory();
  }

  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestionEntities() async {
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

  Future<List<AiFavoriteQaEntity>> getFavoriteQAEntities() async {
    // 분리된 Mock 데이터 서비스 사용
    return AiMockDataService.getFavoriteQAsMockData();
  }

  Future<List<AiChatSessionEntity>> getChatSessionEntities() async {
    // 분리된 Mock 데이터 서비스 사용
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

  @override
  Future<List<T>> getMockData<T>(String dataType) async {
    switch (dataType.toLowerCase()) {
      case 'messages':
      case 'chathistory':
        return (await getChatHistory()) as List<T>;
      case 'suggestions':
      case 'suggestedquestions':
        return (await getSuggestedQuestions()) as List<T>;
      case 'favorites':
      case 'favoriteqas':
        return (await getFavoriteQAs()) as List<T>;
      case 'sessions':
      case 'chatsessions':
        return (await getChatSessions()) as List<T>;
      default:
        return <T>[];
    }
  }

  @override
  Future<T?> getMockDataById<T>(String dataType, String id) async {
    final dataList = await getMockData<T>(dataType);

    // 각 데이터 타입별로 ID 매칭 로직
    for (final item in dataList) {
      String? itemId;

      if (item is AiMessageEntity) {
        itemId = item.id;
      } else if (item is AiSuggestedQuestionEntity) {
        itemId = item.id;
      } else if (item is AiFavoriteQaEntity) {
        itemId = item.id;
      } else if (item is AiChatSessionEntity) {
        itemId = item.id;
      }

      if (itemId == id) {
        return item;
      }
    }

    return null;
  }
}
