import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 보안 저장소 유틸리티 클래스
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  /// 서버 JWT 토큰 키
  static const String _serverJwtKey = 'server_jwt_token';

  /// 토큰 만료 시간 키 // Changed
  static const String _tokenExpiryKey = 'server_jwt_expiry';

  /// 서버 JWT 토큰 저장
  static Future<void> saveServerJWT(String token) async {
    await _storage.write(key: _serverJwtKey, value: token);
  }

  /// 서버 JWT 토큰 읽기
  static Future<String?> getServerJWT() async {
    return _storage.read(key: _serverJwtKey);
  }

  /// 모든 저장된 데이터 삭제
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// 서버 JWT 토큰 존재 여부 확인
  static Future<bool> hasServerJWT() async {
    final token = await getServerJWT();
    return token != null && token.isNotEmpty;
  }

  /// 서버 JWT 토큰과 만료 시간 함께 저장 // Changed
  static Future<void> saveServerJWTWithExpiry(String token, DateTime expiry) async {
    await _storage.write(key: _serverJwtKey, value: token);
    await _storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
  }

  /// 토큰 만료 시간 읽기 // Changed
  static Future<DateTime?> getTokenExpiry() async {
    final expiryString = await _storage.read(key: _tokenExpiryKey);
    if (expiryString != null) {
      try {
        return DateTime.parse(expiryString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// 토큰이 만료되었는지 확인 // Changed
  static Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true; // 만료 시간이 없으면 만료된 것으로 간주

    return DateTime.now().isAfter(expiry);
  }

  /// 토큰이 곧 만료될지 확인 (기본: 5분 전) // Changed
  static Future<bool> isTokenExpiringSoon({Duration threshold = const Duration(minutes: 5)}) async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;

    final warningTime = expiry.subtract(threshold);
    return DateTime.now().isAfter(warningTime);
  }

  /// 서버 JWT 토큰과 만료 시간 모두 삭제 // Changed
  static Future<void> deleteServerJWT() async {
    await _storage.delete(key: _serverJwtKey);
    await _storage.delete(key: _tokenExpiryKey);
  }
}