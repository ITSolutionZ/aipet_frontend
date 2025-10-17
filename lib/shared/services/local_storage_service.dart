import 'package:aipet_frontend/features/ai/data/services/local_ai_service.dart';
import 'package:aipet_frontend/features/facility/data/services/local_facility_service.dart';
import 'package:aipet_frontend/features/pet/data/services/local_pet_service.dart';
import 'package:aipet_frontend/features/scheduling/data/services/local_schedule_service.dart';
import 'package:aipet_frontend/features/settings/data/services/local_user_service.dart';

import 'local_database_service.dart';

export 'package:aipet_frontend/features/ai/data/services/local_ai_service.dart';
export 'package:aipet_frontend/features/facility/data/services/local_facility_service.dart';
export 'package:aipet_frontend/features/pet/data/services/local_pet_service.dart';
export 'package:aipet_frontend/features/scheduling/data/services/local_schedule_service.dart';
export 'package:aipet_frontend/features/settings/data/services/local_user_service.dart';

export 'local_database_service.dart';

/// 통합 로컬 스토리지 서비스
/// 모든 로컬 데이터 접근을 위한 단일 진입점
class LocalStorageService {
  static LocalStorageService? _instance;

  final LocalDatabaseService database = LocalDatabaseService.instance;
  final LocalPetService pet = LocalPetService();
  final LocalScheduleService schedule = LocalScheduleService();
  final LocalAiService ai = LocalAiService();
  final LocalFacilityService facility = LocalFacilityService();
  final LocalUserService user = LocalUserService();

  LocalStorageService._();

  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  /// 로컬 스토리지 초기화
  Future<void> initialize() async {
    // 데이터베이스 초기화
    await database.database;

    // 필요한 초기 설정 수행
    await _performInitialSetup();
  }

  /// 초기 설정 수행
  Future<void> _performInitialSetup() async {
    // 기본 카테고리 설정
    final categories = await ai.loadAiCategories();
    if (categories == null || categories.isEmpty) {
      await ai.saveAiCategories([
        {'id': '1', 'name': '健康', 'icon': '🏥'},
        {'id': '2', 'name': '食事', 'icon': '🍖'},
        {'id': '3', 'name': 'しつけ', 'icon': '🎓'},
        {'id': '4', 'name': '運動', 'icon': '🏃'},
        {'id': '5', 'name': 'グルーミング', 'icon': '✂️'},
      ]);
    }

    // 기본 키워드 설정
    final keywords = await ai.loadAiKeywords();
    if (keywords.isEmpty) {
      await ai.saveAiKeywords([
        '予防接種',
        '食事量',
        '散歩時間',
        'トレーニング方法',
        '健康チェック',
        '緊急時対応',
      ]);
    }
  }

  /// 모든 로컬 데이터 삭제 (리셋)
  Future<void> clearAllData() async {
    await database.deleteDatabase();
    final prefs = await database.prefs;
    await prefs.clear();
  }

  /// 특정 펫의 모든 데이터 삭제
  Future<void> clearPetData(String petId) async {
    await pet.deletePet(petId);
    // 관련 데이터는 CASCADE로 자동 삭제됨
  }

  /// 데이터 마이그레이션 (향후 버전 업그레이드 시 사용)
  Future<void> migrateData() async {
    // 버전별 마이그레이션 로직 구현
  }

  /// 데이터 백업
  Future<Map<String, dynamic>> backupData() async {
    final backup = <String, dynamic>{};

    // 모든 펫 정보
    backup['pets'] = await pet.getAllPets();

    // 모든 스케줄
    backup['schedules'] = await schedule.getAllSchedules();

    // 사용자 프로필 정보
    backup['userProfile'] = await user.loadUserProfile();

    // AI 설정
    backup['aiSettings'] = await ai.loadAiSettings();
    backup['aiCategories'] = await ai.loadAiCategories();

    // 시설 즐겨찾기
    backup['facilityFavorites'] = await facility.getFavorites();

    backup['backupDate'] = DateTime.now().toIso8601String();

    return backup;
  }

  /// 데이터 복원
  Future<void> restoreData(Map<String, dynamic> backup) async {
    // 기존 데이터 삭제
    await clearAllData();

    // 데이터베이스 재초기화
    await initialize();

    // 펫 정보 복원
    if (backup['pets'] != null) {
      for (final petData in backup['pets']) {
        await pet.addPet(petData);
      }
    }

    // 스케줄 복원
    if (backup['schedules'] != null) {
      for (final scheduleData in backup['schedules']) {
        await schedule.addSchedule(scheduleData);
      }
    }

    // 사용자 프로필 정보 복원
    if (backup['userProfile'] != null) {
      await user.saveUserProfile(backup['userProfile']);
    }

    // AI 설정 복원
    if (backup['aiSettings'] != null) {
      await ai.saveAiSettings(backup['aiSettings']);
    }
    if (backup['aiCategories'] != null) {
      await ai.saveAiCategories(backup['aiCategories']);
    }

    // 시설 즐겨찾기 복원
    if (backup['facilityFavorites'] != null) {
      for (final favoriteData in backup['facilityFavorites']) {
        await facility.addFavorite(favoriteData);
      }
    }
  }
}
