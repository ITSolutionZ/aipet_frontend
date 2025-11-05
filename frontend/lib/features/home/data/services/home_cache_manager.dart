import '../../../../shared/shared.dart';

/// 홈 화면 전용 캐시 관리자
///
/// 홈 화면의 캐시 무효화 및 새로고침 로직을 관리합니다.
class HomeCacheManager {
  static final HomeCacheManager _instance = HomeCacheManager._internal();
  factory HomeCacheManager() => _instance;
  HomeCacheManager._internal();

  final CacheService _cacheService = CacheService();

  /// 홈 대시보드 캐시 새로고침
  ///
  /// 사용자가 Pull-to-Refresh를 수행하거나 특정 데이터 변경 시 호출
  Future<void> refreshHomeDashboard() async {
    LoggerService.debug('🔄 HomeCacheManager: 홈 대시보드 캐시 새로고침');

    // 홈 관련 모든 캐시 삭제
    await Future.wait([
      _cacheService.removeKey(CacheKeys.homeDashboard),
      _cacheService.removeKey(CacheKeys.weather),
      _cacheService.removeKey(CacheKeys.petProfiles),
      _cacheService.removeKey(CacheKeys.walkSummary),
      _cacheService.removeKey(CacheKeys.healthSummary),
      _cacheService.removeKey(CacheKeys.appointments),
    ]);

    LoggerService.debug('✅ HomeCacheManager: 홈 대시보드 캐시 새로고침 완료');
  }

  /// 특정 데이터 캐시 무효화
  ///
  /// 특정 기능에서 데이터가 변경되었을 때 관련 캐시만 삭제
  Future<void> invalidateCache(HomeCacheType cacheType) async {
    String cacheKey;
    String description;

    switch (cacheType) {
      case HomeCacheType.weather:
        cacheKey = CacheKeys.weather;
        description = '날씨';
        break;
      case HomeCacheType.petProfiles:
        cacheKey = CacheKeys.petProfiles;
        description = '펫 프로필';
        break;
      case HomeCacheType.walkSummary:
        cacheKey = CacheKeys.walkSummary;
        description = '산책 요약';
        break;
      case HomeCacheType.healthSummary:
        cacheKey = CacheKeys.healthSummary;
        description = '건강 요약';
        break;
      case HomeCacheType.appointments:
        cacheKey = CacheKeys.appointments;
        description = '예약 정보';
        break;
    }

    await _cacheService.removeKey(cacheKey);
    LoggerService.debug('🗑️ HomeCacheManager: $description 캐시 무효화');

    // 홈 대시보드 캐시도 함께 무효화 (종속성 때문)
    await _cacheService.removeKey(CacheKeys.homeDashboard);
    LoggerService.debug('🗑️ HomeCacheManager: 홈 대시보드 캐시도 무효화');
  }

  /// 백그라운드 캐시 정리
  ///
  /// 앱이 백그라운드에서 포그라운드로 돌아왔을 때 호출
  Future<void> cleanupExpiredCache() async {
    _cacheService.cleanupExpiredCache();
    LoggerService.debug('🧹 HomeCacheManager: 만료된 캐시 정리 완료');
  }

  /// 캐시 상태 확인 (디버그용)
  Map<String, bool> getCacheStatus() {
    return {
      'homeDashboard':
          _cacheService.getCache<dynamic>(CacheKeys.homeDashboard) != null,
      'weather': _cacheService.getCache<dynamic>(CacheKeys.weather) != null,
      'petProfiles':
          _cacheService.getCache<dynamic>(CacheKeys.petProfiles) != null,
      'walkSummary':
          _cacheService.getCache<dynamic>(CacheKeys.walkSummary) != null,
      'healthSummary':
          _cacheService.getCache<dynamic>(CacheKeys.healthSummary) != null,
      'appointments':
          _cacheService.getCache<dynamic>(CacheKeys.appointments) != null,
    };
  }
}

/// 홈 캐시 타입
enum HomeCacheType {
  weather,
  petProfiles,
  walkSummary,
  healthSummary,
  appointments,
}
