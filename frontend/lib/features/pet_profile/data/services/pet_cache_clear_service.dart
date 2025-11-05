import 'package:flutter/foundation.dart';


import '../../../../shared/shared.dart';
/// 펫 관련 캐시 클리어 서비스
/// 목업 데이터 제거를 위해 모든 펫 관련 캐시를 초기화
class PetCacheClearService {
  static final CacheService _cacheService = CacheService();

  /// 모든 펫 관련 캐시 클리어
  ///
  /// [return] 클리어 완료 여부
  static Future<bool> clearAllPetCache() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('🧹 PetCacheClearService: 모든 펫 관련 캐시 클리어 시작');
      }

      // LocalDataManager의 펫 데이터 완전 초기화
      await LocalDataManager.instance.clearAllPetData();

      // 펫 프로필 캐시 클리어
      await _clearPetProfileCache();

      // 건강 요약 캐시 클리어
      await _clearHealthSummaryCache();

      // 대시보드 캐시 클리어
      await _clearDashboardCache();

      if (kDebugMode) {
        LoggerService.debug('✅ PetCacheClearService: 모든 펫 관련 캐시 클리어 완료');
      }

      return true;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        LoggerService.debug('❌ PetCacheClearService: 캐시 클리어 실패: $error');
        LoggerService.debug('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// 펫 프로필 캐시 클리어
  static Future<void> _clearPetProfileCache() async {
    try {
      // 메모리 캐시에서 펫 프로필 제거
      await _cacheService.removeKey(CacheKeys.petProfiles);

      if (kDebugMode) {
        LoggerService.debug('🧹 PetCacheClearService: 펫 프로필 캐시 클리어 완료');
      }
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('❌ PetCacheClearService: 펫 프로필 캐시 클리어 실패: $error');
      }
    }
  }

  /// 건강 요약 캐시 클리어
  static Future<void> _clearHealthSummaryCache() async {
    try {
      // 메모리 캐시에서 건강 요약 제거
      await _cacheService.removeKey(CacheKeys.healthSummary);

      if (kDebugMode) {
        LoggerService.debug('🧹 PetCacheClearService: 건강 요약 캐시 클리어 완료');
      }
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('❌ PetCacheClearService: 건강 요약 캐시 클리어 실패: $error');
      }
    }
  }

  /// 대시보드 캐시 클리어
  static Future<void> _clearDashboardCache() async {
    try {
      // 메모리 캐시에서 대시보드 데이터 제거
      await _cacheService.removeKey(CacheKeys.dashboard);

      if (kDebugMode) {
        LoggerService.debug('🧹 PetCacheClearService: 대시보드 캐시 클리어 완료');
      }
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('❌ PetCacheClearService: 대시보드 캐시 클리어 실패: $error');
      }
    }
  }

  /// 특정 캐시 키 클리어
  ///
  /// [cacheKey] 클리어할 캐시 키
  /// [return] 클리어 완료 여부
  static Future<bool> clearSpecificCache(String cacheKey) async {
    try {
      await _cacheService.removeKey(cacheKey);

      if (kDebugMode) {
        LoggerService.debug('🧹 PetCacheClearService: $cacheKey 캐시 클리어 완료');
      }

      return true;
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug(
          '❌ PetCacheClearService: $cacheKey 캐시 클리어 실패: $error',
        );
      }
      return false;
    }
  }

  /// 캐시 상태 확인
  ///
  /// [return] 캐시 상태 정보
  static Map<String, dynamic> getCacheStatus() {
    try {
      final petProfilesCache = _cacheService.getCache<List<dynamic>>(
        CacheKeys.petProfiles,
      );
      final healthSummaryCache = _cacheService.getCache<dynamic>(
        CacheKeys.healthSummary,
      );
      final dashboardCache = _cacheService.getCache<dynamic>(
        CacheKeys.dashboard,
      );

      return {
        'petProfiles': petProfilesCache != null,
        'healthSummary': healthSummaryCache != null,
        'dashboard': dashboardCache != null,
        'hasAnyCache':
            petProfilesCache != null ||
            healthSummaryCache != null ||
            dashboardCache != null,
      };
    } catch (error) {
      if (kDebugMode) {
        LoggerService.debug('❌ PetCacheClearService: 캐시 상태 확인 실패: $error');
      }
      return {'error': error.toString()};
    }
  }

  /// 강제 캐시 새로고침
  ///
  /// 모든 펫 관련 캐시를 클리어하고 새로고침을 트리거
  /// [return] 새로고침 완료 여부
  static Future<bool> forceRefreshAllPetData() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('🔄 PetCacheClearService: 강제 펫 데이터 새로고침 시작');
      }

      // 모든 캐시 클리어
      final clearResult = await clearAllPetCache();

      if (clearResult) {
        if (kDebugMode) {
          LoggerService.debug('✅ PetCacheClearService: 강제 펫 데이터 새로고침 완료');
        }
        return true;
      } else {
        if (kDebugMode) {
          LoggerService.debug('❌ PetCacheClearService: 캐시 클리어 실패로 새로고침 불가');
        }
        return false;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        LoggerService.debug('❌ PetCacheClearService: 강제 새로고침 실패: $error');
        LoggerService.debug('Stack trace: $stackTrace');
      }
      return false;
    }
  }
}
