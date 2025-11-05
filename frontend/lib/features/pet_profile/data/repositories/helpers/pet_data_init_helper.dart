import 'package:aipet_frontend/shared/shared.dart';


/// Pet 데이터 초기화 헬퍼
class PetDataInitHelper {
  /// 빈 데이터로 로컬 저장소 초기화
  static Future<void> initializeWithMockData(
    LocalDataManager localDataManager,
  ) async {
    try {
      // 기존 데이터 완전 클리어
      await localDataManager.clearDataByPattern('pet_profiles');
      await localDataManager.clearDataByPattern('pet_registration_');
      await localDataManager.clearDataByPattern('pet_');

      // 마이그레이션 상태 리셋
      await localDataManager.clearDataByPattern(
        'migration_completed_pet_profiles',
      );

      // 빈 리스트로 초기화 (사용자가 직접 펫을 등록하도록)
      await localDataManager.savePetProfiles([]);
      await localDataManager.setMigrationCompleted('pet_profiles');
      LoggerService.debug('Pet profiles initialized with empty data');
    } catch (error) {
      LoggerService.debug('Failed to initialize: $error');
    }
  }

  /// 디버깅용: 로컬 저장소 데이터 상태 확인
  static Future<void> debugLocalStorageStatus(
    LocalDataManager localDataManager,
  ) async {
    final localPets = await localDataManager.loadPetProfiles();
    final isMigrationCompleted = localDataManager.isMigrationCompleted(
      'pet_profiles',
    );

    LoggerService.debug('=== Local Storage Debug Info ===');
    LoggerService.debug('Pet count: ${localPets.length}');
    LoggerService.debug('Migration completed: $isMigrationCompleted');

    if (localPets.isNotEmpty) {
      LoggerService.debug('First pet keys: ${localPets.first.keys.toList()}');
      LoggerService.debug('First pet data: ${localPets.first}');
    }
    LoggerService.debug('===============================');
  }

  /// LocalDataManager 초기화 확인
  static Future<void> ensureInitialized(
    LocalDataManager localDataManager,
  ) async {
    if (!localDataManager.isInitialized) {
      LoggerService.debug(
        'LocalDataManager not initialized, initializing now...',
      );
      await localDataManager.initialize();
      LoggerService.debug('LocalDataManager initialization completed');
    }
  }
}
