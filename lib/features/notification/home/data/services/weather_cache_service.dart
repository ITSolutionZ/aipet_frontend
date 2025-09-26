import 'dart:async';
import 'dart:convert';

import 'package:aipet_frontend/features/home/data/models/weather_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 날씨 데이터 캐시 전용 서비스
///
/// - 메모리 캐시 (빠른 접근)
/// - 디스크 캐시 (앱 재시작 후에도 유지)
/// - 위치별 캐시 관리
/// - 캐시 만료 정책
class WeatherCacheService {
  static const String _cacheKeyPrefix = 'weather_cache_';
  static const String _cacheTimeKeyPrefix = 'weather_cache_time_';
  static const String _cacheLocationKeyPrefix = 'weather_cache_location_';

  // 메모리 캐시
  static final Map<String, WeatherData> _memoryCache = {};
  static final Map<String, DateTime> _memoryCacheTime = {};
  static final Map<String, WeatherLocation> _memoryCacheLocation = {};

  // 캐시 설정 - API 호출 최적화를 위해 30분 간격으로 설정
  static const Duration defaultCacheDuration = Duration(minutes: 30);
  static const Duration userTriggeredCacheDuration = Duration(
    minutes: 15,
  ); // 사용자 트리거시 15분
  static const Duration offlineCacheDuration = Duration(hours: 24);

  /// 캐시에서 날씨 데이터 조회
  ///
  /// [location] 위치 정보
  /// [userTriggered] 사용자가 직접 요청한 경우
  static Future<WeatherData?> getCached({
    required WeatherLocation location,
    bool userTriggered = false,
  }) async {
    final locationKey = _getLocationKey(location);

    // 1. 메모리 캐시 확인 (가장 빠름)
    if (_isMemoryCacheValid(locationKey, userTriggered)) {
      debugPrint('🚀 Memory cache hit for $locationKey');
      return _memoryCache[locationKey];
    }

    // 2. 디스크 캐시 확인 (앱 재시작 후에도 유지)
    if (!userTriggered) {
      // 사용자 트리거시 디스크 캐시 무시
      final diskCachedData = await _getDiskCached(locationKey);
      if (diskCachedData != null) {
        // 메모리 캐시에도 저장
        _memoryCache[locationKey] = diskCachedData;
        _memoryCacheTime[locationKey] = DateTime.now();
        _memoryCacheLocation[locationKey] = location;

        debugPrint('💾 Disk cache hit for $locationKey');
        return diskCachedData;
      }
    }

    debugPrint('❌ Cache miss for $locationKey');
    return null;
  }

  /// 캐시에 날씨 데이터 저장
  ///
  /// [weatherData] 저장할 날씨 데이터
  /// [location] 위치 정보
  static Future<void> setCached({
    required WeatherData weatherData,
    required WeatherLocation location,
  }) async {
    final locationKey = _getLocationKey(location);
    final now = DateTime.now();

    // 메모리 캐시 저장
    _memoryCache[locationKey] = weatherData;
    _memoryCacheTime[locationKey] = now;
    _memoryCacheLocation[locationKey] = location;

    // 디스크 캐시 저장 (백그라운드에서 실행)
    unawaited(
      _saveDiskCache(locationKey, weatherData, now).catchError((error) {
        debugPrint('Failed to save disk cache: $error');
      }),
    );

    debugPrint('✅ Weather data cached for $locationKey');
  }

  /// 캐시 무효화 (특정 위치)
  static Future<void> invalidateCache(WeatherLocation location) async {
    final locationKey = _getLocationKey(location);

    // 메모리 캐시 삭제
    _memoryCache.remove(locationKey);
    _memoryCacheTime.remove(locationKey);
    _memoryCacheLocation.remove(locationKey);

    // 디스크 캐시 삭제
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cacheKeyPrefix$locationKey');
      await prefs.remove('$_cacheTimeKeyPrefix$locationKey');
      await prefs.remove('$_cacheLocationKeyPrefix$locationKey');
    } catch (e) {
      debugPrint('Failed to remove disk cache: $e');
    }

