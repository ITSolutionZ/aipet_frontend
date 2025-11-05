import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';



/// 🎯 AI 로컬 저장소 서비스
///
/// AI 관련 데이터를 SharedPreferences를 통해 로컬에 저장하고 관리합니다.
///
/// ## 주요 기능
/// - 채팅 히스토리 영구 저장 및 복원
/// - 즐겨찾기 메시지 관리 (추가/삭제/조회)
/// - 채팅 세션 관리 (생성/삭제/목록 조회)
/// - 채팅 요약 저장 및 관리
/// - 즐겨찾기 QA 관리
///
/// ## 데이터 구조
/// - 모든 데이터는 JSON 형태로 직렬화되어 저장
/// - 에러 발생 시 안전한 폴백 처리
/// - 로깅을 통한 저장/로드 상태 추적
class AiLocalStorageService extends BaseLoggingService {
  static const String _chatHistoryKey = 'ai_chat_history';
  static const String _favoriteMessagesKey = 'ai_favorite_messages';
  static const String _chatSessionsKey = 'ai_chat_sessions';
  static const String _chatSummariesKey = 'ai_chat_summaries';
  static const String _favoriteQAsKey = 'ai_favorite_qas';
  static const String _suggestedQuestionsKey = 'ai_suggested_questions';

  final _cache = CacheService();

  AiLocalStorageService() : super('ai_local_storage');

  // ===== 채팅 히스토리 관리 =====

  /// 채팅 히스토리 저장
  ///
  /// [messages] 채팅 메시지 목록을 JSON으로 직렬화하여 로컬 저장소에 저장합니다.
  ///
  /// ## 동작 방식
  /// 1. 메시지 목록을 JSON 형태로 변환
  /// 2. SharedPreferences에 저장
  /// 3. 성공/실패 로깅
  ///
  /// ## 예외 처리
  /// - 저장 실패 시 예외를 다시 던짐 (rethrow)
  /// - 로깅을 통한 에러 추적
  Future<void> saveChatHistory(List<AiMessageEntity> messages) async {
    try {
      await _cache.initialize();
      final messagesJson = messages.map((msg) => _messageToJson(msg)).toList();
      final jsonString = jsonEncode(messagesJson);

      await _cache.setString(_chatHistoryKey, jsonString);
      logInfo('채팅 히스토리 저장 완료: ${messages.length}개 메시지');
    } catch (e) {
      logError('채팅 히스토리 저장 실패', e);
      rethrow;
    }
  }

  /// 채팅 히스토리 로드
  ///
  /// 로컬 저장소에서 저장된 채팅 히스토리를 로드합니다.
  ///
  /// ## 반환값
  /// - 저장된 메시지가 있으면: `List<AiMessageEntity>`
  /// - 저장된 메시지가 없으면: 빈 리스트 `[]`
  /// - 에러 발생 시: 빈 리스트 `[]` (안전한 폴백)
  ///
  /// ## 동작 방식
  /// 1. SharedPreferences에서 JSON 문자열 로드
  /// 2. JSON을 AiMessageEntity 객체로 역직렬화
  /// 3. 메시지 타입 검증 및 기본값 설정
  Future<List<AiMessageEntity>> loadChatHistory() async {
    try {
      await _cache.initialize();
      final jsonString = _cache.getString(_chatHistoryKey);

      if (jsonString == null || jsonString.isEmpty) {
        logInfo('저장된 채팅 히스토리가 없습니다');
        return [];
      }

      final messagesJson = jsonDecode(jsonString) as List;
      final messages = messagesJson
          .map((json) => _messageFromJson(json))
          .toList();

      logInfo('채팅 히스토리 로드 완료: ${messages.length}개 메시지');
      return messages;
    } catch (e) {
      logError('채팅 히스토리 로드 실패', e);
      return [];
    }
  }

  /// 채팅 히스토리 삭제
  Future<void> clearChatHistory() async {
    try {
      await _cache.initialize();
      await _cache.removeKey(_chatHistoryKey);
      logInfo('채팅 히스토리 삭제 완료');
    } catch (e) {
      logError('채팅 히스토리 삭제 실패', e);
      rethrow;
    }
  }

  // ===== 즐겨찾기 메시지 관리 =====

  /// 즐겨찾기 메시지 저장
  Future<void> saveFavoriteMessage(AiFavoriteEntity favorite) async {
    try {
      await _cache.initialize();
      final favorites = await loadFavoriteMessages();

      // 중복 확인
      favorites.removeWhere((fav) => fav.id == favorite.id);
      favorites.add(favorite);

      final favoritesJson = favorites
          .map((fav) => _favoriteToJson(fav))
          .toList();
      final jsonString = jsonEncode(favoritesJson);

      await _cache.setString(_favoriteMessagesKey, jsonString);
      logInfo('즐겨찾기 메시지 저장 완료: ${favorite.id}');
    } catch (e) {
      logError('즐겨찾기 메시지 저장 실패', e);
      rethrow;
    }
  }

