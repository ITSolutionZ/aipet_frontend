import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';

import '../../domain/domain.dart';
import 'auth_config_service.dart';

/// 토큰을 안전하게 저장하고 관리하는 서비스
/// 패스워드는 저장하지 않고 토큰만 관리
class TokenStorageService {
  // AuthConfigConstants에서 상수 사용
  static String get _accessTokenKey => AuthConfigConstants.accessTokenKey;
  static String get _refreshTokenKey => AuthConfigConstants.refreshTokenKey;
  static String get _tokenExpiresAtKey => AuthConfigConstants.tokenExpiresAtKey;
  static String get _tokenTypeKey => AuthConfigConstants.tokenTypeKey;
  static String get _savedEmailKey => AuthConfigConstants.savedEmailKey;
  static String get _rememberMeKey => AuthConfigConstants.rememberMeKey;

  /// 토큰 저장
  static Future<void> saveToken(AuthToken token) async {
    try {
      await Future.wait([
        SecureStorageService.setString(_accessTokenKey, token.accessToken),
        if (token.refreshToken != null)
          SecureStorageService.setString(_refreshTokenKey, token.refreshToken!),
        SecureStorageService.setString(
          _tokenExpiresAtKey,
          token.expiresAt.toIso8601String(),
        ),
        SecureStorageService.setString(_tokenTypeKey, token.tokenType),
      ]);

      if (kDebugMode) {
        LoggerService.debug('토큰 저장 완료');
      }
    } catch (e) {
      LoggerService.debug('토큰 저장 실패: $e');
      rethrow;
    }
  }

  /// 저장된 토큰 불러오기
  static Future<AuthToken?> getToken() async {
    try {
      final results = await Future.wait([
        SecureStorageService.getString(_accessTokenKey),
        SecureStorageService.getString(_refreshTokenKey),
        SecureStorageService.getString(_tokenExpiresAtKey),
        SecureStorageService.getString(_tokenTypeKey),
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
      LoggerService.debug('토큰 불러오기 실패: $e');
      return null;
    }
  }

  /// 토큰 삭제 (로그아웃 시)
  static Future<void> clearToken() async {
    try {
      await Future.wait([
        SecureStorageService.remove(_accessTokenKey),
        SecureStorageService.remove(_refreshTokenKey),
        SecureStorageService.remove(_tokenExpiresAtKey),
        SecureStorageService.remove(_tokenTypeKey),
      ]);

      if (kDebugMode) {
        LoggerService.debug('토큰 삭제 완료');
      }
    } catch (e) {
      LoggerService.debug('토큰 삭제 실패: $e');
      rethrow;
    }
  }

  /// Remember Me 기능을 위한 이메일만 저장 (패스워드는 저장하지 않음)
  static Future<void> saveRememberMeEmail(String email) async {
    try {
      await Future.wait([
        SecureStorageService.setString(_savedEmailKey, email),
        SecureStorageService.setBool(_rememberMeKey, true),
      ]);

      if (kDebugMode) {
        LoggerService.debug('Remember Me 이메일 저장 완료');
      }
    } catch (e) {
      LoggerService.debug('Remember Me 저장 실패: $e');
      rethrow;
    }
  }

  /// 저장된 Remember Me 정보 불러오기
  static Future<String?> getRememberMeEmail() async {
    try {
      final isRememberMe =
          await SecureStorageService.getBool(_rememberMeKey) ?? false;
      if (!isRememberMe) {
        return null;
      }

      return await SecureStorageService.getString(_savedEmailKey);
    } catch (e) {
      LoggerService.debug('Remember Me 정보 불러오기 실패: $e');
      return null;
    }
  }

  /// Remember Me 정보 삭제
  static Future<void> clearRememberMe() async {
    try {
      await Future.wait([
        SecureStorageService.remove(_savedEmailKey),
        SecureStorageService.setBool(_rememberMeKey, false),
      ]);

      if (kDebugMode) {
        LoggerService.debug('Remember Me 정보 삭제 완료');
      }
    } catch (e) {
      LoggerService.debug('Remember Me 정보 삭제 실패: $e');
      rethrow;
    }
  }

  /// 현재 사용자가 인증되었는지 확인
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && !token.isExpired;
  }
}
