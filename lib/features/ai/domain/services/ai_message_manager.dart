import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';

import '../entities/ai_message_entity.dart';
import 'ai_message_service.dart';
import 'message_pagination_service.dart';

/// 🧠 AI 메시지 관리 서비스
///
/// AI 채팅의 메시지 관리 책임을 담당합니다.
/// - 메시지 추가/제거
/// - 메시지 검증 및 최적화
/// - 메모리 관리
///
/// ## 아키텍처 노트
/// - **Static Utility Class**: 모든 메서드가 static이며 상태를 가지지 않음
/// - **순수 함수**: 입력에 대해 항상 동일한 출력 반환
/// - **테스트 가능**: 의존성 없이 독립적으로 테스트 가능
class AiMessageManager {
  static const String _tag = 'AiMessageManager';

  /// 메시지 목록에 새 메시지 추가
  ///
  /// [currentMessages] 현재 메시지 목록
  /// [newMessages] 추가할 메시지들
  /// [return] 최적화된 메시지 목록
  static Result<List<AiMessageEntity>> addMessages(
    List<AiMessageEntity> currentMessages,
    List<AiMessageEntity> newMessages,
  ) {
    try {
      if (newMessages.isEmpty) {
        return Result.success('No new messages to add', currentMessages);
      }

      // 중복 메시지 제거
      final combinedMessages = [...currentMessages];
      for (final newMessage in newMessages) {
        if (!combinedMessages.any((msg) => msg.id == newMessage.id)) {
          combinedMessages.add(newMessage);
        }
      }

      // 메시지 최적화 (페이징, 정렬, 중복 제거)
      final optimizedResult = MessagePaginationService.optimizeMessages(
        combinedMessages,
      );

      if (optimizedResult.isSuccess) {
        if (kDebugMode) {
          debugPrint(
            '[$_tag] Messages added and optimized: ${optimizedResult.dataOrNull!.length} total',
          );
        }
        return optimizedResult;
      }

      // 최적화 실패 시 원본 반환
      if (kDebugMode) {
        debugPrint(
          '[$_tag] Optimization failed, returning unoptimized messages',
        );
      }
      return Result.success(
        'Messages added without optimization',
        combinedMessages,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error adding messages: $error\n$stackTrace');
      }
      return Result.failure('메시지 추가 중 오류 발생: $error');
    }
  }

  /// 단일 메시지 추가
  ///
  /// [currentMessages] 현재 메시지 목록
  /// [message] 추가할 메시지
  /// [return] 업데이트된 메시지 목록
  static Result<List<AiMessageEntity>> addMessage(
    List<AiMessageEntity> currentMessages,
    AiMessageEntity message,
  ) {
    return addMessages(currentMessages, [message]);
  }

  /// 메시지 타입별 검증
  ///
  /// [message] 검증할 메시지
  /// [return] 검증 결과
  static Result<bool> validateMessage(AiMessageEntity message) {
    try {
      // 기본 필드 검증
      if (message.id.isEmpty) {
        return Result.failure('메시지 ID가 비어있습니다');
      }

      if (message.content.trim().isEmpty) {
        return Result.failure('메시지 내용이 비어있습니다');
      }

      // 메시지 길이 제한
      const maxContentLength = 10000;
      if (message.content.length > maxContentLength) {
        return Result.failure(
          '메시지가 너무 깁니다 (${message.content.length}/$maxContentLength자)',
        );
      }

      // 타입별 특수 검증
      switch (message.type) {
        case MessageType.user:
          return _validateUserMessage(message);
        case MessageType.assistant:
          return _validateAssistantMessage(message);
        case MessageType.system:
          return _validateSystemMessage(message);
      }
    } catch (error) {
      return Result.failure('메시지 검증 중 오류: $error');
    }
  }

  /// 메시지 목록 정리 및 최적화
  ///
  /// [messages] 정리할 메시지 목록
  /// [return] 정리된 메시지 목록
  static Result<List<AiMessageEntity>> cleanupMessages(
    List<AiMessageEntity> messages,
  ) {
    try {
      // 빈 메시지 제거
      final nonEmptyMessages = messages
          .where((msg) => msg.content.trim().isNotEmpty)
          .toList();

      // 연속된 같은 타입 메시지 확인 및 정리
      final cleanedMessages = <AiMessageEntity>[];
      MessageType? lastType;

      for (final message in nonEmptyMessages) {
        // 연속된 시스템 메시지는 마지막 것만 유지
        if (message.type == MessageType.system &&
            lastType == MessageType.system) {
          if (cleanedMessages.isNotEmpty) {
            cleanedMessages.removeLast();
          }
        }

        cleanedMessages.add(message);
        lastType = message.type;
      }

      // 메시지 최적화 적용
      final optimizedResult = MessagePaginationService.optimizeMessages(
        cleanedMessages,
      );

      if (optimizedResult.isSuccess) {
        if (kDebugMode) {
          debugPrint(
            '[$_tag] Messages cleaned up: ${messages.length} → ${optimizedResult.dataOrNull!.length}',
          );
        }
        return optimizedResult;
      }

      // 최적화 실패 시 정리된 메시지 반환
      return Result.success(
        'Messages cleaned up without optimization',
        cleanedMessages,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error cleaning up messages: $error\n$stackTrace');
      }
      return Result.failure('메시지 정리 중 오류 발생: $error');
    }
  }

