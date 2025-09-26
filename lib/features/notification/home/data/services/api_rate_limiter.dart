import 'dart:math';

import 'package:aipet_frontend/shared/foundation/result/app_result.dart';
import 'package:flutter/foundation.dart';

/// 🚦 향상된 API Rate Limiting 서비스
///
/// Token Bucket 알고리즘과 Sliding Window를 결합하여 API 남용을 방지합니다.
/// 여러 시간 단위(분당, 시간당, 일당)에서 요청을 제한하고 모니터링합니다.
class ApiRateLimiter {
  static const String _tag = 'ApiRateLimiter';

  // Rate Limit 설정 (OpenWeatherMap One Call API 3.0 기준)
  static const int _requestsPerMinute = 60; // 분당 60회
  static const int _requestsPerHour = 1000; // 시간당 1000회
  static const int _requestsPerDay = 10000; // 일당 10000회

  // Burst 허용량 (단기간 집중 요청 허용)
  static const int _burstTokens = 10;

  // 백오프 설정
  static const Duration _baseBackoffDuration = Duration(seconds: 5);
  static const int _maxBackoffMultiplier = 32; // 최대 2^5 = 32배

  // 상태 관리
  static final Map<String, ApiLimiterState> _limiters = {};
  static final Map<String, List<DateTime>> _requestHistory = {};
  static final Map<String, int> _backoffMultiplier = {};
  static final Map<String, DateTime?> _lastBackoffTime = {};

