import 'dart:convert';

import 'package:aipet_frontend/shared/core/domain/result.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:flutter/foundation.dart';

/// 🔐 JWT 토큰 구조 검증 서비스
///
/// 기본 길이 검사를 넘어 실제 JWT 토큰 구조를 검증합니다.
/// 보안을 강화하고 잘못된 토큰 형식을 사전에 차단합니다.
class JwtValidationService {
  static const String _tag = 'JwtValidationService';

  /// JWT 토큰 구조 검증
  ///
  /// [token] 검증할 JWT 토큰
  /// [return] 검증 결과와 상세 정보
  static Result<JwtValidationResult> validateJwtStructure(String? token) {
    try {
      if (token == null || token.isEmpty) {
        return Result.failure('토큰이 제공되지 않았습니다');
      }

      // 1. 기본 형식 검증: JWT는 3개의 부분으로 구성 (header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) {
        if (kDebugMode) {
          LoggerService.debug('[$_tag] ❌ JWT 형식 오류: ${parts.length}개 부분 (3개 필요)');
        }
        return Result.failure('잘못된 JWT 형식: ${parts.length}개 부분 (3개 필요)');
      }

      // 2. 각 부분이 비어있지 않은지 확인
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isEmpty) {
          return Result.failure('JWT의 ${i + 1}번째 부분이 비어있습니다');
        }
      }

      // 3. Header 검증
      final headerResult = _validateJwtPart(parts[0], 'header');
      if (!headerResult.isSuccess) {
        return Result.failure(
          'Header 검증 실패: ${headerResult.error?.toString() ?? 'Unknown error'}',
        );
      }

      // 4. Payload 검증
      final payloadResult = _validateJwtPart(parts[1], 'payload');
      if (!payloadResult.isSuccess) {
        return Result.failure(
          'Payload 검증 실패: ${payloadResult.error?.toString() ?? 'Unknown error'}',
        );
      }

      // 5. Signature 검증 (길이 및 형식만)
      final signatureResult = _validateSignature(parts[2]);
      if (!signatureResult.isSuccess) {
        return Result.failure(
          'Signature 검증 실패: ${signatureResult.error?.toString() ?? 'Unknown error'}',
        );
      }

      // 6. Header 내용 검증
      final header = headerResult.dataOrNull!;
      if (!header.containsKey('alg') || !header.containsKey('typ')) {
        return Result.failure('Header에 필수 필드(alg, typ)가 없습니다');
      }

      if (header['typ'] != 'JWT') {
        return Result.failure('토큰 타입이 JWT가 아닙니다: ${header['typ']}');
      }

      // 7. Payload 내용 검증
      final payload = payloadResult.dataOrNull!;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // exp (만료 시간) 검증
      if (payload.containsKey('exp')) {
        final exp = payload['exp'];
        if (exp is int && exp < now) {
          return Result.failure('토큰이 만료되었습니다');
        }
      }

      // iat (발행 시간) 검증
      if (payload.containsKey('iat')) {
        final iat = payload['iat'];
        if (iat is int && iat > now + 300) {
          // 5분 허용 오차
          return Result.failure('토큰 발행 시간이 미래입니다');
        }
      }

      // nbf (유효 시작 시간) 검증
      if (payload.containsKey('nbf')) {
        final nbf = payload['nbf'];
        if (nbf is int && nbf > now) {
          return Result.failure('토큰이 아직 유효하지 않습니다');
        }
      }

      final validationResult = JwtValidationResult(
        isValid: true,
        header: header,
        payload: payload,
        algorithm: header['alg'] as String,
        tokenType: header['typ'] as String,
        issuer: payload['iss'] as String?,
        subject: payload['sub'] as String?,
        audience: payload['aud'] as String?,
        expirationTime: payload['exp'] is int
            ? DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000)
            : null,
        issuedAt: payload['iat'] is int
            ? DateTime.fromMillisecondsSinceEpoch(payload['iat'] * 1000)
            : null,
        notBefore: payload['nbf'] is int
            ? DateTime.fromMillisecondsSinceEpoch(payload['nbf'] * 1000)
            : null,
        estimatedSizeBytes: token.length,
        validationTimestamp: DateTime.now(),
      );

      if (kDebugMode) {
        LoggerService.debug(
          '[$_tag] ✅ JWT 구조 검증 성공 - 알고리즘: ${header['alg']}, 만료: ${validationResult.expirationTime}',
        );
      }

      return Result.success('JWT 구조 검증 성공', validationResult);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        LoggerService.debug('[$_tag] JWT 검증 중 예외 발생: $error\n$stackTrace');
      }
      return Result.failure('JWT 검증 중 오류 발생: $error');
    }
  }

  /// Firebase ID 토큰 특화 검증
  ///
  /// [token] Firebase ID 토큰
  /// [return] Firebase 토큰 검증 결과
  static Result<JwtValidationResult> validateFirebaseIdToken(String? token) {
    final basicResult = validateJwtStructure(token);
    if (!basicResult.isSuccess) {
      return basicResult;
    }

    final result = basicResult.dataOrNull!;

    // Firebase 특화 검증
    if (result.issuer?.contains('securetoken.google.com') != true) {
      return Result.failure('Firebase ID 토큰이 아닙니다 (잘못된 발행자)');
    }

    if (result.audience == null || result.audience!.isEmpty) {
      return Result.failure('Firebase ID 토큰에 audience가 없습니다');
    }

    // Firebase 전용 클레임 검증
    final authTime = result.payload['auth_time'];
    if (authTime == null) {
      return Result.failure('Firebase ID 토큰에 auth_time이 없습니다');
    }

    if (kDebugMode) {
      LoggerService.debug('[$_tag] ✅ Firebase ID 토큰 검증 성공');
    }

    return basicResult;
  }

  /// JWT 부분(Header/Payload) 검증 및 디코딩
  static Result<Map<String, dynamic>> _validateJwtPart(
    String part,
    String partName,
  ) {
    try {
      // Base64URL 디코딩
      String normalizedPart = part;

      // Base64URL에서 Base64로 변환
      switch (part.length % 4) {
        case 2:
          normalizedPart += '==';
          break;
        case 3:
          normalizedPart += '=';
          break;
      }

      normalizedPart = normalizedPart.replaceAll('-', '+').replaceAll('_', '/');

      final bytes = base64Decode(normalizedPart);
      final jsonString = utf8.decode(bytes);
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      if (decoded.isEmpty) {
        return Result.failure('$partName가 비어있습니다');
      }

      return Result.success('$partName 디코딩 성공', decoded);
    } catch (error) {
      return Result.failure('$partName 디코딩 실패: $error');
    }
  }

  /// JWT Signature 기본 검증
  static Result<bool> _validateSignature(String signature) {
    try {
      if (signature.isEmpty) {
        return Result.failure('Signature가 비어있습니다');
      }

      // Base64URL 문자 검증
      final validChars = RegExp(r'^[A-Za-z0-9_-]+$');
      if (!validChars.hasMatch(signature)) {
        return Result.failure('Signature에 유효하지 않은 문자가 포함되어 있습니다');
      }

      // 최소 길이 검증 (일반적인 signature는 최소 20자 이상)
      if (signature.length < 20) {
        return Result.failure('Signature가 너무 짧습니다 (${signature.length}자)');
      }

      return Result.success('Signature 기본 형식 검증 성공', true);
    } catch (error) {
      return Result.failure('Signature 검증 중 오류: $error');
    }
  }

  /// JWT 토큰 보안 등급 평가
  ///
  /// [validationResult] 검증된 JWT 결과
  /// [return] 보안 등급 정보
  static JwtSecurityLevel evaluateSecurityLevel(
    JwtValidationResult validationResult,
  ) {
    int score = 0;
    final issues = <String>[];

    // 알고리즘 보안성 점수
    switch (validationResult.algorithm) {
      case 'RS256':
      case 'RS384':
      case 'RS512':
      case 'ES256':
      case 'ES384':
      case 'ES512':
        score += 30;
        break;
      case 'HS256':
      case 'HS384':
      case 'HS512':
        score += 20;
        break;
      case 'none':
        score -= 50;
        issues.add('서명이 없는 토큰은 보안상 위험합니다');
        break;
      default:
        score += 10;
        issues.add('알려지지 않은 알고리즘: ${validationResult.algorithm}');
    }

    // 만료 시간 설정 여부
    if (validationResult.expirationTime != null) {
      score += 20;
      final remaining = validationResult.expirationTime!.difference(
        DateTime.now(),
      );
      if (remaining.inHours > 24) {
        score -= 10;
        issues.add('토큰 만료 시간이 너무 깁니다 (${remaining.inHours}시간)');
      }
    } else {
      score -= 30;
      issues.add('만료 시간이 설정되지 않았습니다');
    }

    // 발행자 및 수신자 설정
    if (validationResult.issuer != null) score += 10;
    if (validationResult.audience != null) score += 10;
    if (validationResult.subject != null) score += 5;

    // 토큰 크기 검증
    if (validationResult.estimatedSizeBytes > 8192) {
      score -= 10;
      issues.add('토큰 크기가 큽니다 (${validationResult.estimatedSizeBytes} 바이트)');
    }

    // 보안 등급 결정
    SecurityLevel level;
    if (score >= 80) {
      level = SecurityLevel.high;
    } else if (score >= 50) {
      level = SecurityLevel.medium;
    } else if (score >= 20) {
      level = SecurityLevel.low;
    } else {
      level = SecurityLevel.critical;
    }

    return JwtSecurityLevel(
      level: level,
      score: score,
      maxScore: 100,
      securityIssues: issues,
      recommendation: _getSecurityRecommendation(level, issues),
    );
  }

  static String _getSecurityRecommendation(
    SecurityLevel level,
    List<String> issues,
  ) {
    switch (level) {
      case SecurityLevel.high:
        return '토큰 보안 수준이 양호합니다';
      case SecurityLevel.medium:
        return '토큰 보안을 더 강화할 수 있습니다: ${issues.join(', ')}';
      case SecurityLevel.low:
        return '토큰 보안 수준이 낮습니다. 보안 설정을 검토하세요: ${issues.join(', ')}';
      case SecurityLevel.critical:
        return '심각한 보안 문제가 있습니다. 즉시 토큰 설정을 수정하세요: ${issues.join(', ')}';
    }
  }
}

