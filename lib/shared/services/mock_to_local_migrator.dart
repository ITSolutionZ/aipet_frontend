import 'package:flutter/foundation.dart';
import '../testing/mock_data/mock_data_service.dart';
import 'local_data_manager.dart';

/// Mock 데이터를 로컬 저장소로 마이그레이션하는 서비스
class MockToLocalMigrator {
  static MockToLocalMigrator? _instance;
  static MockToLocalMigrator get instance => _instance ??= MockToLocalMigrator._();

  MockToLocalMigrator._();

  final LocalDataManager _localDataManager = LocalDataManager.instance;

  /// 전체 Mock 데이터 마이그레이션 실행
  Future<void> migrateAllMockData() async {
    if (!MockDataService.isEnabled) {
      debugPrint('MockDataService가 비활성화되어 있습니다. 마이그레이션을 건너뜁니다.');
      return;
    }

    try {
      debugPrint('🔄 Mock 데이터 마이그레이션 시작...');

      await _migratePetData();
      await _migrateWalkData();
      await _migrateFeedingData();
      await _migrateHealthData();
      await _migrateAiData();
      await _migrateActivitiesData();
      await _migrateNotificationData();
      await _migrateFacilityData();

      debugPrint('✅ Mock 데이터 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ Mock 데이터 마이그레이션 실패: $e');
      rethrow;
    }
  }

  /// Pet 관련 데이터 마이그레이션
  Future<void> _migratePetData() async {
    if (_localDataManager.isMigrationCompleted('pet')) return;

    try {
      // 개별 Pet 데이터 마이그레이션 (MockDataService에서 ID별로 가져옴)
      final petIds = ['pet-1']; // 현재 사용 중인 펫 ID들
      final petProfiles = <Map<String, dynamic>>[];

      for (final petId in petIds) {
        final petData = MockDataService.getMockPetById(petId);
        petProfiles.add(petData);

        // Pet 상태 정보 마이그레이션
        final status = MockDataService.getPetCurrentStatus(petId);
        if (status.isNotEmpty) {
          await _localDataManager.savePetStatus(petId, status);
        }
      }

      await _localDataManager.savePetProfiles(petProfiles);

      await _localDataManager.setMigrationCompleted('pet');
      debugPrint('✅ Pet 데이터 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ Pet 데이터 마이그레이션 실패: $e');
    }
  }

  /// Walk 관련 데이터 마이그레이션
  Future<void> _migrateWalkData() async {
    if (_localDataManager.isMigrationCompleted('walk')) return;

    try {
      // Walk records 마이그레이션 (현재 MockDataService에 해당 메서드가 없으므로 빈 리스트로 초기화)
      final walkRecords = <Map<String, dynamic>>[];
      await _localDataManager.saveWalkRecords(walkRecords);

      await _localDataManager.setMigrationCompleted('walk');
      debugPrint('✅ Walk 데이터 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ Walk 데이터 마이그레이션 실패: $e');
    }
  }

  /// Feeding 관련 데이터 마이그레이션
  Future<void> _migrateFeedingData() async {
    if (_localDataManager.isMigrationCompleted('feeding')) return;

    try {
      // Feeding records 마이그레이션
      final feedingRecords = MockDataService.getMockFeedingRecords();
      await _localDataManager.saveFeedingRecords(feedingRecords);

      // Feeding statistics 마이그레이션은 계산된 데이터이므로 제외
      // (실제 records에서 계산하도록 변경)

      await _localDataManager.setMigrationCompleted('feeding');
      debugPrint('✅ Feeding 데이터 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ Feeding 데이터 마이그레이션 실패: $e');
    }
  }

  /// Health 관련 데이터 마이그레이션
  Future<void> _migrateHealthData() async {
    if (_localDataManager.isMigrationCompleted('health')) return;

    try {
      // Health records 마이그레이션 (현재 MockDataService에 해당 메서드가 없으므로 빈 리스트로 초기화)
      final healthRecords = <Map<String, dynamic>>[];
      await _localDataManager.saveHealthRecords(healthRecords);

      // Vaccine records 마이그레이션 (현재 MockDataService에 해당 메서드가 없으므로 빈 리스트로 초기화)
      final vaccineRecords = <Map<String, dynamic>>[];
      await _localDataManager.saveVaccineRecords(vaccineRecords);

      await _localDataManager.setMigrationCompleted('health');
      debugPrint('✅ Health 데이터 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ Health 데이터 마이그레이션 실패: $e');
    }
  }