  /// API 요청 허용 여부 확인 및 토큰 소비
  ///
  /// [apiKey] API 식별자 (예: 'weather', 'openai')
  /// [priority] 요청 우선순위 (높을수록 우선)
  /// [return] 요청 허용 여부와 상세 정보
  static Result<RateLimitDecision> checkRateLimit(
    String apiKey, {
    RequestPriority priority = RequestPriority.normal,
    bool isUserTriggered = false,
  }) {
    try {
      final now = DateTime.now();

      // 리미터 상태 초기화
      _limiters[apiKey] ??= ApiLimiterState(
        tokensRemaining: _burstTokens,
        lastRefillTime: now,
      );

      _requestHistory[apiKey] ??= [];

      final state = _limiters[apiKey]!;
      final history = _requestHistory[apiKey]!;

      // 1. 백오프 상태 확인
      final backoffResult = _checkBackoffStatus(apiKey, now);
      if (!backoffResult.isSuccess) {
        return backoffResult;
      }

      // 2. Token Bucket 알고리즘 적용 (버스트 제어)
      final tokenResult = _checkTokenBucket(state, now, priority);
      if (!tokenResult.isSuccess) {
        _incrementBackoff(apiKey, now);
        return tokenResult;
      }

      // 3. Sliding Window 알고리즘 적용 (시간 기반 제한)
      final slidingResult = _checkSlidingWindow(history, now, isUserTriggered);
      if (!slidingResult.isSuccess) {
        _incrementBackoff(apiKey, now);
        return slidingResult;
      }

      // 4. 요청 허용 - 토큰 소비 및 히스토리 기록
      state.tokensRemaining = max(0, state.tokensRemaining - 1);
      history.add(now);

      // 히스토리 정리 (24시간 이전 데이터 제거)
      _cleanupHistory(history, now);

      // 백오프 리셋
      _backoffMultiplier[apiKey] = 1;

      final decision = RateLimitDecision(
        allowed: true,
        tokensRemaining: state.tokensRemaining,
        retryAfter: null,
        quotaStatus: _calculateQuotaStatus(history, now),
        reason: 'Request allowed',
        nextRefillTime: _calculateNextRefillTime(state, now),
        currentBackoff: Duration.zero,
        priority: priority,
        requestTimestamp: now,
      );

      if (kDebugMode) {
        debugPrint(
          '[$_tag] ✅ Request allowed for $apiKey - Tokens: ${state.tokensRemaining}, Quota: ${decision.quotaStatus}',
        );
      }

      return ResultFactory.success(decision, 'Request allowed');
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[$_tag] Error in rate limiting: $error\n$stackTrace');
      }
      return ResultFactory.failure('Rate limiting error: $error');
    }
  }

  /// 백오프 상태 확인
  static Result<RateLimitDecision> _checkBackoffStatus(
    String apiKey,
    DateTime now,
  ) {
    final lastBackoff = _lastBackoffTime[apiKey];
    final multiplier = _backoffMultiplier[apiKey] ?? 1;

    if (lastBackoff != null) {
      final backoffDuration = Duration(
        milliseconds: _baseBackoffDuration.inMilliseconds * multiplier,
      );
      final backoffEndTime = lastBackoff.add(backoffDuration);

      if (now.isBefore(backoffEndTime)) {
        final retryAfter = backoffEndTime.difference(now);

        final decision = RateLimitDecision(
          allowed: false,
          tokensRemaining: 0,
          retryAfter: retryAfter,
          quotaStatus: const QuotaStatus(
            minuteUsage: 0,
            hourUsage: 0,
            dayUsage: 0,
            minuteLimit: _requestsPerMinute,
            hourLimit: _requestsPerHour,
            dayLimit: _requestsPerDay,
          ),
          reason: 'In backoff period (attempt $multiplier)',
          nextRefillTime: null,
          currentBackoff: retryAfter,
          priority: RequestPriority.normal,
          requestTimestamp: now,
        );

        return ResultFactory.failure('Request blocked - backoff period');
      }
    }

    return ResultFactory.success(
      RateLimitDecision(
        allowed: true,
        tokensRemaining: 0,
        retryAfter: null,
        quotaStatus: QuotaStatus.empty(),
        reason: 'Backoff check passed',
        nextRefillTime: null,
        currentBackoff: Duration.zero,
        priority: RequestPriority.normal,
        requestTimestamp: now,
      ),
      'Backoff check passed',
    );
  }

  /// Token Bucket 알고리즘 체크
  static Result<RateLimitDecision> _checkTokenBucket(
    ApiLimiterState state,
    DateTime now,
    RequestPriority priority,
  ) {
    // 토큰 리필 (1초마다 1개씩)
    final timeSinceLastRefill = now.difference(state.lastRefillTime);
    final tokensToAdd = (timeSinceLastRefill.inSeconds * 0.5)
        .floor(); // 더 보수적으로

    if (tokensToAdd > 0) {
      state.tokensRemaining = min(
        _burstTokens,
        state.tokensRemaining + tokensToAdd,
      );
      state.lastRefillTime = now;
    }

    // 우선순위에 따른 토큰 소비량 조정
    final tokensRequired = priority == RequestPriority.high
        ? 1
        : priority == RequestPriority.low
        ? 2
        : 1;

    if (state.tokensRemaining < tokensRequired) {
      final nextRefillTime = state.lastRefillTime.add(
        Duration(seconds: (tokensRequired / 0.5).ceil()),
      );
      final retryAfter = nextRefillTime.difference(now);

      final decision = RateLimitDecision(
        allowed: false,
        tokensRemaining: state.tokensRemaining,
        retryAfter: retryAfter,
        quotaStatus: QuotaStatus.empty(),
        reason:
            'Insufficient tokens (need $tokensRequired, have ${state.tokensRemaining})',
        nextRefillTime: nextRefillTime,
        currentBackoff: Duration.zero,
        priority: priority,
        requestTimestamp: now,
      );

      if (kDebugMode) {
        debugPrint(
          '[$_tag] 🚫 Token bucket limit reached - retry in ${retryAfter.inSeconds}s',
        );
      }

      return ResultFactory.failure('Token bucket limit reached');
    }

    return ResultFactory.success(
      RateLimitDecision(
        allowed: true,
        tokensRemaining: state.tokensRemaining,
        retryAfter: null,
        quotaStatus: QuotaStatus.empty(),
        reason: 'Token bucket check passed',
        nextRefillTime: null,
        currentBackoff: Duration.zero,
        priority: priority,
        requestTimestamp: now,
      ),
      'Token bucket check passed',
    );
  }

  /// Sliding Window 알고리즘 체크
  static Result<RateLimitDecision> _checkSlidingWindow(
    List<DateTime> history,
    DateTime now,
    bool isUserTriggered,
  ) {
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    final oneDayAgo = now.subtract(const Duration(days: 1));

    final minuteRequests = history
        .where((time) => time.isAfter(oneMinuteAgo))
        .length;
    final hourRequests = history
        .where((time) => time.isAfter(oneHourAgo))
        .length;
    final dayRequests = history.where((time) => time.isAfter(oneDayAgo)).length;

    final quotaStatus = QuotaStatus(
      minuteUsage: minuteRequests,
      hourUsage: hourRequests,
      dayUsage: dayRequests,
      minuteLimit: _requestsPerMinute,
      hourLimit: _requestsPerHour,
      dayLimit: _requestsPerDay,
    );

    // 사용자 트리거 요청은 더 관대한 제한 적용
    final minuteLimit = isUserTriggered
        ? _requestsPerMinute + 10
        : _requestsPerMinute;

    // 제한 확인
    String? limitExceeded;
    Duration? retryAfter;

    if (minuteRequests >= minuteLimit) {
      limitExceeded = 'Minute limit exceeded ($minuteRequests/$minuteLimit)';
      retryAfter = Duration(seconds: 60 - DateTime.now().second);
    } else if (hourRequests >= _requestsPerHour) {
      limitExceeded = 'Hour limit exceeded ($hourRequests/$_requestsPerHour)';
      retryAfter = Duration(minutes: 60 - DateTime.now().minute);
    } else if (dayRequests >= _requestsPerDay) {
      limitExceeded = 'Day limit exceeded ($dayRequests/$_requestsPerDay)';
      retryAfter = Duration(hours: 24 - DateTime.now().hour);
    }

    if (limitExceeded != null) {
      final decision = RateLimitDecision(
        allowed: false,
        tokensRemaining: 0,
        retryAfter: retryAfter,
        quotaStatus: quotaStatus,
        reason: limitExceeded,
        nextRefillTime: null,
        currentBackoff: Duration.zero,
        priority: RequestPriority.normal,
        requestTimestamp: now,
      );

      if (kDebugMode) {
        debugPrint('[$_tag] 🚫 Sliding window limit: $limitExceeded');
      }

      return ResultFactory.failure(limitExceeded);
    }

    return ResultFactory.success(
      RateLimitDecision(
        allowed: true,
        tokensRemaining: 0,
        retryAfter: null,
        quotaStatus: quotaStatus,
        reason: 'Sliding window check passed',
        nextRefillTime: null,
        currentBackoff: Duration.zero,
        priority: RequestPriority.normal,
        requestTimestamp: now,
      ),
      'Sliding window check passed',
    );
  }

  /// 백오프 증가
  static void _incrementBackoff(String apiKey, DateTime now) {
    final currentMultiplier = _backoffMultiplier[apiKey] ?? 1;
    _backoffMultiplier[apiKey] = min(
      _maxBackoffMultiplier,
      currentMultiplier * 2,
    );
    _lastBackoffTime[apiKey] = now;

    if (kDebugMode) {
      debugPrint(
        '[$_tag] 🔄 Backoff increased for $apiKey: ${_backoffMultiplier[apiKey]}x',
      );
    }
  }

  /// 히스토리 정리
  static void _cleanupHistory(List<DateTime> history, DateTime now) {
    final cutoff = now.subtract(const Duration(days: 1));
    history.removeWhere((time) => time.isBefore(cutoff));
  }

  /// 쿼터 상태 계산
  static QuotaStatus _calculateQuotaStatus(
    List<DateTime> history,
    DateTime now,
  ) {
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    final oneDayAgo = now.subtract(const Duration(days: 1));

    return QuotaStatus(
      minuteUsage: history.where((time) => time.isAfter(oneMinuteAgo)).length,
      hourUsage: history.where((time) => time.isAfter(oneHourAgo)).length,
      dayUsage: history.where((time) => time.isAfter(oneDayAgo)).length,
      minuteLimit: _requestsPerMinute,
      hourLimit: _requestsPerHour,
      dayLimit: _requestsPerDay,
    );
  }

  /// 다음 토큰 리필 시간 계산
  static DateTime? _calculateNextRefillTime(
    ApiLimiterState state,
    DateTime now,
  ) {
    if (state.tokensRemaining >= _burstTokens) return null;

    final secondsUntilRefill = ((_burstTokens - state.tokensRemaining) / 0.5)
        .ceil();
    return now.add(Duration(seconds: secondsUntilRefill));
  }

  /// API별 통계 조회
  static ApiRateLimitStats getStats(String apiKey) {
    final history = _requestHistory[apiKey] ?? [];
    final now = DateTime.now();

    return ApiRateLimitStats(
      apiKey: apiKey,
      totalRequests: history.length,
      quotaStatus: _calculateQuotaStatus(history, now),
      tokensRemaining: _limiters[apiKey]?.tokensRemaining ?? _burstTokens,
      currentBackoff: _backoffMultiplier[apiKey] ?? 1,
      lastRequestTime: history.isNotEmpty ? history.last : null,
      averageRequestsPerMinute: _calculateAverageRpm(history, now),
      peakRequestsPerMinute: _calculatePeakRpm(history, now),
    );
  }

  /// 모든 API 통계 조회
  static Map<String, ApiRateLimitStats> getAllStats() {
    final allStats = <String, ApiRateLimitStats>{};

    for (final apiKey in {..._limiters.keys, ..._requestHistory.keys}) {
      allStats[apiKey] = getStats(apiKey);
    }

    return allStats;
  }

  /// 특정 API의 모든 상태 리셋
  static void resetApiLimiter(String apiKey) {
    _limiters.remove(apiKey);
    _requestHistory.remove(apiKey);
    _backoffMultiplier.remove(apiKey);
    _lastBackoffTime.remove(apiKey);

    if (kDebugMode) {
      debugPrint('[$_tag] 🔄 Reset rate limiter for $apiKey');
    }
  }

  /// 모든 API 상태 리셋
  static void resetAllLimiters() {
    _limiters.clear();
    _requestHistory.clear();
    _backoffMultiplier.clear();
    _lastBackoffTime.clear();

    if (kDebugMode) {
      debugPrint('[$_tag] 🔄 Reset all rate limiters');
    }
  }

  // 내부 헬퍼 메서드들
  static double _calculateAverageRpm(List<DateTime> history, DateTime now) {
    if (history.isEmpty) return 0.0;

    final oneHourAgo = now.subtract(const Duration(hours: 1));
    final recentRequests = history
        .where((time) => time.isAfter(oneHourAgo))
        .length;

    return recentRequests / 60.0; // 시간당 요청을 분당으로 변환
  }

  static int _calculatePeakRpm(List<DateTime> history, DateTime now) {
    if (history.isEmpty) return 0;

    int peakRpm = 0;
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    // 1분 단위로 윈도우를 슬라이드하며 최대값 찾기
    for (int i = 0; i < 60; i++) {
      final windowStart = oneHourAgo.add(Duration(minutes: i));
      final windowEnd = windowStart.add(const Duration(minutes: 1));

      final requestsInWindow = history
          .where(
            (time) => time.isAfter(windowStart) && time.isBefore(windowEnd),
          )
          .length;

      peakRpm = max(peakRpm, requestsInWindow);
    }

    return peakRpm;
  }
}

