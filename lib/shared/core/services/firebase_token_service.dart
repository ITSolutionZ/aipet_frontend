import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'logger_service.dart';
import 'secure_storage_service.dart';

/// Firebase ID Token 관리 서비스
///
/// Firebase Auth에서 ID Token을 획득하고 관리합니다.
/// 백엔드 API 인증에 사용됩니다.
class FirebaseTokenService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 현재 사용자의 Firebase ID Token 획득
  ///
  /// [forceRefresh] true인 경우 캐시된 토큰을 무시하고 새로 발급받습니다.
  /// Returns: Firebase ID Token 또는 null (로그인하지 않은 경우)
  static Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final token = await user.getIdToken(forceRefresh);
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Firebase ID Token을 SecureStorage에 저장
  ///
  /// 백엔드 API 호출 시 사용하기 위해 로컬에 저장합니다.
  static Future<bool> saveTokenToStorage() async {
    try {
      final token = await getIdToken();
      if (token == null) {
        return false;
      }

      await SecureStorageService.saveToken(token);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// SecureStorage에서 토큰 조회
  static Future<String?> getTokenFromStorage() async {
    try {
      final token = await SecureStorageService.getToken();
      return token;
    } catch (e) {
      return null;
    }
  }

  /// 토큰 갱신 및 저장
  ///
  /// 만료된 토큰을 새로 발급받아 저장합니다.
  static Future<String?> refreshAndSaveToken() async {
    try {
      final token = await getIdToken(forceRefresh: true);
      if (token == null) {
        return null;
      }

      await SecureStorageService.saveToken(token);
      return token;
    } catch (e) {
      return null;
    }
  }

  /// 토큰 유효성 검증
  ///
  /// 토큰이 만료되지 않았는지 확인합니다.
  static Future<bool> isTokenValid() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Firebase는 자동으로 만료된 토큰을 갱신해줌
      final token = await user.getIdToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }

  /// 로그아웃 시 토큰 삭제
  static Future<void> clearToken() async {
    try {
      await SecureStorageService.clearTokens();
    } catch (e) {
      // 에러 무시
    }
  }

  /// 현재 로그인 사용자 ID (UID) 조회
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// 현재 로그인 사용자 이메일 조회
  static String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// 토큰 정보 디버그 출력
  static Future<void> debugTokenInfo() async {
    if (!kDebugMode) return;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        LoggerService.debug('🔍 [Token Debug] 로그인하지 않음');
        return;
      }

      final token = await user.getIdToken();
      final tokenResult = await user.getIdTokenResult();

      LoggerService.debug('🔍 [Token Debug] ================');
      LoggerService.debug('   사용자 UID: ${user.uid}');
      LoggerService.debug('   이메일: ${user.email}');
      LoggerService.debug('   토큰 길이: ${token?.length ?? 0}');
      LoggerService.debug('   발급 시간: ${tokenResult.issuedAtTime}');
      LoggerService.debug('   만료 시간: ${tokenResult.expirationTime}');
      LoggerService.debug('   서명 제공자: ${tokenResult.signInProvider}');
      LoggerService.debug('================================');
    } catch (e) {
      LoggerService.debug('❌ 토큰 디버그 정보 출력 실패: $e');
    }
  }
}

