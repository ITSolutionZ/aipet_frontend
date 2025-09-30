import 'package:aipet_frontend/features/ai/domain/entities/ai_message_entity.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:flutter/foundation.dart';

/// 🧠 AI 채팅 메시지 페이징 및 메모리 관리 서비스
///
/// 메모리 누수 방지를 위해 메시지 수량을 제한하고 페이징을 관리합니다.
class MessagePaginationService {
  static const String _tag = 'MessagePaginationService';

  /// 메모리 내 최대 메시지 수 (100개로 제한)
  static const int maxMessagesInMemory = 100;

  /// 페이지당 메시지 수
  static const int messagesPerPage = 20;

  /// 히스토리 보관 최대 메시지 수 (영구 저장소)
  static const int maxStoredMessages = 1000;

  /// 자동 정리 임계값 (이 수치를 넘으면 자동으로 오래된 메시지 정리)
  static const int autoCleanupThreshold = 120;

  /// 메모리 사용량 모니터링 임계값 (MB)
  static const int memoryThresholdMb = 50;

  /// 메시지 목록에서 메모리 제한을 적용합니다
  ///
  /// [messages] 전체 메시지 목록
  /// [return] 메모리 제한이 적용된 메시지 목록
  static Result<List<AiMessageEntity>> limitMessagesInMemory(List<AiMessageEntity> messages) {
    try {
      if (messages.length <= maxMessagesInMemory) {
        return Result.success('Messages within memory limit', messages);
      }

      // 최신 메시지부터 maxMessagesInMemory개만 유지
      final limitedMessages = messages.skip(messages.length - maxMessagesInMemory).toList();

      final removedCount = messages.length - limitedMessages.length;

      if (kDebugMode) {
        debugPrint('[$_tag] Memory limit applied: removed $removedCount old messages');
        debugPrint('[$_tag] Memory messages count: ${limitedMessages.length}');
      }

      return Result.success(
        'Memory limit applied: $removedCount messages archived',
        limitedMessages,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error limiting messages: $error\n$stackTrace');
      }
      return Result.failure('メッセージ制限適用中にエラーが発生しました');
    }
  }

  /// 자동 정리가 필요한지 확인합니다
  ///
  /// [messageCount] 현재 메시지 수
  /// [return] 정리 필요 여부
  static bool shouldAutoCleanup(int messageCount) {
    return messageCount >= autoCleanupThreshold;
  }

  /// 메시지를 페이지 단위로 분할합니다
  ///
  /// [messages] 전체 메시지 목록
  /// [pageIndex] 페이지 인덱스 (0부터 시작)
  /// [return] 해당 페이지의 메시지 목록
  static Result<List<AiMessageEntity>> getMessagePage(
    List<AiMessageEntity> messages,
    int pageIndex,
  ) {
    try {
      if (pageIndex < 0) {
        return Result.failure('페이지 인덱스는 0 이상이어야 합니다');
      }

      final startIndex = pageIndex * messagesPerPage;
      if (startIndex >= messages.length) {
        return Result.success('Empty page', []);
      }

      final endIndex = (startIndex + messagesPerPage).clamp(0, messages.length);
      final pageMessages = messages.sublist(startIndex, endIndex);

      return Result.success(
        'Page $pageIndex loaded with ${pageMessages.length} messages',
        pageMessages,
      );
    } catch (error) {
      return Result.failure('페이지 로드 중 에러가 발생했습니다: $error');
    }
  }

  /// 총 페이지 수를 계산합니다
  ///
  /// [totalMessages] 전체 메시지 수
  /// [return] 총 페이지 수
  static int calculateTotalPages(int totalMessages) {
    if (totalMessages <= 0) return 0;
    return (totalMessages / messagesPerPage).ceil();
  }

  /// 메시지 목록을 시간순으로 정렬합니다
  ///
  /// [messages] 정렬할 메시지 목록
  /// [ascending] 오름차순 여부 (기본: true, 오래된 것부터)
  /// [return] 정렬된 메시지 목록
  static Result<List<AiMessageEntity>> sortMessagesByTime(
    List<AiMessageEntity> messages, {
    bool ascending = true,
  }) {
    try {
      final sortedMessages = List<AiMessageEntity>.from(messages);

      sortedMessages.sort((a, b) {
        final comparison = a.timestamp.compareTo(b.timestamp);
        return ascending ? comparison : -comparison;
      });

      return Result.success(
        'Messages sorted by time (${ascending ? 'ascending' : 'descending'})',
        sortedMessages,
      );
    } catch (error) {
      return Result.failure('메시지 정렬 중 에러가 발생했습니다: $error');
    }
  }

  /// 중복 메시지를 제거합니다
  ///
  /// [messages] 메시지 목록
  /// [return] 중복이 제거된 메시지 목록
  static Result<List<AiMessageEntity>> removeDuplicateMessages(List<AiMessageEntity> messages) {
    try {
      final seen = <String>{};
      final uniqueMessages = <AiMessageEntity>[];

      for (final message in messages) {
        if (!seen.contains(message.id)) {
          seen.add(message.id);
          uniqueMessages.add(message);
        }
      }

      final removedCount = messages.length - uniqueMessages.length;

      if (removedCount > 0 && kDebugMode) {
        debugPrint('[$_tag] Removed $removedCount duplicate messages');
      }

      return Result.success('Duplicates removed: $removedCount messages', uniqueMessages);
    } catch (error) {
      return Result.failure('중복 제거 중 에러가 발생했습니다: $error');
    }
  }

