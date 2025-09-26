import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter/foundation.dart';

/// 🪙 OpenAI 토큰 사용량 추적 및 관리 서비스
///
/// OpenAI API 사용량을 모니터링하고 비용을 추적하여 남용을 방지합니다.
class TokenUsageService {
  static const String _tag = 'TokenUsageService';

  /// 일일 토큰 사용량 제한 (GPT-3.5-turbo 기준)
  static const int dailyTokenLimit = 50000;

  /// 시간당 토큰 사용량 제한
  static const int hourlyTokenLimit = 10000;

  /// 단일 요청 최대 토큰 수
  static const int maxTokensPerRequest = 4000;

  /// 경고 임계값 (일일 제한의 80%)
  static const int warningThreshold = dailyTokenLimit * 80 ~/ 100;

  /// 토큰당 예상 비용 (USD, GPT-3.5-turbo 기준)
  static const double costPerToken = 0.002 / 1000;

  /// 토큰 사용량 기록
  static final Map<String, int> _dailyUsage = {};
  static final Map<String, int> _hourlyUsage = {};
  static final List<TokenUsageRecord> _usageHistory = [];

  /// 토큰 사용량 기록 및 검증
  ///
  /// [promptTokens] 입력 토큰 수
  /// [completionTokens] 완료 토큰 수
  /// [model] 사용된 모델명
  /// [return] 사용량 기록 결과
  static Result<TokenUsageRecord> recordUsage({
    required int promptTokens,
    required int completionTokens,
    required String model,
    String? userId,
  }) {
    try {
      final totalTokens = promptTokens + completionTokens;
      final now = DateTime.now();
      final dateKey = _formatDateKey(now);
      final hourKey = _formatHourKey(now);

      // 일일 사용량 체크
      final currentDailyUsage = _dailyUsage[dateKey] ?? 0;
      if (currentDailyUsage + totalTokens > dailyTokenLimit) {
        return ResultFactory.failure('일일 토큰 사용량 한도 초과 ($dailyTokenLimit 토큰)');
      }

      // 시간당 사용량 체크
      final currentHourlyUsage = _hourlyUsage[hourKey] ?? 0;
      if (currentHourlyUsage + totalTokens > hourlyTokenLimit) {
        return ResultFactory.failure(
          '시간당 토큰 사용량 한도 초과 ($hourlyTokenLimit 토큰)',
        );
      }

      // 사용량 기록
      _dailyUsage[dateKey] = currentDailyUsage + totalTokens;
      _hourlyUsage[hourKey] = currentHourlyUsage + totalTokens;

      final usageRecord = TokenUsageRecord(
        timestamp: now,
        promptTokens: promptTokens,
        completionTokens: completionTokens,
        totalTokens: totalTokens,
        model: model,
        userId: userId,
        estimatedCost: totalTokens * costPerToken,
      );

      _usageHistory.add(usageRecord);

      // 메모리 관리: 최대 1000개 기록 유지
      if (_usageHistory.length > 1000) {
        _usageHistory.removeRange(0, _usageHistory.length - 1000);
      }

      // 경고 레벨 확인
      if (currentDailyUsage + totalTokens >= warningThreshold && kDebugMode) {
        debugPrint(
          '[$_tag] ⚠️ 일일 토큰 사용량이 경고 임계값에 도달: ${currentDailyUsage + totalTokens}/$dailyTokenLimit',
        );
      }

      if (kDebugMode) {
        debugPrint(
          '[$_tag] 토큰 사용량 기록: $totalTokens 토큰 (일일: ${currentDailyUsage + totalTokens}/$dailyTokenLimit)',
        );
      }

      return ResultFactory.success(usageRecord, '토큰 사용량 기록 완료');
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error recording token usage: $error\n$stackTrace');
      }
      return ResultFactory.failure('토큰 사용량 기록 중 오류 발생');
    }
  }

  /// 현재 일일 사용량 조회
  static int getDailyUsage([DateTime? date]) {
    final dateKey = _formatDateKey(date ?? DateTime.now());
    return _dailyUsage[dateKey] ?? 0;
  }

  /// 현재 시간당 사용량 조회
  static int getHourlyUsage([DateTime? dateTime]) {
    final hourKey = _formatHourKey(dateTime ?? DateTime.now());
    return _hourlyUsage[hourKey] ?? 0;
  }

  /// 일일 사용량 통계 생성
  static TokenUsageStatistics getDailyStatistics([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    final dateKey = _formatDateKey(targetDate);
    final usage = _dailyUsage[dateKey] ?? 0;

    return TokenUsageStatistics(
      date: targetDate,
      totalTokens: usage,
      remainingTokens: (dailyTokenLimit - usage).clamp(0, dailyTokenLimit),
      usagePercentage: (usage / dailyTokenLimit * 100).clamp(0.0, 100.0),
      estimatedCost: usage * costPerToken,
      isOverLimit: usage >= dailyTokenLimit,
      isNearLimit: usage >= warningThreshold,
      requestCount: _getRequestCountForDate(targetDate),
    );
  }

  /// 사용량 히스토리 조회
  static List<TokenUsageRecord> getUsageHistory({int? limit}) {
    final history = List<TokenUsageRecord>.from(_usageHistory);
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // 최신순

    if (limit != null && history.length > limit) {
      return history.take(limit).toList();
    }
    return history;
  }

  /// 사용량 히스토리 초기화
  static void clearUsageHistory() {
    _usageHistory.clear();
    if (kDebugMode) {
      debugPrint('[$_tag] Token usage history cleared');
    }
  }

  /// 오래된 사용량 데이터 정리
  static void cleanupOldData() {
    final now = DateTime.now();
    final cutoffDate = now.subtract(const Duration(days: 7));

    // 7일 이전 데이터 제거
    _dailyUsage.removeWhere((key, _) {
      final date = DateTime.parse(key);
      return date.isBefore(cutoffDate);
    });

    // 1일 이전 시간별 데이터 제거
    final hourCutoffDate = now.subtract(const Duration(days: 1));
    _hourlyUsage.removeWhere((key, _) {
      final parts = key.split('-');
      if (parts.length >= 4) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
          int.parse(parts[3]),
        );
        return date.isBefore(hourCutoffDate);
      }
      return true;
    });

    if (kDebugMode) {
      debugPrint('[$_tag] Old token usage data cleaned up');
    }
  }

  /// 요청 가능 여부 확인
  static Result<bool> canMakeRequest({int estimatedTokens = 1000}) {
    final now = DateTime.now();
    final dateKey = _formatDateKey(now);
    final hourKey = _formatHourKey(now);

    final currentDailyUsage = _dailyUsage[dateKey] ?? 0;
    final currentHourlyUsage = _hourlyUsage[hourKey] ?? 0;

    if (currentDailyUsage + estimatedTokens > dailyTokenLimit) {
      return ResultFactory.failure('일일 토큰 한도 초과');
    }

    if (currentHourlyUsage + estimatedTokens > hourlyTokenLimit) {
      return ResultFactory.failure('시간당 토큰 한도 초과');
    }

    return ResultFactory.success(true, '요청 가능');
  }

  // 내부 헬퍼 메서드들
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatHourKey(DateTime dateTime) {
    return '${_formatDateKey(dateTime)}-${dateTime.hour.toString().padLeft(2, '0')}';
  }

  static int _getRequestCountForDate(DateTime date) {
    final dateKey = _formatDateKey(date);
    return _usageHistory
        .where((record) => _formatDateKey(record.timestamp) == dateKey)
        .length;
  }
}