/// Rate Limiter 상태
class ApiLimiterState {
  int tokensRemaining;
  DateTime lastRefillTime;

  ApiLimiterState({
    required this.tokensRemaining,
    required this.lastRefillTime,
  });
}

/// Rate Limit 결정 결과
class RateLimitDecision {
  final bool allowed;
  final int tokensRemaining;
  final Duration? retryAfter;
  final QuotaStatus quotaStatus;
  final String reason;
  final DateTime? nextRefillTime;
  final Duration currentBackoff;
  final RequestPriority priority;
  final DateTime requestTimestamp;

  const RateLimitDecision({
    required this.allowed,
    required this.tokensRemaining,
    required this.retryAfter,
    required this.quotaStatus,
    required this.reason,
    required this.nextRefillTime,
    required this.currentBackoff,
    required this.priority,
    required this.requestTimestamp,
  });

  @override
  String toString() {
    return 'RateLimitDecision('
        'allowed: $allowed, '
        'tokens: $tokensRemaining, '
        'retryAfter: ${retryAfter?.inSeconds}s, '
        'reason: $reason'
        ')';
  }
}

/// 쿼터 상태 정보
class QuotaStatus {
  final int minuteUsage;
  final int hourUsage;
  final int dayUsage;
  final int minuteLimit;
  final int hourLimit;
  final int dayLimit;

