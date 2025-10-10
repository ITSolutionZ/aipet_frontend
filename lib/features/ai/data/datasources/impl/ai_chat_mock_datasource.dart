import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/ai_chat_history_entity.dart';
import '../../../domain/entities/ai_chat_session_entity.dart';
import '../../../domain/entities/ai_message_entity.dart';
import '../ai_chat_datasource.dart';

/// AI 채팅 Mock 데이터소스
class AiChatMockDatasource implements AiChatDatasource {
  final Map<String, List<AiMessageEntity>> _chatHistories = {};
  final Map<String, AiChatSessionEntity> _chatSessions = {};
  final List<AiChatHistoryEntity> _savedHistories = [];

  @override
  Future<List<AiMessageEntity>> getChatHistory({String? sessionId}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (sessionId != null) {
      return _chatHistories[sessionId] ?? [];
    }

    // 모든 메시지 반환 (최신순)
    final allMessages = <AiMessageEntity>[];
    for (final messages in _chatHistories.values) {
      allMessages.addAll(messages);
    }

    allMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allMessages;
  }

  @override
  Future<List<AiMessageEntity>> loadChatHistory({
    required String userId,
    String? petId,
    String? sessionId,
    int? limit,
    int? offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    var messages = await getChatHistory(sessionId: sessionId);

    // 필터링
    if (petId != null) {
      messages = messages.where((msg) => msg.petId == petId).toList();
    }

    // 페이징 적용
    if (offset != null && offset > 0) {
      if (offset >= messages.length) return [];
      messages = messages.skip(offset).toList();
    }

    if (limit != null && limit > 0) {
      messages = messages.take(limit).toList();
    }

    return messages;
  }

  @override
  Future<void> saveChatHistory(AiChatHistoryEntity chatHistory) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedHistories.add(chatHistory);
  }

  @override
  Future<void> clearChatHistory({String? sessionId}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (sessionId != null) {
      _chatHistories.remove(sessionId);
    } else {
      _chatHistories.clear();
    }
  }

  @override
  Future<AiMessageEntity> sendMessage({
    required String message,
    required String sessionId,
    String? petId,
    String? categoryId,
    List<String>? attachedImages,
    Map<String, dynamic>? context,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // AI 응답 지연 시뮬레이션

    // 사용자 메시지 생성
    final userMessage = AiMessageEntity(
      id: _generateId(),
      content: message,
      type: MessageType.user,
      timestamp: DateTime.now(),
      petId: petId,
      metadata: categoryId != null ? {'categoryId': categoryId} : null,
    );

    // AI 응답 생성
    final aiResponse = AiMessageEntity(
      id: _generateId(),
      content: _generateMockResponse(message, categoryId),
      type: MessageType.assistant,
      timestamp: DateTime.now().add(const Duration(seconds: 1)),
      petId: petId,
      metadata: categoryId != null ? {'categoryId': categoryId} : null,
    );

    // 세션에 메시지들 추가
    final sessionMessages = _chatHistories[sessionId] ?? [];
    sessionMessages.addAll([userMessage, aiResponse]);
    _chatHistories[sessionId] = sessionMessages;

    return aiResponse;
  }

  @override
  Future<AiMessageEntity> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
    String? sessionId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // 펫 컨텍스트를 고려한 응답 생성
    final contextualResponse = _generateContextualResponse(
      message,
      petContext,
      weatherAdvice,
      walkGuide,
    );

    final aiMessage = AiMessageEntity(
      id: _generateId(),
      content: contextualResponse,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      petId: petContext?.id,
      petName: petContext?.name,
    );

    // 세션에 추가
    if (sessionId != null) {
      final sessionMessages = _chatHistories[sessionId] ?? [];
      sessionMessages.add(aiMessage);
      _chatHistories[sessionId] = sessionMessages;
    }

    return aiMessage;
  }

