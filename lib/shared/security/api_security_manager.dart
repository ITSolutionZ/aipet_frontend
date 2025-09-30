import 'dart:async';

import 'package:flutter/foundation.dart';

/// 🛡️ API 보안 관리 시스템
///
/// API 호출에 대한 Rate Limiting, DDoS 방어, 보안 헤더 검증을 제공합니다.
class ApiSecurityManager {
  static ApiSecurityManager? _instance;
  static ApiSecurityManager get instance => _instance ??= ApiSecurityManager._();

  ApiSecurityManager._();

  // Rate Limiting 설정
  final Map<String, List<DateTime>> _requestHistory = {};
  final Map<String, int> _requestCounts = {};

  // DDoS 방어 설정
  static const int _maxRequestsPerMinute = 60;
  static const int _maxRequestsPerHour = 1000;
  static const int _maxConcurrentRequests = 10;

  // 현재 활성 요청 수
  int _activeRequests = 0;

  // 보안 헤더 검증
  static const Map<String, String> _requiredSecurityHeaders = {
    'Content-Type': 'application/json',
    'User-Agent': 'AiPetApp/1.0',
    'X-Requested-With': 'XMLHttpRequest',
  };

  /// API 요청 보안 검증
  Future<ApiSecurityResult> validateRequest({
    required String endpoint,
    required Map<String, String> headers,
    String? clientId,
  }) async {
    try {
      // 1. Rate Limiting 검증
      final rateLimitResult = await _validateRateLimit(clientId ?? 'anonymous');
      if (!rateLimitResult.isAllowed) {
        return ApiSecurityResult.blocked(
          'Rate limit exceeded: ${rateLimitResult.reason}',
          ApiSecurityViolationType.rateLimit,
        );
      }

      // 2. 동시 요청 수 검증
      if (_activeRequests >= _maxConcurrentRequests) {
        return ApiSecurityResult.blocked(
          'Too many concurrent requests',
          ApiSecurityViolationType.concurrentLimit,
        );
      }

      // 3. 보안 헤더 검증
      final headerResult = _validateSecurityHeaders(headers);
      if (!headerResult.isValid) {
        return ApiSecurityResult.blocked(
          'Invalid security headers: ${headerResult.reason}',
          ApiSecurityViolationType.invalidHeaders,
        );
      }

      // 4. 엔드포인트 보안 검증
      final endpointResult = _validateEndpoint(endpoint);
      if (!endpointResult.isSecure) {
        return ApiSecurityResult.blocked(
          'Endpoint security violation: ${endpointResult.reason}',
          ApiSecurityViolationType.endpointViolation,
        );
      }

      // 요청 허용
      _activeRequests++;
      _recordRequest(clientId ?? 'anonymous');

      return ApiSecurityResult.allowed();
    } catch (e) {
      return ApiSecurityResult.blocked(
        'Security validation error: ${e.toString()}',
        ApiSecurityViolationType.validationError,
      );
    }
  }

  /// 요청 완료 처리
  void completeRequest() {
    if (_activeRequests > 0) {
      _activeRequests--;
    }
  }

  /// Rate Limiting 검증
  Future<RateLimitResult> _validateRateLimit(String clientId) async {
    final now = DateTime.now();
    final clientHistory = _requestHistory[clientId] ?? [];

    // 1분 이내 요청 수 확인
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    final recentRequests = clientHistory.where((time) => time.isAfter(oneMinuteAgo)).length;

    if (recentRequests >= _maxRequestsPerMinute) {
      return RateLimitResult.exceeded('Too many requests per minute');
    }

    // 1시간 이내 요청 수 확인
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    final hourlyRequests = clientHistory.where((time) => time.isAfter(oneHourAgo)).length;

    if (hourlyRequests >= _maxRequestsPerHour) {
      return RateLimitResult.exceeded('Too many requests per hour');
    }

    return RateLimitResult.allowed();
  }

