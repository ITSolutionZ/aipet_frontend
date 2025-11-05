import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../shared/shared.dart';

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
  static Future<void> debugTokenInfo({bool showFullToken = false}) async {
    if (!kDebugMode) return;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        LoggerService.debug('🔍 [Firebase Token Debug] ログインしていません');
        return;
      }

      final token = await user.getIdToken();
      final tokenResult = await user.getIdTokenResult();

      LoggerService.debug('🔍 [Firebase Token Debug] ================');
      LoggerService.debug('   ユーザーUID: ${user.uid}');
      LoggerService.debug('   メール: ${user.email}');
      LoggerService.debug('   トークン長: ${token?.length ?? 0}文字');

      if (token != null) {
        if (showFullToken) {
          // フルトークンを表示（開発専用 - 注意！）
          LoggerService.debug('   🔑 フルトークン:');
          LoggerService.debug('   $token');
        } else {
          // セキュリティのため、最初と最後のみ表示
          final prefix = token.substring(
            0,
            token.length > 20 ? 20 : token.length,
          );
          final suffix = token.length > 40
              ? token.substring(token.length - 20)
              : '';
          LoggerService.debug('   🔑 トークン（一部）: $prefix...$suffix');
        }
      }

      LoggerService.debug('   発行時間: ${tokenResult.issuedAtTime}');
      LoggerService.debug('   有効期限: ${tokenResult.expirationTime}');
      LoggerService.debug('   署名プロバイダー: ${tokenResult.signInProvider}');

      // 残り時間を計算
      if (tokenResult.expirationTime != null) {
        final remaining = tokenResult.expirationTime!.difference(
          DateTime.now(),
        );
        LoggerService.debug(
          '   残り時間: ${remaining.inMinutes}分 ${remaining.inSeconds % 60}秒',
        );
      }

      // クレーム情報
      if (tokenResult.claims != null && tokenResult.claims!.isNotEmpty) {
        LoggerService.debug('   📋 クレーム情報:');
        tokenResult.claims!.forEach((key, value) {
          LoggerService.debug('      - $key: $value');
        });
      }

      LoggerService.debug('=========================================');
    } catch (e) {
      LoggerService.debug('❌ トークンデバッグ情報出力失敗: $e');
    }
  }

  /// ストレージに保存されたトークン情報をデバッグ出力
  static Future<void> debugStoredTokenInfo() async {
    if (!kDebugMode) return;

    try {
      final storedToken = await getTokenFromStorage();

      LoggerService.debug('💾 [Stored Token Debug] ================');
      if (storedToken == null) {
        LoggerService.debug('   保存されたトークンなし');
      } else {
        LoggerService.debug('   トークン長: ${storedToken.length}文字');
        final prefix = storedToken.substring(
          0,
          storedToken.length > 20 ? 20 : storedToken.length,
        );
        final suffix = storedToken.length > 40
            ? storedToken.substring(storedToken.length - 20)
            : '';
        LoggerService.debug('   🔑 トークン（一部）: $prefix...$suffix');
      }
      LoggerService.debug('==========================================');
    } catch (e) {
      LoggerService.debug('❌ 保存トークンデバッグ情報出力失敗: $e');
    }
  }

  /// 🧪 テスト用：全体トークンを表示（フルトークン）
  ///
  /// ⚠️ 警告：セキュリティのため、本番環境では使用しないでください！
  /// デバッグモードでのみ動作します。
  static Future<void> debugFullToken() async {
    if (!kDebugMode) return;

    LoggerService.debug('');
    LoggerService.debug('🧪 =======================================');
    LoggerService.debug('🧪 [TEST MODE] フルトークン表示');
    LoggerService.debug('🧪 ⚠️ セキュリティ注意：本番環境で使用禁止！');
    LoggerService.debug('🧪 =======================================');

    await debugTokenInfo(showFullToken: true);
    await debugStoredTokenInfo();

    LoggerService.debug('');
  }
}
