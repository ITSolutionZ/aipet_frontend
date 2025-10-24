import 'dart:convert';

import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:aipet_frontend/shared/core/services/auth_token_repository.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/domain.dart';
import 'token_storage_service.dart';

/// [AuthTokenRepository] 구현체로서 기존 [TokenStorageService]를 래핑합니다.
class TokenStorageAuthTokenRepository implements AuthTokenRepository {
  const TokenStorageAuthTokenRepository();

  @override
  Future<AuthTokenBundle?> getToken() async {
    final token = await TokenStorageService.getToken();
    if (token == null) {
      return null;
    }

    return AuthTokenBundle(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      tokenType: token.tokenType,
      expiresAt: token.expiresAt,
    );
  }

  @override
  Future<void> clearToken() {
    return TokenStorageService.clearToken();
  }

  /// 토큰 갱신 (자동 갱신 로직 포함)
  ///
  /// [refreshToken] 갱신할 리프레시 토큰
  ///
  /// Returns: 새로운 토큰 번들 또는 null (갱신 실패 시)
  @override
  Future<AuthTokenBundle?> refreshToken(String refreshToken) async {
    try {
      // 실제 백엔드 API 호출로 토큰 갱신
      final response = await http.post(
        Uri.parse('${AppConfig.current.apiBaseUrl}/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
          'Accept': 'application/json',
        },
        body: json.encode({
          'refreshToken': refreshToken,
          'clientType': 'mobile',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // 응답 데이터 검증
        final accessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;
        final expiresIn = data['expiresIn'] as int? ?? 3600; // 기본 1시간

        if (accessToken == null || accessToken.isEmpty) {
          await TokenStorageService.clearToken();
          return null;
        }

        final authToken = AuthToken(
          accessToken: accessToken,
          refreshToken: newRefreshToken ?? refreshToken,
          expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
          tokenType: data['tokenType'] as String? ?? 'Bearer',
        );

        // 새 토큰 저장
        await TokenStorageService.saveToken(authToken);

        if (kDebugMode) {
          LoggerService.debug('토큰 갱신 완료 (만료: ${authToken.expiresAt.toIso8601String()})');
        }

        return AuthTokenBundle(
          accessToken: authToken.accessToken,
          refreshToken: authToken.refreshToken,
          tokenType: authToken.tokenType,
          expiresAt: authToken.expiresAt,
        );
      } else if (response.statusCode == 401) {
        // Refresh token이 만료된 경우
        await TokenStorageService.clearToken();
        if (kDebugMode) {
          LoggerService.debug('Refresh token 만료됨 - 재로그인 필요');
        }
        return null;
      } else {
        // 기타 서버 오류
        final errorData = json.decode(response.body) as Map<String, dynamic>?;
        final errorMessage = errorData?['message'] ?? 'Token refresh failed';
        throw Exception('Token refresh failed: $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('토큰 갱신 실패: $e');
      }

      // 갱신 실패 시 기존 토큰 삭제 (보안상 이유)
      try {
        await TokenStorageService.clearToken();
      } catch (clearError) {
        if (kDebugMode) {
          LoggerService.debug('토큰 삭제 실패: $clearError');
        }
      }

      return null;
    }
  }

  /// 토큰 자동 갱신 확인 및 실행
  ///
  /// 토큰이 곧 만료될 경우 자동으로 갱신을 시도합니다.
  ///
  /// Returns: 갱신된 토큰 번들 또는 현재 토큰 (갱신 불필요/실패 시)
  Future<AuthTokenBundle?> autoRefreshTokenIfNeeded() async {
    try {
      final currentToken = await getToken();
      if (currentToken == null) {
        return null; // 토큰이 없으면 갱신 불가
      }

      // 토큰이 곧 만료되는지 확인 (5분 전)
      final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
      final isExpiringSoon =
          currentToken.expiresAt?.isBefore(fiveMinutesFromNow) ?? false;

      if (isExpiringSoon && currentToken.refreshToken != null) {
        if (kDebugMode) {
          LoggerService.debug(
            '토큰 자동 갱신 시작 (만료 예정: ${currentToken.expiresAt?.toIso8601String()})',
          );
        }

        // 리프레시 토큰으로 갱신 시도
        final refreshedToken = await refreshToken(currentToken.refreshToken!);

        if (refreshedToken != null) {
          if (kDebugMode) {
            LoggerService.debug('토큰 자동 갱신 성공');
          }
          return refreshedToken;
        } else {
          if (kDebugMode) {
            LoggerService.debug('토큰 자동 갱신 실패');
          }
          return currentToken; // 갱신 실패 시 기존 토큰 반환
        }
      }

      // 갱신이 필요하지 않으면 현재 토큰 반환
      return currentToken;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('토큰 자동 갱신 확인 실패: $e');
      }
      return null;
    }
  }
}