  /// 메모리 사용량을 추정합니다
  ///
  /// [messages] 메시지 목록
  /// [return] 추정 메모리 사용량 (바이트)
  static int estimateMemoryUsage(List<AiMessageEntity> messages) {
    try {
      int totalSize = 0;

      for (final message in messages) {
        // 메시지 내용 크기 추정
        totalSize += message.content.length * 2; // UTF-16 기준
        totalSize += message.id.length * 2;
        totalSize += message.type.toString().length * 2;

        // 추가 메타데이터 크기 추정 (대략 200바이트)
        totalSize += 200;
      }

      return totalSize;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error estimating memory usage: $error');
      }
      return 0;
    }
  }

  /// 메모리 사용량이 임계값을 초과하는지 확인합니다
  ///
  /// [messages] 메시지 목록
  /// [return] 임계값 초과 여부
  static bool isMemoryUsageHigh(List<AiMessageEntity> messages) {
    final usageBytes = estimateMemoryUsage(messages);
    final usageMB = usageBytes / (1024 * 1024);

    if (kDebugMode && usageMB > memoryThresholdMb * 0.8) {
      debugPrint('[$_tag] Memory usage approaching threshold: ${usageMB.toStringAsFixed(1)}MB');
    }

    return usageMB > memoryThresholdMb;
  }

  /// 메시지 목록을 최적화합니다 (정렬, 중복 제거, 제한 적용)
  ///
  /// [messages] 최적화할 메시지 목록
  /// [return] 최적화된 메시지 목록
  static Result<List<AiMessageEntity>> optimizeMessages(List<AiMessageEntity> messages) {
    try {
      // 1. 중복 제거
      final deduplicatedResult = removeDuplicateMessages(messages);
      if (!deduplicatedResult.isSuccess) {
        return deduplicatedResult;
      }

      // 2. 시간순 정렬
      final sortedResult = sortMessagesByTime(deduplicatedResult.dataOrNull!);
      if (!sortedResult.isSuccess) {
        return Result.failure('정렬 실패: ${sortedResult.error?.toString() ?? 'Unknown error'}');
      }

      // 3. 메모리 제한 적용
      final limitedResult = limitMessagesInMemory(sortedResult.dataOrNull!);
      if (!limitedResult.isSuccess) {
        return Result.failure(
          '메모리 제한 적용 실패: ${limitedResult.error?.toString() ?? 'Unknown error'}',
        );
      }

      final optimizedMessages = limitedResult.dataOrNull!;
      final memoryUsageMB = estimateMemoryUsage(optimizedMessages) / (1024 * 1024);

      if (kDebugMode) {
        debugPrint('[$_tag] Messages optimized:');
        debugPrint('[$_tag] - Original count: ${messages.length}');
        debugPrint('[$_tag] - Optimized count: ${optimizedMessages.length}');
        debugPrint('[$_tag] - Estimated memory: ${memoryUsageMB.toStringAsFixed(2)}MB');
      }

      return Result.success(
        'Messages optimized: ${optimizedMessages.length} messages, ${memoryUsageMB.toStringAsFixed(1)}MB',
        optimizedMessages,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error optimizing messages: $error\n$stackTrace');
      }
      return Result.failure('메시지 최적화 중 에러가 발생했습니다');
    }
  }

  /// 메시지 통계를 생성합니다
  ///
  /// [messages] 메시지 목록
  /// [return] 메시지 통계 정보
  static MessageStatistics generateStatistics(List<AiMessageEntity> messages) {
    try {
      final userMessages = messages.where((m) => m.type == MessageType.user).length;
      final assistantMessages = messages.where((m) => m.type == MessageType.assistant).length;
      final totalCharacters = messages.fold<int>(0, (sum, m) => sum + m.content.length);
      final memoryUsageBytes = estimateMemoryUsage(messages);

      return MessageStatistics(
        totalMessages: messages.length,
        userMessages: userMessages,
        assistantMessages: assistantMessages,
        totalCharacters: totalCharacters,
        memoryUsageBytes: memoryUsageBytes,
        memoryUsageMB: memoryUsageBytes / (1024 * 1024),
        isMemoryHigh: isMemoryUsageHigh(messages),
        needsCleanup: shouldAutoCleanup(messages.length),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error generating statistics: $error');
      }
      return MessageStatistics.empty();
    }
  }
}

/// 메시지 통계 정보 클래스
class MessageStatistics {
  final int totalMessages;
  final int userMessages;
  final int assistantMessages;
  final int totalCharacters;
  final int memoryUsageBytes;
  final double memoryUsageMB;
  final bool isMemoryHigh;
  final bool needsCleanup;

  const MessageStatistics({
    required this.totalMessages,
    required this.userMessages,
    required this.assistantMessages,
    required this.totalCharacters,
    required this.memoryUsageBytes,
    required this.memoryUsageMB,
    required this.isMemoryHigh,
    required this.needsCleanup,
  });

  factory MessageStatistics.empty() {
    return const MessageStatistics(
      totalMessages: 0,
      userMessages: 0,
      assistantMessages: 0,
      totalCharacters: 0,
      memoryUsageBytes: 0,
      memoryUsageMB: 0.0,
      isMemoryHigh: false,
      needsCleanup: false,
    );
  }

  @override
  String toString() {
    return 'MessageStatistics('
        'total: $totalMessages, '
        'user: $userMessages, '
        'assistant: $assistantMessages, '
        'memory: ${memoryUsageMB.toStringAsFixed(2)}MB, '
        'needsCleanup: $needsCleanup'
        ')';
  }
}
