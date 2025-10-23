import 'package:aipet_frontend/features/pet_profile/data/services/pet_cache_clear_service.dart';
import 'package:aipet_frontend/shared/services/local_data_manager.dart';
import 'package:flutter/foundation.dart';

/// 펫 데이터 리셋 유틸리티
/// 목업 데이터 완전 제거를 위한 강제 리셋 기능
class PetDataResetUtil {
  /// 펫 데이터 강제 리셋 (개발용)
  ///
  /// 모든 펫 관련 데이터를 완전히 제거하고 빈 상태로 초기화
  /// [return] 리셋 완료 여부
  static Future<bool> forceResetAllPetData() async {
    try {
      if (kDebugMode) {
        LoggerService.debug('🔄 PetDataResetUtil: 펫 데이터 강제 리셋 시작');
      }

      // 1단계: LocalDataManager의 모든 펫 데이터 삭제
      await LocalDataManager.instance.clearAllPetData();

      if (kDebugMode) {
        LoggerService.debug('✅ PetDataResetUtil: LocalDataManager 펫 데이터 삭제 완료');
      }

      // 2단계: 모든 펫 관련 캐시 클리어
      final cacheClearResult = await PetCacheClearService.clearAllPetCache();

      if (kDebugMode) {
        LoggerService.debug('✅ PetDataResetUtil: 펫 캐시 클리어 완료: $cacheClearResult');
      }

      // 3단계: 빈 펫 프로필 리스트 저장 (마이그레이션 완료 상태로)
      await LocalDataManager.instance.savePetProfiles([]);
      await LocalDataManager.instance.setMigrationCompleted('pet_profiles');

      if (kDebugMode) {
        LoggerService.debug('✅ PetDataResetUtil: 빈 펫 프로필 리스트 저장 완료');
      }

      // 4단계: 최종 확인
      final finalPets = await LocalDataManager.instance.loadPetProfiles();
      final isMigrationCompleted = LocalDataManager.instance
          .isMigrationCompleted('pet_profiles');

      if (kDebugMode) {
        LoggerService.debug('🔍 PetDataResetUtil: 최종 확인');
        LoggerService.debug('  - 펫 프로필 수: ${finalPets.length}');
        LoggerService.debug('  - 마이그레이션 완료: $isMigrationCompleted');
      }

      if (finalPets.isEmpty && isMigrationCompleted) {
        if (kDebugMode) {
          LoggerService.debug('✅ PetDataResetUtil: 펫 데이터 강제 리셋 성공!');
        }
        return true;
      } else {
        if (kDebugMode) {
          LoggerService.debug('❌ PetDataResetUtil: 펫 데이터 리셋 실패 - 데이터가 남아있음');
        }
        return false;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        LoggerService.debug('❌ PetDataResetUtil: 펫 데이터 강제 리셋 실패: $error');
        LoggerService.debug('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// 펫 데이터 상태 확인
  ///
  /// [return] 펫 데이터 상태 정보
  static Future<Map<String, dynamic>> getPetDataStatus() async {
    try {
      final pets = await LocalDataManager.instance.loadPetProfiles();
      final isMigrationCompleted = LocalDataManager.instance
          .isMigrationCompleted('pet_profiles');
      final cacheStatus = PetCacheClearService.getCacheStatus();

      return {
        'petCount': pets.length,
        'isMigrationCompleted': isMigrationCompleted,
        'cacheStatus': cacheStatus,
        'isClean': pets.isEmpty && isMigrationCompleted,
        'pets': pets.map((pet) => pet['name']).toList(),
      };
    } catch (error) {
      return {'error': error.toString(), 'isClean': false};
    }
  }

  /// 디버그 정보 출력
  static Future<void> printDebugInfo() async {
    if (!kDebugMode) return;

    LoggerService.debug('🔍 === 펫 데이터 디버그 정보 ===');

    final status = await getPetDataStatus();
    LoggerService.debug('펫 개수: ${status['petCount']}');
    LoggerService.debug('마이그레이션 완료: ${status['isMigrationCompleted']}');
    LoggerService.debug('깨끗한 상태: ${status['isClean']}');
    LoggerService.debug('펫 이름들: ${status['pets']}');
    LoggerService.debug('캐시 상태: ${status['cacheStatus']}');

    if (status['error'] != null) {
      LoggerService.debug('에러: ${status['error']}');
    }

    LoggerService.debug('==============================');
  }
}
