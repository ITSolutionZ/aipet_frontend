import 'dart:math';

import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/utils/ai_logger.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/foundation/error_handler/error_handler.dart';
import '../../domain/domain.dart';
import '../services/ai_local_storage_service.dart';
import '../services/openai_service.dart';

/// 🎯 AI Repository 구현체
///
/// AI 관련 데이터 접근을 담당하는 Repository의 구현체입니다.
///
/// ## 주요 기능
/// - OpenAI API를 통한 AI 응답 생성
/// - 로컬 저장소를 통한 데이터 영속성 관리
/// - Mock 데이터 서비스를 통한 개발 환경 지원
///
/// ## 아키텍처
/// - Clean Architecture의 Repository 패턴 구현
/// - 의존성 주입을 통한 테스트 가능한 구조
/// - 에러 처리 및 로깅을 통한 안정성 확보
class AiRepositoryImpl implements AiRepository {
  final OpenAIService _openAIService;
  final AiLocalStorageService _localStorageService;
  final LocalStorageService _localStorage;
  final Ref ref;

  AiRepositoryImpl({required OpenAIService openAIService, required this.ref})
    : _openAIService = openAIService,
      _localStorageService = AiLocalStorageService(),
      _localStorage = LocalStorageService.instance;

  /// 채팅 히스토리 조회
  ///
  /// 사용자의 채팅 히스토리를 조회합니다.
  ///
  /// ## 우선순위
  /// 1. 로컬 저장소에서 저장된 히스토리 조회
  /// 2. 로컬에 데이터가 없으면 Mock 데이터 반환 (개발 환경)
  ///
  /// ## 반환값
  /// - `List<AiMessageEntity>`: 채팅 메시지 목록
  @override
  Future<List<AiMessageEntity>> getChatHistory() async {
    // 로컬 저장소에서 채팅 히스토리 가져오기
    final localHistory = await _localStorageService.loadChatHistory();
    return localHistory;
  }

  /// 메시지 전송 및 AI 응답 생성
  ///
  /// 사용자 메시지를 OpenAI API로 전송하여 AI 응답을 생성합니다.
  ///
  /// ## 매개변수
  /// - [message] 사용자가 입력한 메시지
  ///
  /// ## 반환값
  /// - `Result<AiMessageEntity>`: 성공 시 AI 응답 메시지, 실패 시 에러 정보
  ///
  /// ## 처리 과정
  /// 1. OpenAI API 호출
  /// 2. 응답 메시지 생성
  /// 3. 로컬 저장소에 자동 저장
  /// 4. 로깅 및 에러 처리
  @override
  Future<Result<AiMessageEntity>> sendMessage(String message) async {
    try {
      // AI API 호출 시작

      // 실제 OpenAI API 호출
      final response = await _openAIService.generateResponse(message);

      // AI 로거를 사용한 응답 성공 로그
      AiLogger.logApiSuccess(response as String);

      final aiMessage = AiMessageEntity(
        id: _generateId(),
        content: response as String,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );

      // 로컬 저장소에 메시지 저장
      await _saveMessageToLocal(aiMessage);

      return Result.success('AI応答を生成しました', aiMessage);
    } catch (e) {
      // AI 로거를 사용한 에러 로그
      AiLogger.logApiError(e);

      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure('AI応答の生成に失敗しました: ${appException.message}');
    }
  }

