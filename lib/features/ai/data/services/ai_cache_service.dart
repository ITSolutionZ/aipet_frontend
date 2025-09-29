import 'package:aipet_frontend/shared/services/base_logging_service.dart';

/// 🎯 AI 캐시 서비스
///
/// AI 관련 데이터의 캐싱을 담당
class AiCacheService extends BaseLoggingService {
  static const Duration _cacheTimeout = const Duration(minutes: 30);

  // 캐시 저장소
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  AiCacheService() : super('ai_cache');

  /// 캐시에서 데이터 가져오기
  T? getFromCache<T>(String key) {
    if (_cache.containsKey(key) && _cacheTimestamps.containsKey(key)) {
      final cacheTime = _cacheTimestamps[key]!;
      if (DateTime.now().difference(cacheTime) < _cacheTimeout) {
        logDebug('Cache hit for key: $key');
        return _cache[key] as T?;
      } else {
        logDebug('Cache expired for key: $key');
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    return null;
  }

  /// 캐시에 데이터 저장하기
  void setCache<T>(String key, T data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    logDebug('Data cached for key: $key');
  }

  /// 캐시 초기화
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    logInfo('Cache cleared');
  }

  /// 특정 키의 캐시 제거
  void clearCacheForKey(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    logInfo('Cache cleared for key: $key');
  }

  /// 캐시 상태 정보 가져오기
  Map<String, dynamic> getCacheStatus() {
    final now = DateTime.now();
    final status = <String, dynamic>{
      'totalKeys': _cache.length,
      'keys': <String>[],
      'expiredKeys': <String>[],
    };

    for (final key in _cache.keys) {
      status['keys'].add(key);
      if (_cacheTimestamps.containsKey(key)) {
        final cacheTime = _cacheTimestamps[key]!;
        if (now.difference(cacheTime) >= _cacheTimeout) {
          status['expiredKeys'].add(key);
        }
      }
    }

    return status;
  }

  /// 캐시 만료된 항목들 자동 정리
  void cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheTimeout) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      logInfo('Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }
}
