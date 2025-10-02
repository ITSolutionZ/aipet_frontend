import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// 위치 정보 캐싱 서비스
///
/// GPS 위치 정보를 캐싱하여 불필요한 위치 조회를 방지합니다.
/// TTL(Time To Live)을 사용하여 일정 시간 동안 캐시된 위치를 재사용합니다.
class LocationCacheService {
  static LocationCacheService? _instance;
  static LocationCacheService get instance =>
      _instance ??= LocationCacheService._();

  LocationCacheService._();

  Position? _cachedPosition;
  DateTime? _cacheTimestamp;

  /// 캐시 유효 시간 (기본: 30초)
  /// 30초 이내에는 같은 위치를 재사용
  static const Duration cacheDuration = Duration(seconds: 30);

  /// 캐시된 위치 가져오기
  ///
  /// 캐시가 유효하면 캐시된 위치를 반환하고, 만료되었으면 null을 반환합니다.
  Position? getCachedPosition() {
    if (_cachedPosition == null || _cacheTimestamp == null) {
      debugPrint('📍 LocationCache: 캐시 없음');
      return null;
    }

    final now = DateTime.now();
    final difference = now.difference(_cacheTimestamp!);

    if (difference > cacheDuration) {
      debugPrint('📍 LocationCache: 캐시 만료 (${difference.inSeconds}초 경과)');
      _cachedPosition = null;
      _cacheTimestamp = null;
      return null;
    }

    debugPrint(
      '✅ LocationCache: 캐시 히트 (${difference.inSeconds}초 전) - '
      'lat: ${_cachedPosition!.latitude}, lng: ${_cachedPosition!.longitude}',
    );
    return _cachedPosition;
  }

  /// 위치 정보 캐시에 저장
  void cachePosition(Position position) {
    _cachedPosition = position;
    _cacheTimestamp = DateTime.now();
    debugPrint(
      '💾 LocationCache: 위치 정보 캐싱 - '
      'lat: ${position.latitude}, lng: ${position.longitude}',
    );
  }

  /// 캐시 무효화
  void invalidateCache() {
    _cachedPosition = null;
    _cacheTimestamp = null;
    debugPrint('🗑️ LocationCache: 캐시 무효화');
  }

  /// 캐시 유효성 확인
  bool isCacheValid() {
    if (_cachedPosition == null || _cacheTimestamp == null) {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(_cacheTimestamp!);
    return difference <= cacheDuration;
  }

  /// 캐시 정보 확인 (디버깅용)
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedPosition': _cachedPosition != null,
      'cacheTimestamp': _cacheTimestamp?.toIso8601String(),
      'isValid': isCacheValid(),
      'position': _cachedPosition != null
          ? {
              'latitude': _cachedPosition!.latitude,
              'longitude': _cachedPosition!.longitude,
              'accuracy': _cachedPosition!.accuracy,
            }
          : null,
    };
  }
}