  /// AI 관련 데이터 마이그레이션
  Future<void> _migrateAiData() async {
    if (_localDataManager.isMigrationCompleted('ai')) return;

    try {
      // AI chat history 마이그레이션 (현재 MockDataService에 해당 메서드가 없으므로 빈 리스트로 초기화)
      final chatHistory = <Map<String, dynamic>>[];
      await _localDataManager.saveAiChatHistory(chatHistory);

      // AI favorite QAs 마이그레이션 (현재 MockDataService에 해당 메서드가 없으므로 빈 리스트로 초기화)
      final favoriteQAs = <Map<String, dynamic>>[];
      await _localDataManager.saveAiFavoriteQAs(favoriteQAs);

      await _localDataManager.setMigrationCompleted('ai');
      debugPrint('✅ AI 데이터 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ AI 데이터 마이그레이션 실패: $e');
    }
  }

  /// Activities 관련 데이터 마이그레이션
  Future<void> _migrateActivitiesData() async {
    if (_localDataManager.isMigrationCompleted('activities')) return;

    try {
      // Video bookmarks 마이그레이션
      final videoBookmarks = MockDataService.getMockVideoBookmarks();
      await _localDataManager.saveVideoBookmarks(videoBookmarks);

      // Tricks 마이그레이션
      final tricks = MockDataService.getMockTricks();
      await _localDataManager.saveTricks(tricks);

      await _localDataManager.setMigrationCompleted('activities');
      debugPrint('✅ Activities 데이터 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ Activities 데이터 마이그레이션 실패: $e');
    }
  }

  /// Notification 관련 데이터 마이그레이션
  Future<void> _migrateNotificationData() async {
    if (_localDataManager.isMigrationCompleted('notification')) return;

    try {
      // Notifications 마이그레이션 (현재 MockDataService에 해당 메서드가 없으므로 빈 리스트로 초기화)
      final notifications = <Map<String, dynamic>>[];
      await _localDataManager.saveNotifications(notifications);

      await _localDataManager.setMigrationCompleted('notification');
      debugPrint('✅ Notification 데이터 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ Notification 데이터 마이그레이션 실패: $e');
    }
  }

  /// Facility 관련 데이터 마이그레이션
  Future<void> _migrateFacilityData() async {
    if (_localDataManager.isMigrationCompleted('facility')) return;

    try {
      // Facility bookings 마이그레이션 (현재 MockDataService에 해당 메서드가 없으므로 빈 리스트로 초기화)
      final facilityBookings = <Map<String, dynamic>>[];
      await _localDataManager.saveFacilityBookings(facilityBookings);

      await _localDataManager.setMigrationCompleted('facility');
      debugPrint('✅ Facility 데이터 마이그레이션 완료');
    } catch (e) {
      debugPrint('❌ Facility 데이터 마이그레이션 실패: $e');
    }
  }

  /// 특정 기능의 마이그레이션 상태 확인
  bool isMigrationCompleted(String feature) {
    return _localDataManager.isMigrationCompleted(feature);
  }

  /// 마이그레이션 상태 리셋 (개발/테스트용)
  Future<void> resetMigrationStatus() async {
    final features = ['pet', 'walk', 'feeding', 'health', 'ai', 'activities', 'notification', 'facility'];
    for (final feature in features) {
      await _localDataManager.clearDataByPattern('migration_completed_$feature');
    }
    debugPrint('🔄 마이그레이션 상태 리셋 완료');
  }

  /// Mock 데이터 비활성화 및 로컬 저장소 활성화
  Future<void> switchToLocalStorage() async {
    // 마이그레이션 완료 후 Mock 데이터 비활성화
    MockDataService.isEnabled = false;

    debugPrint('🔄 Mock 데이터 비활성화, 로컬 저장소 활성화 완료');
  }

  /// API 연계 준비를 위한 전체 로컬 데이터 삭제
  Future<void> clearAllDataForApiMigration() async {
    await _localDataManager.clearAllLocalData();
    debugPrint('🗑️ API 연계를 위한 로컬 데이터 전체 삭제 완료');
  }
}