  @override
  Future<List<AiChatSessionEntity>> getChatSessions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _chatSessions.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<AiChatSessionEntity> createChatSession(
    String title, {
    String? petId,
    String? categoryId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final session = AiChatSessionEntity(
      id: _generateId(),
      title: title,
      messages: [],
      petId: petId,
      petName: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _chatSessions[session.id] = session;
    _chatHistories[session.id] = [];

    return session;
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _chatSessions.remove(sessionId);
    _chatHistories.remove(sessionId);
  }

  @override
  Future<AiChatSessionEntity> updateChatSession(
    AiChatSessionEntity session,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final updatedSession = AiChatSessionEntity(
      id: session.id,
      title: session.title,
      messages: session.messages,
      petId: session.petId,
      petName: session.petName,
      createdAt: session.createdAt,
      updatedAt: DateTime.now(),
    );

    _chatSessions[session.id] = updatedSession;
    return updatedSession;
  }

  @override
  Future<List<AiChatHistoryEntity>> getChatHistories({
    int limit = 30,
    bool onlyManualSaved = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var histories = List<AiChatHistoryEntity>.from(_savedHistories);

    if (onlyManualSaved) {
      histories = histories.where((h) => h.isManualSaved).toList();
    }

    histories.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return histories.take(limit).toList();
  }

  @override
  Future<void> deleteChatHistory(String historyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedHistories.removeWhere((history) => history.id == historyId);
  }

  /// Mock 응답 생성
  String _generateMockResponse(String message, String? categoryId) {
    final lowerMessage = message.toLowerCase();

    // 카테고리별 응답
    if (categoryId != null) {
      switch (categoryId) {
        case 'health':
          return _generateHealthResponse(lowerMessage);
        case 'behavior':
          return _generateBehaviorResponse(lowerMessage);
        case 'nutrition':
          return _generateNutritionResponse(lowerMessage);
        default:
          break;
      }
    }

    // 일반적인 키워드 기반 응답
    if (lowerMessage.contains('안녕') || lowerMessage.contains('hello')) {
      return '안녕하세요! 반려동물과 관련된 어떤 도움이 필요하신가요?';
    }

    if (lowerMessage.contains('감사') || lowerMessage.contains('고마')) {
      return '도움이 되었다니 기쁩니다! 다른 궁금한 점이 있으시면 언제든 말씀해주세요.';
    }

    return '좋은 질문이네요! 반려동물의 상황을 더 자세히 알려주시면 더 구체적인 조언을 드릴 수 있습니다.';
  }

  String _generateHealthResponse(String message) {
    if (message.contains('아프') || message.contains('병')) {
      return '반려동물이 아픈 것 같다면 가장 중요한 것은 수의사의 진료를 받는 것입니다. 증상이 지속되거나 악화된다면 즉시 병원에 가시기 바랍니다.';
    }

    if (message.contains('예방접종') || message.contains('백신')) {
      return '정기적인 예방접종은 반려동물 건강 관리의 핵심입니다. 수의사와 상담하여 적절한 접종 스케줄을 세우시기 바랍니다.';
    }

    return '반려동물의 건강 관리에 대해 질문해주셔서 감사합니다. 구체적인 증상이나 상황을 알려주시면 더 도움이 될 것 같습니다.';
  }

  String _generateBehaviorResponse(String message) {
    if (message.contains('짖') || message.contains('bark')) {
      return '과도한 짖음은 여러 원인이 있을 수 있습니다. 지루함, 불안, 영역 보호 본능 등이 주된 원인입니다. 일관된 훈련과 충분한 운동이 도움이 됩니다.';
    }

    if (message.contains('훈련') || message.contains('training')) {
      return '효과적인 훈련을 위해서는 일관성과 인내심이 필요합니다. 긍정적 강화 방법을 사용하고, 짧고 규칙적인 훈련 세션을 진행하세요.';
    }

    return '반려동물의 행동에 대해 질문해주셨네요. 구체적인 행동 문제나 상황을 설명해주시면 더 맞춤형 조언을 드릴 수 있습니다.';
  }

  String _generateNutritionResponse(String message) {
    if (message.contains('사료') || message.contains('음식')) {
      return '반려동물의 나이, 크기, 활동량에 맞는 고품질 사료를 선택하는 것이 중요합니다. 급격한 사료 변경은 피하고, 점진적으로 바꿔주세요.';
    }

    if (message.contains('간식') || message.contains('treat')) {
      return '간식은 전체 칼로리의 10%를 넘지 않도록 주의하세요. 사람 음식 중에는 반려동물에게 독성이 있는 것들이 많으니 전용 간식을 이용하시기 바랍니다.';
    }

    return '영양에 대한 질문을 해주셨네요. 반려동물의 종류, 나이, 체중 등의 정보를 알려주시면 더 구체적인 조언을 드릴 수 있습니다.';
  }

  String _generateContextualResponse(
    String message,
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
  ) {
    var response = _generateMockResponse(message, null);

    // 펫 컨텍스트 추가
    if (petContext != null) {
      response += '\n\n${petContext.name}의 정보를 고려한 조언입니다.';
    }

    // 날씨 조언 추가
    if (weatherAdvice != null && weatherAdvice.isNotEmpty) {
      response += '\n\n날씨 관련: $weatherAdvice';
    }

    // 산책 가이드 추가
    if (walkGuide != null && walkGuide.isNotEmpty) {
      response += '\n\n산책 팁: $walkGuide';
    }

    return response;
  }

  String _generateId() {
    return 'mock_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }
}

/// Datasource Provider
final aiChatDatasourceProvider = Provider<AiChatDatasource>((ref) {
  return AiChatMockDatasource();
});