  /// 펫 정보와 함께 메시지 전송 및 AI 응답 생성
  ///
  /// 펫의 정보를 컨텍스트로 포함하여 더 정확한 AI 응답을 생성합니다.
  ///
  /// ## 매개변수
  /// - [message] 사용자가 입력한 메시지
  /// - [petContext] 펫 프로필 정보 (선택사항)
  ///
  /// ## 반환값
  /// - `Result<AiMessageEntity>`: 성공 시 AI 응답 메시지, 실패 시 에러 정보
  ///
  /// ## 특징
  /// - 펫 정보를 시스템 프롬프트에 포함하여 개인화된 응답 생성
  /// - 펫 이름, 나이, 종류 등 상세 정보 활용
  /// - 로컬 저장소에 펫 정보와 함께 저장
  @override
  Future<Result<AiMessageEntity>> sendMessageWithPetContext(
    String message, {
    PetProfileEntity? petContext,
    String? weatherAdvice,
    String? walkGuide,
  }) async {
    try {
      // AI 로거를 사용한 API 호출 시작 로그
      AiLogger.logApiStart(message, context: '펫 컨텍스트');
      AiLogger.logPetContext(petContext?.name, petContext?.type);

      // 펫 정보와 함께 OpenAI API 호출
      final response = await _openAIService.generateResponse(
        message,
        petContext: petContext,
        weatherAdvice: weatherAdvice,
        walkGuide: walkGuide,
      );

      // AI 로거를 사용한 응답 성공 로그
      AiLogger.logApiSuccess(response as String);

      final aiMessage = AiMessageEntity(
        id: _generateId(),
        content: response as String,
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        petId: petContext?.id,
        petName: petContext?.name,
      );

      // 로컬 저장소에 메시지 저장
      await _saveMessageToLocal(aiMessage);

      return Result.success('ペット情報を含むAI応答を生成しました', aiMessage);
    } catch (e) {
      // AI 로거를 사용한 에러 로그
      AiLogger.logApiError(e);

      final appException = AppErrorHandler.convertToAppException(e);
      return Result.failure('AI応答の生成に失敗しました: ${appException.message}');
    }
  }

  @override
  Future<void> clearChatHistory() async {
    // 로컬 저장소에서 채팅 히스토리 삭제
    await _localStorageService.clearChatHistory();
  }

  @override
  Future<List<AiChatSessionEntity>> getChatSessions() async {
    // 로컬 저장소에서 채팅 세션 목록 가져오기
    final localSessions = await _localStorageService.loadChatSessions();
    return localSessions;
  }

  @override
  Future<AiChatSessionEntity> createChatSession(
    String title, {
    String? petId,
  }) async {
    // 새로운 채팅 세션 생성
    final session = AiChatSessionEntity(
      id: _generateId(),
      title: title,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      petId: petId,
      petName: null, // 펫 이름은 별도로 조회해야 함
    );

    // 로컬 저장소에 세션 저장
    await _localStorageService.saveChatSession(session);

    return session;
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    // 로컬 저장소에서 채팅 세션 삭제
    await _localStorageService.deleteChatSession(sessionId);
  }

  @override
  Future<List<AiSuggestedQuestionEntity>> getSuggestedQuestions() async {
    // 로컬 저장소에서 추천 질문 가져오기
    final questions = await _localStorage.ai.loadAiCategories();
    if (questions != null && questions.isNotEmpty) {
      return questions
          .map(
            (q) => AiSuggestedQuestionEntity(
              id: q['id'] ?? '',
              question: q['question'] ?? '',
              category: q['category'] ?? '',
              icon: Icons.help_outline,
              description: q['description'] as String?,
            ),
          )
          .toList();
    }
    return [];
  }

  /// 펫 정보 기반 맞춤형 추천 질문 가져오기
  @override
  Future<List<AiSuggestedQuestionEntity>> getPersonalizedSuggestedQuestions({
    String? category,
    PetProfileEntity? pet,
  }) async {
    // 기본 추천 질문 가져오기
    final baseQuestions = [
      AiSuggestedQuestionEntity(
        id: '1',
        question: 'ペットの健康管理について教えてください',
        category: category ?? 'health',
        icon: Icons.medical_services,
        description: '健康管理の基本について',
      ),
      AiSuggestedQuestionEntity(
        id: '2',
        question: 'おすすめのペットフードは何ですか？',
        category: category ?? 'food',
        icon: Icons.restaurant,
        description: 'フード選びのアドバイス',
      ),
      AiSuggestedQuestionEntity(
        id: '3',
        question: 'しつけの基本を教えてください',
        category: category ?? 'behavior',
        icon: Icons.psychology,
        description: 'しつけの基礎知識',
      ),
    ];

    // 카테고리와 펫 정보에 따라 필터링
    if (category != null) {
      return baseQuestions.where((q) => q.category == category).toList();
    }

    return baseQuestions;
  }

  @override
  Future<AiFavoriteEntity> addFavoriteMessage(
    AiMessageEntity message,
    String category, {
    String? petId,
    String? petName,
    String? userNote,
  }) async {
    // 즐겨찾기 메시지 생성
    final favorite = AiFavoriteEntity(
      id: _generateId(),
      message: message,
      petId: petId,
      petName: petName,
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userNote: userNote,
    );

    // 로컬 저장소에 즐겨찾기 저장
    await _localStorageService.saveFavoriteMessage(favorite);

    return favorite;
  }

