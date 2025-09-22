import 'package:flutter/foundation.dart';

import '../../../../shared/core/services/auth_token_repository.dart';
import '../../../../shared/testing.dart';
import '../../domain/auth_token.dart';
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

  @override
  Future<AuthTokenBundle?> refreshToken(String refreshToken) async {
    try {
      final mockResponse = await AuthMockData.mockBackendRefreshToken(
        refreshToken,
      );

      if (mockResponse['success'] != true) {
        return null;
      }

      final authToken = AuthToken(
        accessToken: mockResponse['accessToken'] as String,
        refreshToken: mockResponse['refreshToken'] as String?,
        expiresAt: DateTime.parse(mockResponse['expiresAt'] as String),
        tokenType: mockResponse['tokenType'] as String? ?? 'Bearer',
      );

      await TokenStorageService.saveToken(authToken);

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
      return null;
    }
  }
}
