import 'package:flutter/material.dart';

import '../../../../shared/core/services/mock_data_service.dart';
import '../../domain/domain.dart';

/// AI Mock 데이터 서비스 구현체
///
/// MockDataService 인터페이스를 구현하여 AI 관련 Mock 데이터를 중앙에서 관리합니다.
class AiMockDataServiceImpl implements MockDataService {
  @override
  Future<void> simulateApiDelay({int seconds = 1}) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  @override
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    // 빈 채팅 히스토리 반환 (로컬 저장소에서 로드됨)
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getSuggestedQuestions() async {
    // Mock 추천 질문 반환
    return [
      {
        'id': '1',
        'question': 'ペットの健康管理について教えてください',
        'category': 'health',
        'description': '健康管理の基本について',
      },
      {
        'id': '2',
        'question': 'おすすめのペットフードは何ですか？',
        'category': 'food',
        'description': 'フード選びのアドバイス',
      },
      {
        'id': '3',
        'question': 'しつけの基本を教えてください',
        'category': 'behavior',
        'description': 'しつけの基礎知識',
      },
    ];
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
    // 빈 채팅 히스토리 반환 (로컬 저장소에서 로드됨)
    return [];
  }

  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestionEntities() async {
    return [
      const AiSuggestedQuestionEntity(
        id: '1',
        question: 'ペットの健康管理について教えてください',
        category: 'health',
        icon: Icons.medical_services,
        description: '健康管理の基本について',
      ),
      const AiSuggestedQuestionEntity(
        id: '2',
        question: 'おすすめのペットフードは何ですか？',
        category: 'food',
        icon: Icons.restaurant,
        description: 'フード選びのアドバイス',
      ),
      const AiSuggestedQuestionEntity(
        id: '3',
        question: 'しつけの基本を教えてください',
        category: 'behavior',
        icon: Icons.psychology,
        description: 'しつけの基礎知識',
      ),
    ];
  }

  Future<List<AiFavoriteQaEntity>> getFavoriteQAEntities() async {
    // 빈 즐겨찾기 목록 반환 (로컬 저장소에서 로드됨)
    return [];
  }

  Future<List<AiChatSessionEntity>> getChatSessionEntities() async {
    // 빈 세션 목록 반환 (로컬 저장소에서 로드됨)
    return [];
  }

  @override
  Future<Map<String, dynamic>> generateAiResponse(String userMessage) async {
    // Mock AI 응답 생성
    return {
      'id': 'ai_${DateTime.now().millisecondsSinceEpoch}',
      'content': 'ペットについてのご質問ありがとうございます。詳しい情報を教えていただけますか？',
      'type': 'assistant',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> createChatSession(
    String title, {
    String? petId,
  }) async {
    // Mock 채팅 세션 생성
    return {
      'id': 'session_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'petId': petId,
      'messages': [],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
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
