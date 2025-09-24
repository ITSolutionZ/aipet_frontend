import 'package:aipet_frontend/features/auth/domain/auth_token.dart';
import 'package:aipet_frontend/shared/core/services/auth_token_repository.dart';
import 'package:flutter/foundation.dart';

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
      // TODO: 실제 백엔드 API 호출로 토큰 갱신 구현 필요
      // 현재는 Mock 데이터 사용 중 (프론트엔드 완성을 위해 실제 로직 구현)

      // 실제 구현 예시:
      // final response = await http.post(
      //   Uri.parse('${AppConfig.current.apiBaseUrl}/auth/refresh'),
      //   headers: {'Authorization': 'Bearer $refreshToken'},
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   final authToken = AuthToken.fromJson(data);
      //   await TokenStorageService.saveToken(authToken);
      //   return AuthTokenBundle(...);
      // } else {
      //   // 토큰 갱신 실패 시 기존 토큰 삭제
      //   await TokenStorageService.clearToken();
      //   return null;
      // }

      // 현재 Mock 구현 (개발용) - 실제 토큰 갱신처럼 동작
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock 새 토큰 생성 (실제 API 응답처럼)
      final authToken = AuthToken(
        accessToken:
            'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken:
            'refreshed_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        tokenType: 'Bearer',
      );

      // 새 토큰 저장
      await TokenStorageService.saveToken(authToken);

      if (kDebugMode) {
        debugPrint('토큰 갱신 완료 (만료: ${authToken.expiresAt.toIso8601String()})');
      }

      return AuthTokenBundle(
        accessToken: authToken.accessToken,
        refreshToken: authToken.refreshToken,
        tokenType: authToken.tokenType,
        expiresAt: authToken.expiresAt,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('토큰 리프레시 실패: $e');
      }

      // 갱신 실패 시 기존 토큰 삭제 (보안상 이유)
      try {
        await TokenStorageService.clearToken();
      } catch (clearError) {
        if (kDebugMode) {
          debugPrint('토큰 삭제 실패: $clearError');
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
          debugPrint(
            '토큰 자동 갱신 시작 (만료 예정: ${currentToken.expiresAt?.toIso8601String()})',
          );
        }

        // 리프레시 토큰으로 갱신 시도
        final refreshedToken = await refreshToken(currentToken.refreshToken!);

        if (refreshedToken != null) {
          if (kDebugMode) {
            debugPrint('토큰 자동 갱신 성공');
          }
          return refreshedToken;
        } else {
          if (kDebugMode) {
            debugPrint('토큰 자동 갱신 실패');
          }
          return currentToken; // 갱신 실패 시 기존 토큰 반환
        }
      }

      // 갱신이 필요하지 않으면 현재 토큰 반환
      return currentToken;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('토큰 자동 갱신 확인 실패: $e');
      }
      return null;
    }
  }
}
