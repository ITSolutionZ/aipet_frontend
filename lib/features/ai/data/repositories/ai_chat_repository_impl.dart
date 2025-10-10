import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ai_chat_history_entity.dart';
import '../../domain/entities/ai_chat_session_entity.dart';
import '../../domain/entities/ai_message_entity.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../datasources/ai_chat_datasource.dart';
import '../datasources/impl/ai_chat_mock_datasource.dart';

/// AI 채팅 Repository 구현체
class AiChatRepositoryImpl implements AiChatRepository {
  final AiChatDatasource _datasource;

  const AiChatRepositoryImpl(this._datasource);

  @override
  Future<List<AiMessageEntity>> getChatHistory({String? sessionId}) async {
    return _datasource.getChatHistory(sessionId: sessionId);
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
      final messages = await _datasource.loadChatHistory(
        userId: userId,
        petId: petId,
        sessionId: sessionId,
        limit: limit,
        offset: offset,
      );
      return Result.success('채팅 기록을 로드했습니다', messages);
    } catch (error) {
      return Result.failure('채팅 기록 로드 실패: ${error.toString()}');
    }
  }

  @override
  Future<void> saveChatHistory(AiChatHistoryEntity chatHistory) async {
    await _datasource.saveChatHistory(chatHistory);
  }

  @override
  Future<void> clearChatHistory({String? sessionId}) async {
    await _datasource.clearChatHistory(sessionId: sessionId);
  }

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
        return Result.failure('메시지를 입력해주세요');
      }

      final response = await _datasource.sendMessage(
        message: message,
        sessionId: sessionId,
        petId: petId,
        categoryId: categoryId,
        attachedImages: attachedImages,
        context: context,
      );

      return Result.success('메시지를 전송했습니다', response);
    } catch (error) {
      return Result.failure('메시지 전송 실패: ${error.toString()}');
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
      final response = await _datasource.sendMessageWithPetContext(
        message,
        petContext: petContext,
        weatherAdvice: weatherAdvice,
        walkGuide: walkGuide,
        sessionId: sessionId,
      );

      return Result.success('펫 컨텍스트 메시지를 전송했습니다', response);
    } catch (error) {
      return Result.failure('펫 컨텍스트 메시지 전송 실패: ${error.toString()}');
    }
  }

  @override
  Future<List<AiChatSessionEntity>> getChatSessions({String? petId}) async {
    final sessions = await _datasource.getChatSessions();

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
      throw Exception('세션 제목을 입력해주세요');
    }

    return _datasource.createChatSession(
      title.trim(),
      petId: petId,
      categoryId: categoryId,
    );
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    await _datasource.deleteChatSession(sessionId);
  }

  @override
  Future<AiChatSessionEntity> updateChatSession(
    AiChatSessionEntity session,
  ) async {
    return _datasource.updateChatSession(session);
  }

  @override
  Future<List<AiChatHistoryEntity>> getChatHistories({
    int limit = 30,
    bool onlyManualSaved = false,
    String? petId,
  }) async {
    final histories = await _datasource.getChatHistories(
      limit: limit,
      onlyManualSaved: onlyManualSaved,
    );

    if (petId != null) {
      return histories.where((history) => history.pet?.id == petId).toList();
    }

    return histories;
  }

  @override
  Future<void> deleteChatHistoryById(String historyId) async {
    await _datasource.deleteChatHistory(historyId);
  }
}

/// Repository Provider
final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  final datasource = ref.watch(aiChatDatasourceProvider);
  return AiChatRepositoryImpl(datasource);
});