  /// 보안 헤더 검증
  SecurityHeaderResult _validateSecurityHeaders(Map<String, String> headers) {
    for (final entry in _requiredSecurityHeaders.entries) {
      final headerValue = headers[entry.key];
      if (headerValue == null || headerValue.isEmpty) {
        return SecurityHeaderResult.invalid('Missing required header: ${entry.key}');
      }

      // Content-Type 검증
      if (entry.key == 'Content-Type' && !headerValue.contains('application/json')) {
        return SecurityHeaderResult.invalid('Invalid Content-Type: $headerValue');
      }
    }

    // 추가 보안 헤더 검증
    if (headers.containsKey('X-Forwarded-For') || headers.containsKey('X-Real-IP')) {
      return SecurityHeaderResult.invalid('Proxied request detected');
    }

    return SecurityHeaderResult.valid();
  }

  /// 엔드포인트 보안 검증
  EndpointSecurityResult _validateEndpoint(String endpoint) {
    // 금지된 패턴 검증
    final forbiddenPatterns = [
      r'\.\./', // Directory traversal
      r'<script', // XSS
      r'javascript:', // XSS
      r'data:', // Data URI
      r'vbscript:', // VBScript
    ];

    for (final pattern in forbiddenPatterns) {
      if (endpoint.toLowerCase().contains(RegExp(pattern, caseSensitive: false))) {
        return EndpointSecurityResult.insecure('Forbidden pattern detected: $pattern');
      }
    }

    // SQL Injection 패턴 검증
    final sqlPatterns = [
      r'union\s+select',
      r'drop\s+table',
      r'delete\s+from',
      r'insert\s+into',
      r'update\s+set',
    ];

    for (final pattern in sqlPatterns) {
      if (endpoint.toLowerCase().contains(RegExp(pattern, caseSensitive: false))) {
        return EndpointSecurityResult.insecure('SQL injection pattern detected: $pattern');
      }
    }

    return EndpointSecurityResult.secure();
  }

  /// 요청 기록
  void _recordRequest(String clientId) {
    final now = DateTime.now();
    _requestHistory[clientId] = _requestHistory[clientId] ?? [];
    _requestHistory[clientId]!.add(now);

    // 오래된 기록 정리 (1시간 이상)
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    _requestHistory[clientId]!.removeWhere((time) => time.isBefore(oneHourAgo));

    // 요청 수 증가
    _requestCounts[clientId] = (_requestCounts[clientId] ?? 0) + 1;
  }

  /// 보안 통계 생성
  ApiSecurityStats generateStats() {
    final totalRequests = _requestCounts.values.fold(0, (sum, count) => sum + count);
    final uniqueClients = _requestHistory.keys.length;
    final averageRequestsPerClient = uniqueClients > 0 ? totalRequests / uniqueClients : 0;

    return ApiSecurityStats(
      totalRequests: totalRequests,
      uniqueClients: uniqueClients,
      activeRequests: _activeRequests,
      averageRequestsPerClient: averageRequestsPerClient.toDouble(),
      topClients: _getTopClients(),
    );
  }

  /// 상위 클라이언트 목록
  List<ClientStats> _getTopClients() {
    return _requestCounts.entries
        .map(
          (entry) => ClientStats(
            clientId: entry.key,
            requestCount: entry.value,
            lastRequest: _requestHistory[entry.key]?.last,
          ),
        )
        .toList()
      ..sort((a, b) => b.requestCount.compareTo(a.requestCount));
  }

  /// 의심스러운 활동 탐지
  List<SuspiciousActivity> detectSuspiciousActivity() {
    final activities = <SuspiciousActivity>[];

    for (final entry in _requestCounts.entries) {
      final clientId = entry.key;
      final clientHistory = _requestHistory[clientId] ?? [];

      // 1분당 60회 이상 요청
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      final recentRequests = clientHistory.where((time) => time.isAfter(oneMinuteAgo)).length;

      if (recentRequests > _maxRequestsPerMinute) {
        activities.add(
          SuspiciousActivity(
            clientId: clientId,
            type: SuspiciousActivityType.highFrequency,
            severity: SuspiciousActivitySeverity.high,
            description: 'High frequency requests detected: $recentRequests requests in 1 minute',
            timestamp: now,
          ),
        );
      }

      // 1시간당 1000회 이상 요청
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final hourlyRequests = clientHistory.where((time) => time.isAfter(oneHourAgo)).length;

      if (hourlyRequests > _maxRequestsPerHour) {
        activities.add(
          SuspiciousActivity(
            clientId: clientId,
            type: SuspiciousActivityType.excessiveRequests,
            severity: SuspiciousActivitySeverity.critical,
            description: 'Excessive requests detected: $hourlyRequests requests in 1 hour',
            timestamp: now,
          ),
        );
      }
    }

    return activities;
  }

