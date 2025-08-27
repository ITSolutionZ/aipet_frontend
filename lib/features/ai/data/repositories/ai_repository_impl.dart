import 'package:flutter/material.dart';

import '../../domain/entities/ai_message_entity.dart';
import '../../domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  @override
  Future<List<AiMessageEntity>> getChatHistory() async {
    // TODO: Implement actual chat history retrieval
    // For now, return mock data
    return [
      AiMessageEntity(
        id: '1',
        content: 'AI와 대화를 시작하세요!',
        type: MessageType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Future<AiMessageEntity> sendMessage(String message) async {
    // TODO: Implement actual AI API call
    // For now, return mock response
    await Future.delayed(const Duration(seconds: 1)); // Simulate API delay

    return AiMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'AI 응답: $message에 대한 답변입니다.',
      type: MessageType.assistant,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<void> clearChatHistory() async {
    // TODO: Implement chat history clearing
  }

  @override
  Future<List<AiChatSessionEntity>> getChatSessions() async {
    // TODO: Implement actual chat sessions retrieval
    return [];
  }

  @override
  Future<AiChatSessionEntity> createChatSession(
    String title, {
    String? petId,
  }) async {
    // TODO: Implement actual chat session creation
    return AiChatSessionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      petId: petId,
    );
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    // TODO: Implement chat session deletion
  }

  @override
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    // TODO: Implement suggested questions retrieval
    return [
      const AiSuggestedQuestionEntity(
        id: '1',
        question: '우리 강아지 건강 상태는 어떤가요?',
        category: '건강',
        icon: Icons.health_and_safety,
        description: '반려동물의 전반적인 건강 상태를 확인합니다',
      ),
      const AiSuggestedQuestionEntity(
        id: '2',
        question: '산책 일정을 추천해 주세요',
        category: '활동',
        icon: Icons.pets,
        description: '최적의 산책 시간과 장소를 추천합니다',
      ),
    ];
  }
}