/// 토큰 사용량 기록 데이터 클래스
class TokenUsageRecord {
  final DateTime timestamp;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final String model;
  final String? userId;
  final double estimatedCost;

  const TokenUsageRecord({
    required this.timestamp,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.model,
    this.userId,
    required this.estimatedCost,
  });

  @override
  String toString() {
    return 'TokenUsageRecord(timestamp: $timestamp, totalTokens: $totalTokens, model: $model, cost: \$${estimatedCost.toStringAsFixed(4)})';
  }
}

/// 토큰 사용량 통계 데이터 클래스
class TokenUsageStatistics {
  final DateTime date;
  final int totalTokens;
  final int remainingTokens;
  final double usagePercentage;
  final double estimatedCost;
  final bool isOverLimit;
  final bool isNearLimit;
  final int requestCount;

  const TokenUsageStatistics({
    required this.date,
    required this.totalTokens,
    required this.remainingTokens,
    required this.usagePercentage,
    required this.estimatedCost,
    required this.isOverLimit,
    required this.isNearLimit,
    required this.requestCount,
  });

  @override
  String toString() {
    return 'TokenUsageStatistics(date: $date, usage: $totalTokens/${TokenUsageService.dailyTokenLimit}, percentage: ${usagePercentage.toStringAsFixed(1)}%, cost: \$${estimatedCost.toStringAsFixed(4)})';
  }
}