  /// 즐겨찾기 메시지 목록 로드
  Future<List<AiFavoriteEntity>> loadFavoriteMessages() async {
    try {
      await _cache.initialize();
      final jsonString = _cache.getString(_favoriteMessagesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final favoritesJson = jsonDecode(jsonString) as List;
      final favorites = favoritesJson
          .map((json) => _favoriteFromJson(json))
          .toList();

      logInfo('즐겨찾기 메시지 로드 완료: ${favorites.length}개');
      return favorites;
    } catch (e) {
      logError('즐겨찾기 메시지 로드 실패', e);
      return [];
    }
  }

  /// 즐겨찾기 메시지 삭제
  Future<void> removeFavoriteMessage(String favoriteId) async {
    try {
      await _cache.initialize();
      final favorites = await loadFavoriteMessages();

      favorites.removeWhere((fav) => fav.id == favoriteId);

      final favoritesJson = favorites
          .map((fav) => _favoriteToJson(fav))
          .toList();
      final jsonString = jsonEncode(favoritesJson);

      await _cache.setString(_favoriteMessagesKey, jsonString);
      logInfo('즐겨찾기 메시지 삭제 완료: $favoriteId');
    } catch (e) {
      logError('즐겨찾기 메시지 삭제 실패', e);
      rethrow;
    }
  }

  // ===== 채팅 세션 관리 =====

  /// 채팅 세션 저장
  Future<void> saveChatSession(AiChatSessionEntity session) async {
    try {
      await _cache.initialize();
      final sessions = await loadChatSessions();

      // 중복 확인 및 업데이트
      sessions.removeWhere((s) => s.id == session.id);
      sessions.add(session);

      final sessionsJson = sessions.map((s) => _sessionToJson(s)).toList();
      final jsonString = jsonEncode(sessionsJson);

      await _cache.setString(_chatSessionsKey, jsonString);
      logInfo('채팅 세션 저장 완료: ${session.id}');
    } catch (e) {
      logError('채팅 세션 저장 실패', e);
      rethrow;
    }
  }

  /// 채팅 세션 목록 로드
  Future<List<AiChatSessionEntity>> loadChatSessions() async {
    try {
      await _cache.initialize();
      final jsonString = _cache.getString(_chatSessionsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final sessionsJson = jsonDecode(jsonString) as List;
      final sessions = sessionsJson
          .map((json) => _sessionFromJson(json))
          .toList();

      logInfo('채팅 세션 로드 완료: ${sessions.length}개');
      return sessions;
    } catch (e) {
      logError('채팅 세션 로드 실패', e);
      return [];
    }
  }

  /// 채팅 세션 삭제
  Future<void> deleteChatSession(String sessionId) async {
    try {
      await _cache.initialize();
      final sessions = await loadChatSessions();

      sessions.removeWhere((s) => s.id == sessionId);

      final sessionsJson = sessions.map((s) => _sessionToJson(s)).toList();
      final jsonString = jsonEncode(sessionsJson);

      await _cache.setString(_chatSessionsKey, jsonString);
      logInfo('채팅 세션 삭제 완료: $sessionId');
    } catch (e) {
      logError('채팅 세션 삭제 실패', e);
      rethrow;
    }
  }

  // ===== 채팅 요약 관리 =====

  /// 채팅 요약 저장
  Future<void> saveChatSummary(AiChatSummaryEntity summary) async {
    try {
      await _cache.initialize();
      final summaries = await loadChatSummaries();

      summaries.removeWhere((s) => s.id == summary.id);
      summaries.add(summary);

      final summariesJson = summaries.map((s) => _summaryToJson(s)).toList();
      final jsonString = jsonEncode(summariesJson);

      await _cache.setString(_chatSummariesKey, jsonString);
      logInfo('채팅 요약 저장 완료: ${summary.id}');
    } catch (e) {
      logError('채팅 요약 저장 실패', e);
      rethrow;
    }
  }

  /// 채팅 요약 목록 로드
  Future<List<AiChatSummaryEntity>> loadChatSummaries() async {
    try {
      await _cache.initialize();
      final jsonString = _cache.getString(_chatSummariesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final summariesJson = jsonDecode(jsonString) as List;
      final summaries = summariesJson
          .map((json) => _summaryFromJson(json))
          .toList();

      logInfo('채팅 요약 로드 완료: ${summaries.length}개');
      return summaries;
    } catch (e) {
      logError('채팅 요약 로드 실패', e);
      return [];
    }
  }

  /// 채팅 요약 삭제
  Future<void> deleteChatSummary(String summaryId) async {
    try {
      await _cache.initialize();
      final summaries = await loadChatSummaries();

      summaries.removeWhere((s) => s.id == summaryId);

      final summariesJson = summaries.map((s) => _summaryToJson(s)).toList();
      final jsonString = jsonEncode(summariesJson);

      await _cache.setString(_chatSummariesKey, jsonString);
      logInfo('채팅 요약 삭제 완료: $summaryId');
    } catch (e) {
      logError('채팅 요약 삭제 실패', e);
      rethrow;
    }
  }

  // ===== 즐겨찾기 QA 관리 =====

  /// 즐겨찾기 QA 저장
  Future<void> saveFavoriteQA(AiFavoriteQaEntity favoriteQA) async {
    try {
      await _cache.initialize();
      final favoriteQAs = await loadFavoriteQAs();

      favoriteQAs.removeWhere((qa) => qa.id == favoriteQA.id);
      favoriteQAs.add(favoriteQA);

      final qasJson = favoriteQAs.map((qa) => _favoriteQAToJson(qa)).toList();
      final jsonString = jsonEncode(qasJson);

      await _cache.setString(_favoriteQAsKey, jsonString);
      logInfo('즐겨찾기 QA 저장 완료: ${favoriteQA.id}');
    } catch (e) {
      logError('즐겨찾기 QA 저장 실패', e);
      rethrow;
    }
  }

  /// 즐겨찾기 QA 목록 로드
  Future<List<AiFavoriteQaEntity>> loadFavoriteQAs() async {
    try {
      await _cache.initialize();
      final jsonString = _cache.getString(_favoriteQAsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final qasJson = jsonDecode(jsonString) as List;
      final favoriteQAs = qasJson
          .map((json) => _favoriteQAFromJson(json))
          .toList();

      logInfo('즐겨찾기 QA 로드 완료: ${favoriteQAs.length}개');
      return favoriteQAs;
    } catch (e) {
      logError('즐겨찾기 QA 로드 실패', e);
      return [];
    }
  }

  /// 즐겨찾기 QA 삭제
  Future<void> removeFavoriteQA(String qaId) async {
    try {
      await _cache.initialize();
      final favoriteQAs = await loadFavoriteQAs();

      favoriteQAs.removeWhere((qa) => qa.id == qaId);

      final qasJson = favoriteQAs.map((qa) => _favoriteQAToJson(qa)).toList();
      final jsonString = jsonEncode(qasJson);

      await _cache.setString(_favoriteQAsKey, jsonString);
      logInfo('즐겨찾기 QA 삭제 완료: $qaId');
    } catch (e) {
      logError('즐겨찾기 QA 삭제 실패', e);
      rethrow;
    }
  }

  // ===== JSON 변환 메서드들 =====

  Map<String, dynamic> _messageToJson(AiMessageEntity message) {
    return {
      'id': message.id,
      'content': message.content,
      'type': message.type.name,
      'timestamp': message.timestamp.toIso8601String(),
      'isTyping': message.isTyping,
      'petId': message.petId,
      'petName': message.petName,
      'metadata': message.metadata,
    };
  }

  AiMessageEntity _messageFromJson(Map<String, dynamic> json) {
    return AiMessageEntity(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isTyping: json['isTyping'] as bool? ?? false,
      petId: json['petId'] as String?,
      petName: json['petName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> _favoriteToJson(AiFavoriteEntity favorite) {
    return {
      'id': favorite.id,
      'message': _messageToJson(favorite.message),
      'petId': favorite.petId,
      'petName': favorite.petName,
      'category': favorite.category,
      'createdAt': favorite.createdAt.toIso8601String(),
      'updatedAt': favorite.updatedAt.toIso8601String(),
      'userNote': favorite.userNote,
    };
  }

  AiFavoriteEntity _favoriteFromJson(Map<String, dynamic> json) {
    return AiFavoriteEntity(
      id: json['id'] as String,
      message: _messageFromJson(json['message'] as Map<String, dynamic>),
      petId: json['petId'] as String?,
      petName: json['petName'] as String?,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userNote: json['userNote'] as String?,
    );
  }

  Map<String, dynamic> _sessionToJson(AiChatSessionEntity session) {
    return {
      'id': session.id,
      'title': session.title,
      'messages': session.messages.map(_messageToJson).toList(),
      'createdAt': session.createdAt.toIso8601String(),
      'updatedAt': session.updatedAt.toIso8601String(),
      'petId': session.petId,
      'petName': session.petName,
    };
  }

  AiChatSessionEntity _sessionFromJson(Map<String, dynamic> json) {
    return AiChatSessionEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List)
          .map((m) => _messageFromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      petId: json['petId'] as String?,
      petName: json['petName'] as String?,
    );
  }

  Map<String, dynamic> _summaryToJson(AiChatSummaryEntity summary) {
    return {
      'id': summary.id,
      'title': summary.title,
      'summary': summary.summary,
      'category': summary.category,
      'petId': summary.petId,
      'petName': summary.petName,
      'messages': summary.messages.map(_messageToJson).toList(),
      'createdAt': summary.createdAt.toIso8601String(),
      'updatedAt': summary.updatedAt.toIso8601String(),
      'messageCount': summary.messageCount,
      'hasFavorites': summary.hasFavorites,
    };
  }

  AiChatSummaryEntity _summaryFromJson(Map<String, dynamic> json) {
    return AiChatSummaryEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      category: json['category'] as String,
      petId: json['petId'] as String?,
      petName: json['petName'] as String?,
      messages: (json['messages'] as List)
          .map((m) => _messageFromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messageCount: json['messageCount'] as int,
      hasFavorites: json['hasFavorites'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _favoriteQAToJson(AiFavoriteQaEntity qa) {
    return {
      'id': qa.id,
      'question': qa.question,
      'answer': qa.answer,
      'petId': qa.pet?.id,
      'petName': qa.pet?.name,
      'categoryId': qa.categoryId,
      'categoryName': qa.categoryName,
      'createdAt': qa.createdAt.toIso8601String(),
      'originalTimestamp': qa.originalTimestamp.toIso8601String(),
    };
  }

  AiFavoriteQaEntity _favoriteQAFromJson(Map<String, dynamic> json) {
    return AiFavoriteQaEntity(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      pet: null, // 펫 정보는 별도로 로드해야 함
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      originalTimestamp: DateTime.parse(json['originalTimestamp'] as String),
    );
  }

  AiSuggestedQuestionEntity _suggestedQuestionFromJson(
    Map<String, dynamic> json,
  ) {
    return AiSuggestedQuestionEntity(
      id: json['id'] as String,
      question: json['question'] as String,
      category: json['category'] as String,
      icon: json['icon'] != null
          ? IconData(json['icon'] as int, fontFamily: 'MaterialIcons')
          : Icons.help_outline,
      description: json['description'] as String?,
    );
  }

  // ===== 추천 질문 관리 =====

  /// 추천 질문 목록 로드
  Future<List<AiSuggestedQuestionEntity>> loadSuggestedQuestions() async {
    try {
      await _cache.initialize();
      final jsonString = _cache.getString(_suggestedQuestionsKey);

      if (jsonString == null || jsonString.isEmpty) {
        // 기본 추천 질문 반환
        return _getDefaultSuggestedQuestions();
      }

      final questionsJson = jsonDecode(jsonString) as List;
      final questions = questionsJson
          .map((json) => _suggestedQuestionFromJson(json))
          .toList();

      logInfo('추천 질문 로드 완료: ${questions.length}개');
      return questions;
    } catch (e) {
      logError('추천 질문 로드 실패', e);
      return _getDefaultSuggestedQuestions();
    }
  }

  /// 기본 추천 질문 목록
  List<AiSuggestedQuestionEntity> _getDefaultSuggestedQuestions() {
    return [
      const AiSuggestedQuestionEntity(
        id: 'default_1',
        question: 'ペットの健康状態について相談したいです',
        category: 'health',
        icon: Icons.medical_services,
        description: '健康相談',
      ),
      const AiSuggestedQuestionEntity(
        id: 'default_2',
        question: 'おすすめのフードを教えてください',
        category: 'food',
        icon: Icons.restaurant,
        description: 'フード推奨',
      ),
      const AiSuggestedQuestionEntity(
        id: 'default_3',
        question: '散歩のコツを教えてください',
        category: 'walk',
        icon: Icons.directions_walk,
        description: '散歩ガイド',
      ),
    ];
  }

  /// 모든 AI 데이터 초기화
  Future<void> clearAllData() async {
    try {
      await _cache.initialize();
      await _cache.removeKey(_chatHistoryKey);
      await _cache.removeKey(_favoriteMessagesKey);
      await _cache.removeKey(_chatSessionsKey);
      await _cache.removeKey(_chatSummariesKey);
      await _cache.removeKey(_favoriteQAsKey);
      await _cache.removeKey(_suggestedQuestionsKey);
      logInfo('모든 AI 데이터 초기화 완료');
    } catch (e) {
      logError('AI 데이터 초기화 실패', e);
      rethrow;
    }
  }
}
