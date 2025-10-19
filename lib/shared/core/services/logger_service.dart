import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// AIPet 전용 로깅 서비스
///
/// 개발/프로덕션 환경에 따른 안전한 로깅을 제공합니다.
/// 민감한 정보 노출을 방지하고 구조화된 로그를 생성합니다.
class LoggerService {
  static const String _tag = 'AIPet';

  /// 정보성 로그
  static void info(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final logData = data != null ? ' | Data: ${_sanitizeData(data)}' : '';
      developer.log('[$_tag] INFO: $message$logData', name: 'AIPet.Info');
    }
  }

  /// 경고 로그
  static void warning(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final logData = data != null ? ' | Data: ${_sanitizeData(data)}' : '';
      developer.log('[$_tag] WARNING: $message$logData', name: 'AIPet.Warning');
    }
  }

  /// 에러 로그
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    if (kDebugMode) {
      final logData = data != null ? ' | Data: ${_sanitizeData(data)}' : '';
      final errorInfo = error != null ? ' | Error: $error' : '';

      developer.log(
        '[$_tag] ERROR: $message$logData$errorInfo',
        name: 'AIPet.Error',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 디버그 로그 (개발 환경 전용)
  static void debug(String message, {Map<String, dynamic>? data}) {
    if (kDebugMode) {
      final logData = data != null ? ' | Data: ${_sanitizeData(data)}' : '';
      developer.log('[$_tag] DEBUG: $message$logData', name: 'AIPet.Debug');
    }
  }

  /// API 호출 로그
  static void api(
    String method,
    String url, {
    int? statusCode,
    Duration? duration,
    Map<String, dynamic>? requestData,
    bool isError = false,
  }) {
    if (kDebugMode) {
      final sanitizedUrl = _sanitizeUrl(url);
      final requestInfo = requestData != null
          ? ' | Request: ${_sanitizeData(requestData)}'
          : '';
      final statusInfo = statusCode != null ? ' | Status: $statusCode' : '';
      final durationInfo = duration != null
          ? ' | Duration: ${duration.inMilliseconds}ms'
          : '';

      final logLevel = isError ? 'ERROR' : 'INFO';
      developer.log(
        '[$_tag] API $logLevel: $method $sanitizedUrl$statusInfo$durationInfo$requestInfo',
        name: 'AIPet.API',
      );
    }
  }

  /// 네비게이션 로그
  static void navigation(
    String action,
    String route, {
    Map<String, dynamic>? params,
  }) {
    if (kDebugMode) {
      final paramsInfo = params != null
          ? ' | Params: ${_sanitizeData(params)}'
          : '';
      developer.log(
        '[$_tag] NAV: $action -> $route$paramsInfo',
        name: 'AIPet.Navigation',
      );
    }
  }

  /// 사용자 액션 로그
  static void userAction(String action, {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      final contextInfo = context != null
          ? ' | Context: ${_sanitizeData(context)}'
          : '';
      developer.log('[$_tag] USER: $action$contextInfo', name: 'AIPet.User');
    }
  }

  /// 민감한 데이터 sanitization
  static Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;

      // 민감한 키워드 검사
      if (_isSensitiveKey(key)) {
        sanitized[entry.key] = '***REDACTED***';
      } else if (value is String && _containsSensitiveData(value)) {
        sanitized[entry.key] = '***REDACTED***';
      } else if (value is Map<String, dynamic>) {
        sanitized[entry.key] = _sanitizeData(value);
      } else if (value is List) {
        sanitized[entry.key] = _sanitizeList(value);
      } else {
        sanitized[entry.key] = value;
      }
    }

    return sanitized;
  }

  /// 리스트 데이터 sanitization
  static List<dynamic> _sanitizeList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return _sanitizeData(item);
      } else if (item is String && _containsSensitiveData(item)) {
        return '***REDACTED***';
      }
      return item;
    }).toList();
  }

  /// URL sanitization (쿼리 파라미터에서 민감한 정보 제거)
  static String _sanitizeUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    final sanitizedParams = <String, String>{};
    uri.queryParameters.forEach((key, value) {
      if (_isSensitiveKey(key.toLowerCase())) {
        sanitizedParams[key] = '***REDACTED***';
      } else {
        sanitizedParams[key] = value;
      }
    });

    return uri.replace(queryParameters: sanitizedParams).toString();
  }

  /// 민감한 키 검사
  static bool _isSensitiveKey(String key) {
    const sensitiveKeys = {
      'password',
      'passwd',
      'pwd',
      'token',
      'key',
      'secret',
      'api_key',
      'apikey',
      'auth',
      'authorization',
      'bearer',
      'credit_card',
      'creditcard',
      'card_number',
      'ssn',
      'social_security',
      'phone',
      'email',
      'address',
      'location',
      'gps',
      'coordinate',
      'lat',
      'lng',
      'latitude',
      'longitude',
    };

    return sensitiveKeys.any((sensitive) => key.contains(sensitive));
  }

  /// 민감한 데이터 패턴 검사
  static bool _containsSensitiveData(String value) {
    // 이메일 패턴
    if (RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return true;

    // 전화번호 패턴
    if (RegExp(r'^\+?[\d\-\s\(\)]+$').hasMatch(value) && value.length > 8) {
      return true;
    }

    // 신용카드 번호 패턴
    if (RegExp(
      r'^\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}$',
    ).hasMatch(value)) {
      return true;
    }

    // JWT 토큰 패턴
    if (RegExp(
      r'^[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+$',
    ).hasMatch(value)) {
      return true;
    }

    return false;
  }
}

/// 레거시 print 구문 대체를 위한 확장 메서드
extension LegacyLoggingMigration on String {
  void logInfo() => LoggerService.info(this);
  void logWarning() => LoggerService.warning(this);
  void logError() => LoggerService.error(this);
  void logDebug() => LoggerService.debug(this);
}