  /// 보안 로그 출력 (디버그용)
  void printSecurityLog() {
    if (!kDebugMode) return;

    final stats = generateStats();
    final suspiciousActivities = detectSuspiciousActivity();

    debugPrint('=== API Security Report ===');
    debugPrint('Total Requests: ${stats.totalRequests}');
    debugPrint('Unique Clients: ${stats.uniqueClients}');
    debugPrint('Active Requests: ${stats.activeRequests}');
    debugPrint('Avg Requests/Client: ${stats.averageRequestsPerClient.toStringAsFixed(2)}');
    debugPrint('Suspicious Activities: ${suspiciousActivities.length}');

    if (suspiciousActivities.isNotEmpty) {
      debugPrint('\nSuspicious Activities:');
      for (final activity in suspiciousActivities) {
        debugPrint('  ${activity.type.name}: ${activity.description}');
      }
    }
  }
}

/// API 보안 결과
class ApiSecurityResult {
  final bool isAllowed;
  final String? reason;
  final ApiSecurityViolationType? violationType;

  const ApiSecurityResult._({required this.isAllowed, this.reason, this.violationType});

  factory ApiSecurityResult.allowed() => const ApiSecurityResult._(isAllowed: true);

  factory ApiSecurityResult.blocked(String reason, ApiSecurityViolationType type) =>
      ApiSecurityResult._(isAllowed: false, reason: reason, violationType: type);
}

/// Rate Limiting 결과
class RateLimitResult {
  final bool isAllowed;
  final String? reason;

  const RateLimitResult._({required this.isAllowed, this.reason});

  factory RateLimitResult.allowed() => const RateLimitResult._(isAllowed: true);
  factory RateLimitResult.exceeded(String reason) =>
      RateLimitResult._(isAllowed: false, reason: reason);
}

/// 보안 헤더 결과
class SecurityHeaderResult {
  final bool isValid;
  final String? reason;

  const SecurityHeaderResult._({required this.isValid, this.reason});

  factory SecurityHeaderResult.valid() => const SecurityHeaderResult._(isValid: true);
  factory SecurityHeaderResult.invalid(String reason) =>
      SecurityHeaderResult._(isValid: false, reason: reason);
}

/// 엔드포인트 보안 결과
class EndpointSecurityResult {
  final bool isSecure;
  final String? reason;

  const EndpointSecurityResult._({required this.isSecure, this.reason});

  factory EndpointSecurityResult.secure() => const EndpointSecurityResult._(isSecure: true);
  factory EndpointSecurityResult.insecure(String reason) =>
      EndpointSecurityResult._(isSecure: false, reason: reason);
}

/// API 보안 통계
class ApiSecurityStats {
  final int totalRequests;
  final int uniqueClients;
  final int activeRequests;
  final double averageRequestsPerClient;
  final List<ClientStats> topClients;

  const ApiSecurityStats({
    required this.totalRequests,
    required this.uniqueClients,
    required this.activeRequests,
    required this.averageRequestsPerClient,
    required this.topClients,
  });
}

/// 클라이언트 통계
class ClientStats {
  final String clientId;
  final int requestCount;
  final DateTime? lastRequest;

  const ClientStats({required this.clientId, required this.requestCount, this.lastRequest});
}

/// 의심스러운 활동
class SuspiciousActivity {
  final String clientId;
  final SuspiciousActivityType type;
  final SuspiciousActivitySeverity severity;
  final String description;
  final DateTime timestamp;

  const SuspiciousActivity({
    required this.clientId,
    required this.type,
    required this.severity,
    required this.description,
    required this.timestamp,
  });
}

/// API 보안 위반 타입
enum ApiSecurityViolationType {
  rateLimit,
  concurrentLimit,
  invalidHeaders,
  endpointViolation,
  validationError,
}

/// 의심스러운 활동 타입
enum SuspiciousActivityType { highFrequency, excessiveRequests, suspiciousPattern }

/// 의심스러운 활동 심각도
enum SuspiciousActivitySeverity { low, medium, high, critical }