  @override
  Future<void> removeFavoriteMessage(String favoriteId) async {
    // 로컬 저장소에서 즐겨찾기 메시지 삭제
    await _localStorageService.removeFavoriteMessage(favoriteId);
  }

  @override
  Future<List<AiFavoriteEntity>> getFavoriteMessages({
    String? petId,
    String? category,
  }) async {
    // 로컬 저장소에서 즐겨찾기 메시지 목록 가져오기
    final favorites = await _localStorageService.loadFavoriteMessages();

    // 필터링 적용
    if (petId != null || category != null) {
      return favorites.where((favorite) {
        if (petId != null && favorite.petId != petId) return false;
        if (category != null && favorite.category != category) return false;
        return true;
      }).toList();
    }

    return favorites;
  }

  @override
  List<AiFavoriteQaEntity> getFavoriteQAs() {
    // 로컬 저장소에서 즐겨찾기 QA 목록 가져오기 (동기적)
    return _localStorageService.loadFavoriteQAs();
  }

  @override
  Future<AiChatSummaryEntity> createChatSummary(
    List<AiMessageEntity> messages,
    String category, {
    String? petId,
    String? petName,
  }) async {
    // 채팅 요약 생성
    final summary = messages.length > 1
        ? '${messages[1].content.length > 50 ? messages[1].content.substring(0, 50) : messages[1].content}...'
        : '相談内容';

    final chatSummary = AiChatSummaryEntity(
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

    // 로컬 저장소에 채팅 요약 저장
    await _localStorageService.saveChatSummary(chatSummary);

    return chatSummary;
  }

  @override
  Future<List<AiChatSummaryEntity>> getChatSummaries({
    String? petId,
    String? category,
  }) async {
    // 로컬 저장소에서 채팅 요약 목록 가져오기
    final summaries = await _localStorageService.loadChatSummaries();

    // 필터링 적용
    if (petId != null || category != null) {
      return summaries.where((summary) {
        if (petId != null && summary.petId != petId) return false;
        if (category != null && summary.category != category) return false;
        return true;
      }).toList();
    }

    return summaries;
  }

  @override
  Future<void> deleteChatSummary(String summaryId) async {
    // 로컬 저장소에서 채팅 요약 삭제
    await _localStorageService.deleteChatSummary(summaryId);
  }

  @override
  Future<void> saveChatHistory(AiChatHistoryEntity chatHistory) async {
    // 로컬 저장소에 채팅 히스토리 저장
    // 메시지들을 로컬 저장소에 저장
    await _localStorageService.saveChatHistory(chatHistory.messages);
    debugPrint('채팅 히스토리 저장: ${chatHistory.title}');
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

  @override
  Future<List<AiChatHistoryEntity>> getChatHistories({
    int limit = 30,
    bool onlyManualSaved = false,
  }) async {
    // 로컬 저장소에서 채팅 히스토리 목록 가져오기
    try {
      // Mock 채팅 히스토리 데이터 반환
      // 추후 실제 로컬 저장소 구현 시 교체 예정
      await Future.delayed(const Duration(milliseconds: 100));

      final mockHistories = [
        {
          'id': 'history_1',
          'title': '健康相談',
          'summary': 'ペットの健康について相談しました',
          'messageCount': 5,
          'createdAt': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'isManualSaved': false,
        },
        {
          'id': 'history_2',
          'title': '食事相談',
          'summary': 'ペットの食事について相談しました',
          'messageCount': 3,
          'createdAt': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          'isManualSaved': true,
        },
      ];

      return mockHistories
          .map(
            (history) => AiChatHistoryEntity(
              id: history['id'] as String,
              title: history['title'] as String,
              summary: history['summary'] as String,
              messages: [], // TODO: 실제 메시지 목록 로드 구현 필요
              messageCount: history['messageCount'] as int,
              createdAt: DateTime.parse(history['createdAt'] as String),
              isManualSaved: history['isManualSaved'] as bool,
            ),
          )
          .toList();
    } catch (error) {
      debugPrint('getChatHistories error: $error');
      return [];
    }
  }

  @override
  Future<void> deleteChatHistory(String historyId) async {
    // 로컬 저장소에서 채팅 히스토리 삭제
    // 현재는 전체 히스토리를 삭제
    await _localStorageService.clearChatHistory();
  }

  /// 고유 ID 생성
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'msg_${timestamp}_$random';
  }

  /// 메시지를 로컬 저장소에 저장
  Future<void> _saveMessageToLocal(AiMessageEntity message) async {
    try {
      final existingHistory = await _localStorageService.loadChatHistory();
      existingHistory.add(message);
      await _localStorageService.saveChatHistory(existingHistory);
    } catch (e) {
      debugPrint('메시지 로컬 저장 실패: $e');
    }
  }

  /// 채팅 히스토리 로드 (UseCase용)
  @override
  Future<Result<List<AiMessageEntity>>> loadChatHistory({
    required String userId,
    String? petId,
    int? limit,
    int? offset,
  }) async {
    try {
      final messages = await _localStorageService.loadChatHistory();

      // 펫 ID로 필터링
      var filteredMessages = petId != null
          ? messages.where((msg) => msg.id.contains(petId)).toList()
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

      return Result.success('채팅 히스토리 로드 완료', filteredMessages);
    } catch (e) {
      return Result.failure('채팅 히스토리 로드 실패: $e');
    }
  }

  /// 메시지 분석 (UseCase용)
  @override
  Future<Result<AiAnalysisEntity>> analyzeMessage({
    required String message,
    String? petId,
    Map<String, dynamic>? context,
  }) async {
    try {
      // 간단한 분석 로직 (실제로는 더 복잡한 AI 분석)
      final analysis = AiAnalysisEntity.fromMessage(
        message: message,
        analysis: '메시지 분석이 완료되었습니다. 내용: $message',
        topics: _extractTopics(message),
        confidenceScore: 0.8,
      );

      return Result.success('메시지 분석 완료', analysis);
    } catch (e) {
      return Result.failure('메시지 분석 실패: $e');
    }
  }

  /// 파라미터와 함께 메시지 전송
  @override
  Future<Result<AiMessageEntity>> sendMessageWithParams({
    required String message,
    required String petId,
    String? categoryId,
    List<String>? attachedImages,
  }) async {
    try {
      // 기존 sendMessage 메서드 재사용
      final result = await sendMessage(message);
      return result;
    } catch (e) {
      return Result.failure('메시지 전송 실패: $e');
    }
  }

  /// 즐겨찾기 토글
  @override
  Future<Result<bool>> toggleFavoriteMessage(String messageId) async {
    try {
      // Mock 구현 - 실제로는 로컬 저장소나 서버에서 즐겨찾기 상태 토글
      final isFavorite = Random().nextBool();
      return Result.success('즐겨찾기 토글 완료', isFavorite);
    } catch (e) {
      return Result.failure('즐겨찾기 토글 실패: $e');
    }
  }

  /// 파라미터와 함께 제안 질문 가져오기
  @override
  Future<Result<List<AiSuggestedQuestionEntity>>>
  getSuggestedQuestionsWithParams({String? petId, String? categoryId}) async {
    try {
      // Mock 제안 질문들
      final suggestions = [
        AiSuggestedQuestionEntity(
          id: '1',
          question: '우리 강아지 건강은 어떤가요?',
          category: categoryId ?? '건강',
          // relevanceScore: 0.9,
          icon: Icons.medical_services,
        ),
        AiSuggestedQuestionEntity(
          id: '2',
          question: '오늘 산책은 어떻게 해야 할까요?',
          category: categoryId ?? '산책',
          // relevanceScore: 0.8,
          icon: Icons.directions_walk,
        ),
      ];

      return Result.success('제안 질문 로드 완료', suggestions);
    } catch (e) {
      return Result.failure('제안 질문 가져오기 실패: $e');
    }
  }

  /// 메시지에서 주제 추출
  List<String> _extractTopics(String message) {
    final topics = <String>[];

    if (message.contains('건강') || message.contains('병원')) {
      topics.add('건강');
    }
    if (message.contains('산책') || message.contains('운동')) {
      topics.add('산책');
    }
    if (message.contains('먹이') || message.contains('음식')) {
      topics.add('급식');
    }

    return topics.isEmpty ? ['일반'] : topics;
  }
}