  /// 특정 메시지 ID로 메시지 찾기
  ///
  /// [messages] 검색할 메시지 목록
  /// [messageId] 찾을 메시지 ID
  /// [return] 찾은 메시지와 인덱스
  static Result<MessageSearchResult> findMessage(
    List<AiMessageEntity> messages,
    String messageId,
  ) {
    try {
      for (int i = 0; i < messages.length; i++) {
        if (messages[i].id == messageId) {
          final result = MessageSearchResult(
            message: messages[i],
            index: i,
            found: true,
          );
          return Result.success('Message found at index $i', result);
        }
      }

      const result = MessageSearchResult(
        message: null,
        index: -1,
        found: false,
      );
      return Result.success('Message not found', result);
    } catch (error) {
      return Result.failure('메시지 검색 중 오류: $error');
    }
  }

  /// 메시지 통계 생성
  ///
  /// [messages] 통계를 생성할 메시지 목록
  /// [return] 메시지 통계
  static MessageStatistics generateStatistics(List<AiMessageEntity> messages) {
    try {
      final userMessages = messages
          .where((m) => m.type == MessageType.user)
          .length;
      final assistantMessages = messages
          .where((m) => m.type == MessageType.assistant)
          .length;
      final totalWords = messages.fold<int>(
        0,
        (sum, m) => sum + m.content.split(' ').length,
      );

      return MessageStatistics(
        totalMessages: messages.length,
        userMessages: userMessages,
        aiMessages: assistantMessages,
        totalWords: totalWords,
        averageResponseTimeMs: 0.0,
        lastMessageTime: messages.isNotEmpty
            ? messages.last.timestamp
            : DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error generating statistics: $e');
      }
      return MessageStatistics.empty();
    }
  }

  /// 메모리 사용량 확인 및 경고
  ///
  /// [messages] 확인할 메시지 목록
  /// [return] 메모리 상태 정보
  static MemoryStatus checkMemoryStatus(List<AiMessageEntity> messages) {
    try {
      final isMemoryHigh = MessagePaginationService.isMemoryUsageHigh(messages);
      final shouldCleanup = MessagePaginationService.shouldAutoCleanup(
        messages.length,
      );
      final estimatedUsage = MessagePaginationService.estimateMemoryUsage(
        messages,
      );

      final status = MemoryStatus(
        isHigh: isMemoryHigh,
        shouldCleanup: shouldCleanup,
        estimatedBytes: estimatedUsage,
        estimatedMB: estimatedUsage / (1024 * 1024),
        messageCount: messages.length,
        recommendation: _getMemoryRecommendation(isMemoryHigh, shouldCleanup),
      );

      if (kDebugMode && (isMemoryHigh || shouldCleanup)) {
        debugPrint('[$_tag] 🚨 Memory status: ${status.recommendation}');
      }

      return status;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error checking memory status: $error');
      }
      return MemoryStatus.safe();
    }
  }

  // 내부 검증 메서드들
  static Result<bool> _validateUserMessage(AiMessageEntity message) {
    // 사용자 메시지는 반드시 내용이 있어야 함
    if (message.content.trim().length < 2) {
      return Result.failure('사용자 메시지가 너무 짧습니다');
    }

    return Result.success('User message valid', true);
  }

  static Result<bool> _validateAssistantMessage(AiMessageEntity message) {
    // AI 응답은 반드시 의미있는 내용이 있어야 함
    if (message.content.trim().length < 5) {
      return Result.failure('AI 응답이 너무 짧습니다');
    }

    // 일반적인 에러 응답 패턴 체크
    final errorPatterns = ['error', 'failed', 'cannot', 'unable'];
    final contentLower = message.content.toLowerCase();

    final hasErrorPattern = errorPatterns.any(
      (pattern) => contentLower.contains(pattern),
    );
    if (hasErrorPattern && message.content.length < 50) {
      return Result.failure('AI 응답에 오류 패턴이 감지되었습니다');
    }

    return Result.success('Assistant message valid', true);
  }

  static Result<bool> _validateSystemMessage(AiMessageEntity message) {
    // 시스템 메시지는 특별한 형식을 가져야 함
    if (!message.content.startsWith('[') || !message.content.endsWith(']')) {
      return Result.failure('시스템 메시지 형식이 올바르지 않습니다');
    }

    return Result.success('System message valid', true);
  }

  static String _getMemoryRecommendation(bool isHigh, bool shouldCleanup) {
    if (isHigh && shouldCleanup) {
      return '메모리 사용량이 높고 정리가 필요합니다';
    } else if (isHigh) {
      return '메모리 사용량이 높습니다';
    } else if (shouldCleanup) {
      return '메시지 정리가 권장됩니다';
    } else {
      return '메모리 상태가 양호합니다';
    }
  }
}

/// 메시지 검색 결과
class MessageSearchResult {
  final AiMessageEntity? message;
  final int index;
  final bool found;

  const MessageSearchResult({
    required this.message,
    required this.index,
    required this.found,
  });
}

/// 메모리 상태 정보
class MemoryStatus {
  final bool isHigh;
  final bool shouldCleanup;
  final int estimatedBytes;
  final double estimatedMB;
  final int messageCount;
  final String recommendation;

  const MemoryStatus({
    required this.isHigh,
    required this.shouldCleanup,
    required this.estimatedBytes,
    required this.estimatedMB,
    required this.messageCount,
    required this.recommendation,
  });

  factory MemoryStatus.safe() {
    return const MemoryStatus(
      isHigh: false,
      shouldCleanup: false,
      estimatedBytes: 0,
      estimatedMB: 0.0,
      messageCount: 0,
      recommendation: '메모리 상태가 안전합니다',
    );
  }

  @override
  String toString() {
    return 'MemoryStatus(high: $isHigh, cleanup: $shouldCleanup, '
        'size: ${estimatedMB.toStringAsFixed(2)}MB, count: $messageCount)';
  }
}
