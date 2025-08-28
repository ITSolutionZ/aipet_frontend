import 'package:flutter/foundation.dart';

import '../../../../shared/services/secure_storage_service_v2.dart';
import '../../domain/auth_token.dart';

/// 토큰을 안전하게 저장하고 관리하는 서비스
/// 패스워드는 저장하지 않고 토큰만 관리
class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  static const String _tokenTypeKey = 'token_type';
  static const String _savedEmailKey = 'saved_email';
  static const String _rememberMeKey = 'remember_me';

  /// 토큰 저장
  static Future<void> saveToken(AuthToken token) async {
    try {
      await Future.wait([
        SecureStorageServiceV2.setString(_accessTokenKey, token.accessToken),
        if (token.refreshToken != null)
          SecureStorageServiceV2.setString(_refreshTokenKey, token.refreshToken!),
        SecureStorageServiceV2.setString(
          _tokenExpiresAtKey,
          token.expiresAt.toIso8601String(),
        ),
        SecureStorageServiceV2.setString(_tokenTypeKey, token.tokenType),
      ]);

      if (kDebugMode) {
        debugPrint('토큰 저장 완료');
      }
    } catch (e) {
      debugPrint('토큰 저장 실패: $e');
      rethrow;
    }
  }

  /// 저장된 토큰 불러오기
  static Future<AuthToken?> getToken() async {
    try {
      final results = await Future.wait([
        SecureStorageServiceV2.getString(_accessTokenKey),
        SecureStorageServiceV2.getString(_refreshTokenKey),
        SecureStorageServiceV2.getString(_tokenExpiresAtKey),
        SecureStorageServiceV2.getString(_tokenTypeKey),
      ]);

      final accessToken = results[0];
      final refreshToken = results[1];
      final expiresAtStr = results[2];
      final tokenType = results[3];

      if (accessToken == null || expiresAtStr == null) {
        return null;
      }

      return AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.parse(expiresAtStr),
        tokenType: tokenType ?? 'Bearer',
      );
    } catch (e) {
      debugPrint('토큰 불러오기 실패: $e');
      return null;
    }
  }

  /// 토큰 삭제 (로그아웃 시)
  static Future<void> clearToken() async {
    try {
      await Future.wait([
        SecureStorageServiceV2.remove(_accessTokenKey),
        SecureStorageServiceV2.remove(_refreshTokenKey),
        SecureStorageServiceV2.remove(_tokenExpiresAtKey),
        SecureStorageServiceV2.remove(_tokenTypeKey),
      ]);

      if (kDebugMode) {
        debugPrint('토큰 삭제 완료');
      }
    } catch (e) {
      debugPrint('토큰 삭제 실패: $e');
      rethrow;
    }
  }

  /// Remember Me 기능을 위한 이메일만 저장 (패스워드는 저장하지 않음)
  static Future<void> saveRememberMeEmail(String email) async {
    try {
      await Future.wait([
        SecureStorageServiceV2.setString(_savedEmailKey, email),
        SecureStorageServiceV2.setBool(_rememberMeKey, true),
      ]);

      if (kDebugMode) {
        debugPrint('Remember Me 이메일 저장 완료');
      }
    } catch (e) {
      debugPrint('Remember Me 저장 실패: $e');
      rethrow;
    }
  }

  /// 저장된 Remember Me 정보 불러오기
  static Future<String?> getRememberMeEmail() async {
    try {
      final isRememberMe =
          await SecureStorageServiceV2.getBool(_rememberMeKey) ?? false;
      if (!isRememberMe) {
        return null;
      }

      return await SecureStorageServiceV2.getString(_savedEmailKey);
    } catch (e) {
      debugPrint('Remember Me 정보 불러오기 실패: $e');
      return null;
    }
  }

  /// Remember Me 정보 삭제
  static Future<void> clearRememberMe() async {
    try {
      await Future.wait([
        SecureStorageServiceV2.remove(_savedEmailKey),
        SecureStorageServiceV2.setBool(_rememberMeKey, false),
      ]);

      if (kDebugMode) {
        debugPrint('Remember Me 정보 삭제 완료');
      }
    } catch (e) {
      debugPrint('Remember Me 정보 삭제 실패: $e');
      rethrow;
    }
  }

  /// 현재 사용자가 인증되었는지 확인
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && !token.isExpired;
  }
}
