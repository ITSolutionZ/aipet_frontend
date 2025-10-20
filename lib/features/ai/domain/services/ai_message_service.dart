import 'dart:async';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/ai_usecase_providers.dart';
import '../entities/ai_category_entity.dart';
import '../entities/ai_message_entity.dart';
import '../entities/ai_suggested_question_entity.dart';
import '../usecases/load_chat_history_usecase.dart';
import '../usecases/send_message_usecase.dart';

/// 🎯 AI 메시지 전용 서비스
///
/// 메시지 전송, 수신, 분석 등의 핵심 비즈니스 로직을 처리합니다.
class AiMessageService {
  final Ref _ref;

  // UseCases
  late final SendMessageUseCase _sendMessageUseCase;
  late final LoadChatHistoryUseCase _loadHistoryUseCase;

  AiMessageService(this._ref) {
    _initializeUseCases();
  }

  void _initializeUseCases() {
    _sendMessageUseCase = _ref.read(sendMessageUseCaseProvider);
    _loadHistoryUseCase = _ref.read(loadChatHistoryUseCaseProvider);
  }

  /// ✅ 메시지 전송 처리
  Future<Result<AiMessageEntity>> sendMessage({
    required String message,
    required String selectedPetId, // PetProfile -> String petId로 변경
    required AiCategoryEntity? selectedCategory,
    List<String>? attachedImages,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📤 Sending AI message: ${message.substring(0, message.length.clamp(0, 50))}...',
        );
      }

      final params = SendMessageParams(
        message: message,
        petId: selectedPetId,
        categoryId: selectedCategory?.id,
        attachedImages: attachedImages ?? [],
      );

      final result = await _sendMessageUseCase(params);

      if (result.isSuccess && kDebugMode) {
        debugPrint('✅ Message sent successfully');
      }

      return result;
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
      return Result.failure('메시지 전송 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ AI 응답 분석
  Future<Result<MessageAnalysis>> analyzeMessage({
    required String messageContent,
    required String petId, // PetProfile -> String petId로 변경
    AiCategoryEntity? category,
  }) async {
    try {
      // 임시로 분석 결과를 반환하도록 수정 (실제로는 _analyzeMessageUseCase 호출)
      return Result.success(
        '메시지 분석 완료',
        MessageAnalysis(
          response: AiMessageEntity(
            id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
            content: '메시지 분석이 완료되었습니다: $messageContent',
            timestamp: DateTime.now(),
            type: MessageType.assistant,
          ),
          detectedTopics: ['일반'],
          confidenceScore: 0.8,
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to analyze message: $e');
      return Result.failure('메시지 분석 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 채팅 기록 로드
  Future<Result<List<AiMessageEntity>>> loadChatHistory({
    required String petId,
    int? limit,
    String? lastMessageId,
  }) async {
    try {
      final params = LoadChatHistoryParams(
        userId: 'current_user', // 임시로 추가
        petId: petId,
        limit: limit ?? 50,
        offset: 0, // lastMessageId 대신 offset 사용
      );

      return await _loadHistoryUseCase.call(params);
    } catch (e) {
      debugPrint('❌ Failed to load chat history: $e');
      return Result.failure('채팅 기록 로드 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 제안 질문 가져오기
  Future<Result<List<AiSuggestedQuestionEntity>>> getSuggestedQuestions({
    required String petId, // PetProfile -> String petId로 변경
    AiCategoryEntity? category,
  }) async {
    try {
      // 임시로 고정된 제안 질문 반환 (실제로는 UseCase 호출)
      final suggestions = [
        AiSuggestedQuestionEntity(
          id: '1',
          question: '우리 강아지 건강은 어떤가요?',
          category: category?.name ?? '일반',
          // relevanceScore: 0.9,
          icon: Icons.medical_services,
        ),
        AiSuggestedQuestionEntity(
          id: '2',
          question: '오늘 산책은 어떻게 해야 할까요?',
          category: category?.name ?? '일반',
          // relevanceScore: 0.8,
          icon: Icons.directions_walk,
        ),
      ];

      return Result.success('제안 질문 생성 완료', suggestions);
    } catch (e) {
      debugPrint('❌ Failed to get suggested questions: $e');
      return Result.failure('제안 질문 로드 중 오류가 발생했습니다: $e');
    }
  }

  /// ✅ 메시지 검증
  Result<void> validateMessage(String message) {
    if (message.trim().isEmpty) {
      return Result.failure('메시지를 입력해주세요');
    }

    if (message.length > 2000) {
      return Result.failure('메시지는 2000자를 초과할 수 없습니다');
    }

    if (message.trim().length < 2) {
      return Result.failure('최소 2글자 이상 입력해주세요');
    }

    return Result.success('채팅 기록 삭제 완료', null);
  }

  /// ✅ 메시지 통계 계산
  MessageStatistics calculateMessageStatistics(List<AiMessageEntity> messages) {
    if (messages.isEmpty) {
      return MessageStatistics.empty();
    }

    final userMessages = messages
        .where((m) => m.type == MessageType.user)
        .toList();
    final aiMessages = messages
        .where((m) => m.type == MessageType.assistant)
        .toList();

    final totalWords = messages.fold<int>(
      0,
      (sum, message) => sum + message.content.split(' ').length,
    );

    final avgResponseTime = aiMessages.isNotEmpty
        ? aiMessages
                  .map((m) => m.timestamp.millisecondsSinceEpoch.toDouble())
                  .reduce((a, b) => a + b) /
              aiMessages.length
        : 0.0;

    return MessageStatistics(
      totalMessages: messages.length,
      userMessages: userMessages.length,
      aiMessages: aiMessages.length,
      totalWords: totalWords,
      averageResponseTimeMs: avgResponseTime,
      lastMessageTime: messages.isNotEmpty
          ? messages.last.timestamp
          : DateTime.now(),
    );
  }

  /// ✅ 리소스 해제
  void dispose() {
    // 필요시 스트림 구독 해제 등
  }
}

/// 🎯 메시지 분석 결과
class MessageAnalysis {
  final AiMessageEntity response;
  final List<String> detectedTopics;
  final double confidenceScore;
  final Map<String, dynamic>? metadata;

  const MessageAnalysis({
    required this.response,
    required this.detectedTopics,
    required this.confidenceScore,
    this.metadata,
  });
}

/// 📊 메시지 통계 정보
class MessageStatistics {
  final int totalMessages;
  final int userMessages;
  final int aiMessages;
  final int totalWords;
  final double averageResponseTimeMs;
  final DateTime lastMessageTime;

  const MessageStatistics({
    required this.totalMessages,
    required this.userMessages,
    required this.aiMessages,
    required this.totalWords,
    required this.averageResponseTimeMs,
    required this.lastMessageTime,
  });

  factory MessageStatistics.empty() {
    return MessageStatistics(
      totalMessages: 0,
      userMessages: 0,
      aiMessages: 0,
      totalWords: 0,
      averageResponseTimeMs: 0.0,
      lastMessageTime: DateTime.now(),
    );
  }
}
