import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 보안 저장소 서비스 (flutter_secure_storage 기반)
///
/// iOS: Keychain Services 사용
/// Android: EncryptedSharedPreferences + Android Keystore 사용
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  /// 문자열 데이터를 안전하게 저장합니다
  static Future<void> setString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      if (kDebugMode) {
        debugPrint('✅ Secure storage write success: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Secure storage write failed: $key, error: $e');
      }
      rethrow;
    }
  }

  /// 문자열 데이터를 안전하게 불러옵니다
  static Future<String?> getString(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (kDebugMode && value != null) {
        debugPrint('✅ Secure storage read success: $key');
      }
      return value;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Secure storage read failed: $key, error: $e');
      }
      return null;
    }
  }

  /// Boolean 값을 저장합니다
  static Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  /// Boolean 값을 불러옵니다
  static Future<bool?> getBool(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Integer 값을 저장합니다
  static Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  /// Integer 값을 불러옵니다
  static Future<int?> getInt(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// 특정 키의 데이터를 삭제합니다
  static Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
      if (kDebugMode) {
        debugPrint('✅ Secure storage delete success: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Secure storage delete failed: $key, error: $e');
      }
      rethrow;
    }
  }

  /// 모든 데이터를 삭제합니다
  static Future<void> clear() async {
    try {
      await _storage.deleteAll();
      if (kDebugMode) {
        debugPrint('✅ Secure storage clear all success');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Secure storage clear all failed: $e');
      }
      rethrow;
    }
  }

  /// 키가 존재하는지 확인합니다
  static Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Secure storage contains key check failed: $key, error: $e');
      }
      return false;
    }
  }

  /// 모든 키를 가져옵니다
  static Future<Set<String>> getKeys() async {
    try {
      final allKeys = await _storage.readAll();
      return allKeys.keys.toSet();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Secure storage get keys failed: $e');
      }
      return <String>{};
    }
  }

  /// JSON 형태의 복잡한 데이터를 저장합니다
  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  /// JSON 형태의 복잡한 데이터를 불러옵니다
  static Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ JSON decode failed for key: $key, error: $e');
      }
      return null;
    }
  }

  /// 보안 수준 검증 (디버그용)
  static Future<void> validateSecurityLevel() async {
    if (kDebugMode) {
      try {
        // 테스트 데이터 저장/읽기
        const testKey = 'security_test';
        const testValue = 'test_secure_data_12345';

        await setString(testKey, testValue);
        final retrievedValue = await getString(testKey);
        await remove(testKey);

        if (retrievedValue == testValue) {
          debugPrint('🔐 Secure Storage validation: PASSED');
        } else {
          debugPrint('⚠️  Secure Storage validation: FAILED - Data integrity issue');
        }
      } catch (e) {
        debugPrint('⚠️  Secure Storage validation: FAILED - $e');
      }
    }
  }

  // ========== 인증 토큰 관련 메서드 ==========

  /// Access Token 저장
  static Future<void> saveToken(String token) async {
    await setString('access_token', token);
  }

  /// Access Token 조회
  static Future<String?> getToken() async {
    return await getString('access_token');
  }

  /// Refresh Token 저장
  static Future<void> saveRefreshToken(String refreshToken) async {
    await setString('refresh_token', refreshToken);
  }

  /// Refresh Token 조회
  static Future<String?> getRefreshToken() async {
    return await getString('refresh_token');
  }

  /// 모든 토큰 삭제
  static Future<void> clearTokens() async {
    await remove('access_token');
    await remove('refresh_token');
  }

  /// 사용자 인증 정보 저장
  static Future<void> saveUserCredentials({
    required String accessToken,
    String? refreshToken,
    Map<String, dynamic>? userInfo,
  }) async {
    await saveToken(accessToken);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
    if (userInfo != null) {
      await setJson('user_info', userInfo);
    }
  }

  /// 사용자 정보 조회
  static Future<Map<String, dynamic>?> getUserInfo() async {
    return await getJson('user_info');
  }

  /// 사용자 정보 저장
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await setJson('user_info', userInfo);
  }

  /// 로그아웃 (모든 인증 관련 데이터 삭제)
  static Future<void> logout() async {
    await clearTokens();
    await remove('user_info');
  }
}

/// SecureStorageService Provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
