import 'package:aipet_frontend/shared/shared.dart';

import '../../domain/domain.dart';
import '../services/ai_chat_openai_service.dart';
import '../services/ai_local_storage_service.dart';

/// AI 채팅 Repository 구현체
///
/// AI 채팅 관련 기능(메시지, 세션, 히스토리, 요약)을 담당합니다.
/// AiRepository에서 분리되어 채팅 기능만 집중 관리합니다.
class AiChatRepositoryImpl implements AiChatRepository {
  final AiLocalStorageService _localStorageService;
  final AiChatOpenAIService _openAIService;

  AiChatRepositoryImpl({required AiChatOpenAIService openAIService})
    : _openAIService = openAIService,
      _localStorageService = AiLocalStorageService();

  /// ===== 채팅 기록 관련 =====

  @override
  Future<List<AiMessageEntity>> getChatHistory({String? sessionId}) async {
    return _localStorageService.loadChatHistory();
  }

  @override
  Future<Result<List<AiMessageEntity>>> loadChatHistory({
    required String userId,
    String? petId,
    String? sessionId,
    int? limit,
    int? offset,
  }) async {
    try {
      final messages = await _localStorageService.loadChatHistory();

      // 펫 ID로 필터링
      var filteredMessages = petId != null
          ? messages.where((msg) => msg.petId == petId).toList()
          : messages;

      // 최신순 정렬
      filteredMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // offset과 limit 적용
      if (offset != null && offset > 0) {
        filteredMessages = filteredMessages.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        filteredMessages = filteredMessages.take(limit).toList();
      }

      return Result.success('채팅 기록을 로드했습니다', filteredMessages);
    } catch (error) {
      return Result.failure('채팅 기록 로드 실패: ${error.toString()}');
    }
  }

  @override
  Future<void> saveChatHistory(AiChatHistoryEntity chatHistory) async {
    await _localStorageService.saveChatHistory(chatHistory.messages);
  }

  @override
  Future<void> clearChatHistory({String? sessionId}) async {
    await _localStorageService.clearChatHistory();
  }

  /// ===== 메시지 전송 =====

  @override
  Future<Result<AiMessageEntity>> sendMessage({
    required String message,
    required String sessionId,
    String? petId,
    String? categoryId,
    List<String>? attachedImages,
    Map<String, dynamic>? context,
  }) async {
    try {
      // 비즈니스 로직: 메시지 검증
      if (message.trim().isEmpty) {
        return Result.failure('メッセージを入力してください');
      }

      // OpenAI API 호출
      final response = await _openAIService.generateResponse(message);

      if (!response.isSuccess) {
        return Result.failure(response.message);
      }

      final responseContent = response.dataOrNull!;

      // AI 메시지 생성
      final aiMessage = AiMessageEntity(
        id: IdGenerator.generateMessageId(),
        content: responseContent,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        petId: petId,
      );

      // 로컬 저장소에 저장
      await _localStorageService.saveChatHistory([aiMessage]);

      return Result.success('メッセージを送信しました', aiMessage);
    } catch (error) {
      return Result.failure('メッセージ送信失敗: ${error.toString()}');
    }
  }

  @override
  Future<Result<AiMessageEntity>> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
    String? sessionId,
  }) async {
    try {
      // OpenAI API 호출 (펫 컨텍스트 포함)
      final response = await _openAIService.generateResponse(
        message,
        petContext: petContext,
        weatherAdvice: weatherAdvice,
        walkGuide: walkGuide,
      );

      if (!response.isSuccess) {
        return Result.failure(response.message);
      }

      final responseContent = response.dataOrNull!;

      // AI 메시지 생성
      final aiMessage = AiMessageEntity(
        id: IdGenerator.generateMessageId(),
        content: responseContent,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        petId: petContext?.id,
        petName: petContext?.name,
      );

      // 로컬 저장소에 저장
      await _localStorageService.saveChatHistory([aiMessage]);

      return Result.success('ペットコンテキストメッセージを送信しました', aiMessage);
    } catch (error) {
      return Result.failure('ペットコンテキストメッセージ送信失敗: ${error.toString()}');
    }
  }

  /// ===== 채팅 세션 관련 =====

  @override
  Future<List<AiChatSessionEntity>> getChatSessions({String? petId}) async {
    final sessions = await _localStorageService.loadChatSessions();

    if (petId != null) {
      return sessions.where((session) => session.petId == petId).toList();
    }

    return sessions;
  }

  @override
  Future<AiChatSessionEntity> createChatSession(
    String title, {
    String? petId,
    String? categoryId,
  }) async {
    // 비즈니스 로직: 제목 유효성 검사
    if (title.trim().isEmpty) {
      throw Exception('セッションタイトルを入力してください');
    }

    final session = AiChatSessionEntity(
      id: IdGenerator.generateSessionId(),
      title: title.trim(),
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      petId: petId,
    );

    await _localStorageService.saveChatSession(session);
    return session;
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    await _localStorageService.deleteChatSession(sessionId);
  }

  @override
  Future<AiChatSessionEntity> updateChatSession(
    AiChatSessionEntity session,
  ) async {
    await _localStorageService.saveChatSession(session);
    return session;
  }

  /// ===== 채팅 히스토리 관리 =====

  @override
  Future<List<AiChatHistoryEntity>> getChatHistories({
    int limit = 30,
    bool onlyManualSaved = false,
    String? petId,
  }) async {
    // Mock 데이터 반환 (추후 실제 구현으로 교체)
    return [];
  }

  @override
  Future<void> deleteChatHistoryById(String historyId) async {
    await _localStorageService.clearChatHistory();
  }

  /// ===== 채팅 요약 관련 =====

  @override
  Future<AiChatSummaryEntity> createChatSummary(
    List<AiMessageEntity> messages,
    String category, {
    String? petId,
    String? petName,
  }) async {
    // 채팅 요약 생성 로직 (AiRepositoryImpl에서 이관)
    final summary = messages.length > 1
        ? '${messages[1].content.length > 50 ? messages[1].content.substring(0, 50) : messages[1].content}...'
        : '相談内容';

    final chatSummary = AiChatSummaryEntity(
      id: '${DateTime.now().millisecondsSinceEpoch}',
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

    return chatSummary;
  }

  @override
  Future<List<AiChatSummaryEntity>> getChatSummaries({
    String? petId,
    String? category,
  }) async {
    // 로컬 저장소에서 채팅 요약 목록 가져오기
    return [];
  }

  @override
  Future<void> deleteChatSummary(String summaryId) async {
    // 로컬 저장소에서 채팅 요약 삭제
  }

  @override
  Future<AiChatSummary> generateChatSummary({
    required List<String> userMessages,
    required String petName,
    required String category,
  }) async {
    // 실제 ChatGPT API 호출로 요약 생성
    await Future.delayed(const Duration(milliseconds: 300));

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
}