  const QuotaStatus({
    required this.minuteUsage,
    required this.hourUsage,
    required this.dayUsage,
    required this.minuteLimit,
    required this.hourLimit,
    required this.dayLimit,
  });

  factory QuotaStatus.empty() {
    return const QuotaStatus(
      minuteUsage: 0,
      hourUsage: 0,
      dayUsage: 0,
      minuteLimit: 0,
      hourLimit: 0,
      dayLimit: 0,
    );
  }

  double get minuteUsagePercent =>
      minuteLimit > 0 ? minuteUsage / minuteLimit : 0.0;
  double get hourUsagePercent => hourLimit > 0 ? hourUsage / hourLimit : 0.0;
  double get dayUsagePercent => dayLimit > 0 ? dayUsage / dayLimit : 0.0;

  bool get isNearMinuteLimit => minuteUsagePercent >= 0.8;
  bool get isNearHourLimit => hourUsagePercent >= 0.8;
  bool get isNearDayLimit => dayUsagePercent >= 0.8;

  @override
  String toString() {
    return 'QuotaStatus('
        'min: $minuteUsage/$minuteLimit(${(minuteUsagePercent * 100).toInt()}%), '
        'hour: $hourUsage/$hourLimit(${(hourUsagePercent * 100).toInt()}%), '
        'day: $dayUsage/$dayLimit(${(dayUsagePercent * 100).toInt()}%)'
        ')';
  }
}

/// API Rate Limit 통계
class ApiRateLimitStats {
  final String apiKey;
  final int totalRequests;
  final QuotaStatus quotaStatus;
  final int tokensRemaining;
  final int currentBackoff;
  final DateTime? lastRequestTime;
  final double averageRequestsPerMinute;
  final int peakRequestsPerMinute;

  const ApiRateLimitStats({
    required this.apiKey,
    required this.totalRequests,
    required this.quotaStatus,
    required this.tokensRemaining,
    required this.currentBackoff,
    required this.lastRequestTime,
    required this.averageRequestsPerMinute,
    required this.peakRequestsPerMinute,
  });

  @override
  String toString() {
    return 'ApiRateLimitStats('
        'api: $apiKey, '
        'total: $totalRequests, '
        'avgRPM: ${averageRequestsPerMinute.toStringAsFixed(1)}, '
        'peakRPM: $peakRequestsPerMinute, '
        'backoff: ${currentBackoff}x'
        ')';
  }
}

/// 요청 우선순위
enum RequestPriority {
  low('Low'),
  normal('Normal'),
  high('High'),
  critical('Critical');

  const RequestPriority(this.displayName);
  final String displayName;
}
