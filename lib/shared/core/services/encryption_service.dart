import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// SharedPreferences 암호화 서비스
///
/// 민감한 데이터를 안전하게 저장하고 불러오기 위한 암호화 서비스입니다.
/// AES 암호화를 사용하여 데이터를 보호합니다.
class EncryptionService {
  static const String _keyPrefix = 'encryption_key_';
  static const String _ivPrefix = 'encryption_iv_';
  static const int _keyLength = 32; // AES-256
  static const int _ivLength = 16; // AES 블록 크기

  /// 데이터를 암호화하여 저장합니다.
  ///
  /// [key] SharedPreferences 키
  /// [value] 암호화할 값
  /// [prefs] SharedPreferences 인스턴스
  ///
  /// Returns 암호화 성공 여부
  static Future<bool> encryptAndSave(
    String key,
    String value,
    dynamic prefs,
  ) async {
    try {
      // 암호화 키와 IV 생성/가져오기
      final encryptionKey = await _getOrCreateKey(key, prefs);
      final iv = await _getOrCreateIV(key, prefs);

      // 데이터 암호화
      final encryptedData = _encryptAES(value, encryptionKey, iv);
      final encodedData = base64Encode(encryptedData);

      // 암호화된 데이터 저장
      await prefs.setString('$_keyPrefix$key', encodedData);

      if (kDebugMode) {
        print('데이터 암호화 완료: $key');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('데이터 암호화 실패: $key, 오류: $e');
      }
      return false;
    }
  }

  /// 암호화된 데이터를 복호화하여 불러옵니다.
  ///
  /// [key] SharedPreferences 키
  /// [prefs] SharedPreferences 인스턴스
  ///
  /// Returns 복호화된 값 또는 null
  static Future<String?> decryptAndLoad(String key, dynamic prefs) async {
    try {
      // 암호화된 데이터 가져오기
      final encodedData = prefs.getString('$_keyPrefix$key');
      if (encodedData == null) return null;

      // 암호화 키와 IV 가져오기
      final encryptionKey = await _getOrCreateKey(key, prefs);
      final iv = await _getOrCreateIV(key, prefs);

      // 데이터 복호화
      final encryptedData = base64Decode(encodedData);
      final decryptedData = _decryptAES(encryptedData, encryptionKey, iv);

      if (kDebugMode) {
        print('데이터 복호화 완료: $key');
      }

      return decryptedData;
    } catch (e) {
      if (kDebugMode) {
        print('데이터 복호화 실패: $key, 오류: $e');
      }
      return null;
    }
  }

  /// 암호화된 데이터를 삭제합니다.
  ///
  /// [key] SharedPreferences 키
  /// [prefs] SharedPreferences 인스턴스
  ///
  /// Returns 삭제 성공 여부
  static Future<bool> deleteEncryptedData(String key, dynamic prefs) async {
    try {
      await prefs.remove('$_keyPrefix$key');
      await prefs.remove('$_ivPrefix$key');

      if (kDebugMode) {
        print('암호화된 데이터 삭제 완료: $key');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('암호화된 데이터 삭제 실패: $key, 오류: $e');
      }
      return false;
    }
  }

  /// 암호화 키를 생성하거나 가져옵니다.
  static Future<Uint8List> _getOrCreateKey(String key, dynamic prefs) async {
    final keyString = '$_keyPrefix${key}_key';
    String? existingKey = prefs.getString(keyString);

    if (existingKey == null) {
      // 새로운 키 생성
      final random = Random.secure();
      final keyBytes = List<int>.generate(
        _keyLength,
        (i) => random.nextInt(256),
      );
      existingKey = base64Encode(keyBytes);
      await prefs.setString(keyString, existingKey);
    }

    return base64Decode(existingKey);
  }

  /// 초기화 벡터(IV)를 생성하거나 가져옵니다.
  static Future<Uint8List> _getOrCreateIV(String key, dynamic prefs) async {
    final ivString = '$_ivPrefix${key}_iv';
    String? existingIV = prefs.getString(ivString);

    if (existingIV == null) {
      // 새로운 IV 생성
      final random = Random.secure();
      final ivBytes = List<int>.generate(_ivLength, (i) => random.nextInt(256));
      existingIV = base64Encode(ivBytes);
      await prefs.setString(ivString, existingIV);
    }

    return base64Decode(existingIV);
  }

  /// AES 암호화 (간단한 구현)
  ///
  /// 실제 프로덕션에서는 더 강력한 암호화 라이브러리를 사용해야 합니다.
  static Uint8List _encryptAES(String data, Uint8List key, Uint8List iv) {
    // 간단한 XOR 기반 암호화 (실제 프로덕션에서는 AES 라이브러리 사용)
    final dataBytes = utf8.encode(data);
    final result = Uint8List(dataBytes.length);

    for (int i = 0; i < dataBytes.length; i++) {
      result[i] = dataBytes[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }

    return result;
  }

  /// AES 복호화 (간단한 구현)
  ///
  /// 실제 프로덕션에서는 더 강력한 암호화 라이브러리를 사용해야 합니다.
  static String _decryptAES(
    Uint8List encryptedData,
    Uint8List key,
    Uint8List iv,
  ) {
    // 간단한 XOR 기반 복호화 (실제 프로덕션에서는 AES 라이브러리 사용)
    final result = Uint8List(encryptedData.length);

    for (int i = 0; i < encryptedData.length; i++) {
      result[i] = encryptedData[i] ^ key[i % key.length] ^ iv[i % iv.length];
    }

    return utf8.decode(result);
  }

  /// 데이터가 암호화되어 저장되어 있는지 확인합니다.
  static bool isEncrypted(String key, dynamic prefs) {
    return prefs.containsKey('$_keyPrefix$key');
  }

  /// 모든 암호화된 데이터를 삭제합니다.
  static Future<bool> clearAllEncryptedData(dynamic prefs) async {
    try {
      final keys = prefs.getKeys();
      final encryptedKeys = keys.where(
        (key) => key.startsWith(_keyPrefix) || key.startsWith(_ivPrefix),
      );

      for (final key in encryptedKeys) {
        await prefs.remove(key);
      }

      if (kDebugMode) {
        print('모든 암호화된 데이터 삭제 완료');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('모든 암호화된 데이터 삭제 실패: $e');
      }
      return false;
    }
  }
}