    debugPrint('🗑️ Cache invalidated for $locationKey');
  }

  /// 모든 캐시 삭제
  static Future<void> clearAllCache() async {
    // 메모리 캐시 삭제
    _memoryCache.clear();
    _memoryCacheTime.clear();
    _memoryCacheLocation.clear();

    // 디스크 캐시 삭제
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final weatherCacheKeys = keys.where(
        (key) =>
            key.startsWith(_cacheKeyPrefix) ||
            key.startsWith(_cacheTimeKeyPrefix) ||
            key.startsWith(_cacheLocationKeyPrefix),
      );

      for (final key in weatherCacheKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Failed to clear disk cache: $e');
    }

    debugPrint('🧹 All weather cache cleared');
  }

  /// 위치 기반 캐시 키 생성
  static String _getLocationKey(WeatherLocation location) {
    return '${location.latitude.toStringAsFixed(2)}_${location.longitude.toStringAsFixed(2)}';
  }

  /// 메모리 캐시 유효성 확인
  static bool _isMemoryCacheValid(String locationKey, bool userTriggered) {
    final cachedTime = _memoryCacheTime[locationKey];
    final cachedData = _memoryCache[locationKey];

    if (cachedTime == null || cachedData == null) return false;

    final duration = userTriggered
        ? userTriggeredCacheDuration
        : defaultCacheDuration;

    final isValid = DateTime.now().difference(cachedTime) < duration;

    if (!isValid) {
      // 만료된 메모리 캐시 삭제
      _memoryCache.remove(locationKey);
      _memoryCacheTime.remove(locationKey);
      _memoryCacheLocation.remove(locationKey);
    }

    return isValid;
  }

  /// 디스크 캐시에서 데이터 조회
  static Future<WeatherData?> _getDiskCached(String locationKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cachedTimeString = prefs.getString(
        '$_cacheTimeKeyPrefix$locationKey',
      );
      final cachedDataString = prefs.getString('$_cacheKeyPrefix$locationKey');

      if (cachedTimeString == null || cachedDataString == null) return null;

      final cachedTime = DateTime.parse(cachedTimeString);
      final isExpired =
          DateTime.now().difference(cachedTime) > offlineCacheDuration;

      if (isExpired) {
        // 만료된 디스크 캐시 삭제
        await prefs.remove('$_cacheKeyPrefix$locationKey');
        await prefs.remove('$_cacheTimeKeyPrefix$locationKey');
        await prefs.remove('$_cacheLocationKeyPrefix$locationKey');
        return null;
      }

      final cachedData = json.decode(cachedDataString) as Map<String, dynamic>;
      return WeatherData(
        temperature: cachedData['temperature']?.toDouble() ?? 0.0,
        location: cachedData['location'] ?? '',
        weatherId: cachedData['weather_id'] ?? 800,
        description: cachedData['description'] ?? '',
        feelsLike: cachedData['feels_like']?.toDouble() ?? 0.0,
        humidity: cachedData['humidity'] ?? 0,
        windSpeed: cachedData['wind_speed']?.toDouble() ?? 0.0,
        iconCode: cachedData['icon_code'] ?? '01d',
        uvIndex: cachedData['uv_index']?.toDouble() ?? 0.0,
        visibility: cachedData['visibility'] ?? 10000,
        pressure: cachedData['pressure']?.toDouble() ?? 1013.25,
      );
    } catch (e) {
      debugPrint('Failed to load disk cache: $e');
      return null;
    }
  }

  /// 디스크 캐시에 데이터 저장
  static Future<void> _saveDiskCache(
    String locationKey,
    WeatherData weatherData,
    DateTime timestamp,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final dataJson = json.encode(weatherData.toJson());

      await prefs.setString('$_cacheKeyPrefix$locationKey', dataJson);
      await prefs.setString(
        '$_cacheTimeKeyPrefix$locationKey',
        timestamp.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Failed to save disk cache: $e');
    }
  }
}