/// JWT 검증 결과 데이터 클래스
class JwtValidationResult {
  final bool isValid;
  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
  final String algorithm;
  final String tokenType;
  final String? issuer;
  final String? subject;
  final String? audience;
  final DateTime? expirationTime;
  final DateTime? issuedAt;
  final DateTime? notBefore;
  final int estimatedSizeBytes;
  final DateTime validationTimestamp;

  const JwtValidationResult({
    required this.isValid,
    required this.header,
    required this.payload,
    required this.algorithm,
    required this.tokenType,
    this.issuer,
    this.subject,
    this.audience,
    this.expirationTime,
    this.issuedAt,
    this.notBefore,
    required this.estimatedSizeBytes,
    required this.validationTimestamp,
  });

  @override
  String toString() {
    return 'JwtValidationResult('
        'isValid: $isValid, '
        'algorithm: $algorithm, '
        'issuer: $issuer, '
        'expirationTime: $expirationTime'
        ')';
  }
}

/// JWT 보안 등급 평가 결과
class JwtSecurityLevel {
  final SecurityLevel level;
  final int score;
  final int maxScore;
  final List<String> securityIssues;
  final String recommendation;

  const JwtSecurityLevel({
    required this.level,
    required this.score,
    required this.maxScore,
    required this.securityIssues,
    required this.recommendation,
  });

  double get scorePercentage => (score / maxScore * 100).clamp(0.0, 100.0);

  @override
  String toString() {
    return 'JwtSecurityLevel(level: $level, score: $score/$maxScore, issues: ${securityIssues.length})';
  }
}

/// 보안 등급 열거형
enum SecurityLevel {
  critical('Critical'),
  low('Low'),
  medium('Medium'),
  high('High');

  const SecurityLevel(this.displayName);
  final String displayName;
}
