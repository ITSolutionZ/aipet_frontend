import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 캐시 서비스
///
/// 앱 전반의 데이터 캐싱을 관리합니다.
/// 메모리 캐시와 영속 캐시를 제공합니다.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CacheEntry> _memoryCache = {};
  SharedPreferences? _prefs;

  /// SharedPreferences 초기화
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 메모리 캐시에 데이터 저장
  void setMemoryCache<T>(String key, T data, {Duration? ttl}) {
    final entry = CacheEntry(data: data, timestamp: DateTime.now(), ttl: ttl);
    _memoryCache[key] = entry;
    debugPrint('💾 CacheService: 메모리 캐시 저장 - $key');
  }

  /// 메모리 캐시에서 데이터 조회
  T? getMemoryCache<T>(String key) {
    final entry = _memoryCache[key];
    if (entry == null) return null;

    // TTL 체크
    if (entry.isExpired) {
      _memoryCache.remove(key);
      debugPrint('⏰ CacheService: 메모리 캐시 만료 - $key');
      return null;
    }

    debugPrint('✅ CacheService: 메모리 캐시 히트 - $key');
    return entry.data as T?;
  }

  /// 영속 캐시에 데이터 저장
  Future<void> setPersistentCache(
    String key,
    Map<String, dynamic> data, {
    Duration? ttl,
  }) async {
    await initialize();

    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };

    await _prefs!.setString(key, jsonEncode(cacheData));
    debugPrint('💿 CacheService: 영속 캐시 저장 - $key');
  }

  /// 영속 캐시에 객체 저장 (JSON 직렬화)
  Future<void> setPersistentCacheObject<T>(
    String key,
    T object, {
    Duration? ttl,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final data = toJson(object);
    await setPersistentCache(key, data, ttl: ttl);
  }

  /// 영속 캐시에서 데이터 조회
  Future<Map<String, dynamic>?> getPersistentCache(String key) async {
    await initialize();

    final cachedString = _prefs!.getString(key);
    if (cachedString == null) return null;

    try {
      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        cacheData['timestamp'] as int,
      );
      final ttlMs = cacheData['ttl'] as int?;

      // TTL 체크
      if (ttlMs != null) {
        final expiry = timestamp.add(Duration(milliseconds: ttlMs));
        if (DateTime.now().isAfter(expiry)) {
          await _prefs!.remove(key);
          debugPrint('⏰ CacheService: 영속 캐시 만료 - $key');
          return null;
        }
      }

      debugPrint('✅ CacheService: 영속 캐시 히트 - $key');
      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ CacheService: 영속 캐시 파싱 오류 - $key: $e');
      await _prefs!.remove(key);
      return null;
    }
  }

  /// 영속 캐시에서 객체 조회 (JSON 역직렬화)
  Future<T?> getPersistentCacheObject<T>(
    String key, {
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final data = await getPersistentCache(key);
    if (data == null) return null;

    try {
      return fromJson(data);
    } catch (e) {
      debugPrint('❌ CacheService: 객체 역직렬화 오류 - $key: $e');
      await clearCache(key);
      return null;
    }
  }

  /// 특정 키 캐시 삭제
  Future<void> clearCache(String key) async {
    _memoryCache.remove(key);
    await initialize();
    await _prefs!.remove(key);
    debugPrint('🗑️ CacheService: 캐시 삭제 - $key');
  }

  /// 모든 캐시 삭제
  Future<void> clearAllCache() async {
    _memoryCache.clear();
    await initialize();
    await _prefs!.clear();
    debugPrint('🗑️ CacheService: 모든 캐시 삭제');
  }

  /// 메모리 캐시에서 만료된 항목 정리
  void cleanupExpiredMemoryCache() {
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('🧹 CacheService: 만료된 메모리 캐시 정리 - ${expiredKeys.length}개');
    }
  }
}

/// 캐시 엔트리
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration? ttl;

  CacheEntry({required this.data, required this.timestamp, this.ttl});

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().isAfter(timestamp.add(ttl!));
  }
}

/// 캐시 키 상수
class CacheKeys {
  static const String homeDashboard = 'home_dashboard';
  static const String weather = 'weather_data';
  static const String petProfiles = 'pet_profiles';
  static const String walkSummary = 'walk_summary';
  static const String healthSummary = 'health_summary';
  static const String appointments = 'appointments';
}

/// 캐시 TTL 상수
class CacheTTL {
  static const Duration location = Duration(seconds: 30); // 위치 정보 (30초)
  static const Duration short = Duration(minutes: 5); // 날씨 등 자주 변하는 데이터
  static const Duration medium = Duration(minutes: 15); // 홈 대시보드
  static const Duration long = Duration(hours: 1); // 펫 프로필 등 정적 데이터
  static const Duration veryLong = Duration(hours: 24); // 거의 변하지 않는 데이터
}
