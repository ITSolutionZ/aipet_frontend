import 'package:flutter/foundation.dart';
import 'local_data_manager.dart';
import 'mock_to_local_migrator.dart';

/// 로컬 저장소 초기화 및 마이그레이션 서비스
/// 앱 시작 시 호출하여 Mock 데이터를 로컬 저장소로 마이그레이션
class LocalStorageInitializationService {
  static LocalStorageInitializationService? _instance;
  static LocalStorageInitializationService get instance =>
      _instance ??= LocalStorageInitializationService._();

  LocalStorageInitializationService._();

  final LocalDataManager _localDataManager = LocalDataManager.instance;
  final MockToLocalMigrator _migrator = MockToLocalMigrator.instance;

  bool _isInitialized = false;

  /// 로컬 저장소 초기화 및 마이그레이션 실행
  /// 앱 시작 시 한 번만 호출되어야 합니다
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('LocalStorageInitializationService는 이미 초기화되었습니다.');
      return;
    }

    try {
      debugPrint('🚀 로컬 저장소 초기화 시작...');

      // 1. LocalDataManager 초기화
      await _localDataManager.initialize();
      debugPrint('✅ LocalDataManager 초기화 완료');

      // 2. Mock 데이터 마이그레이션 실행
      await _migrator.migrateAllMockData();
      debugPrint('✅ Mock 데이터 마이그레이션 완료');

      // 3. Mock 데이터 비활성화 및 로컬 저장소 활성화
      await _migrator.switchToLocalStorage();
      debugPrint('✅ 로컬 저장소 모드로 전환 완료');

      _isInitialized = true;
      debugPrint('🎉 로컬 저장소 초기화 완료!');

    } catch (e) {
      debugPrint('❌ 로컬 저장소 초기화 실패: $e');
      rethrow;
    }
  }

  /// 개발/테스트용: 초기화 상태 리셋
  void resetInitializationState() {
    _isInitialized = false;
    debugPrint('🔄 초기화 상태 리셋');
  }

  /// 초기화 완료 여부 확인
  bool get isInitialized => _isInitialized;

  /// 마이그레이션 상태 확인
  Map<String, bool> getMigrationStatus() {
    return {
      'pet': _migrator.isMigrationCompleted('pet'),
      'walk': _migrator.isMigrationCompleted('walk'),
      'feeding': _migrator.isMigrationCompleted('feeding'),
      'health': _migrator.isMigrationCompleted('health'),
      'ai': _migrator.isMigrationCompleted('ai'),
      'activities': _migrator.isMigrationCompleted('activities'),
      'notification': _migrator.isMigrationCompleted('notification'),
      'facility': _migrator.isMigrationCompleted('facility'),
    };
  }

  /// 개발/테스트용: 전체 데이터 리셋
  Future<void> resetAllData() async {
    debugPrint('🗑️ 전체 데이터 리셋 시작...');

    await _migrator.resetMigrationStatus();
    await _localDataManager.clearAllLocalData();

    _isInitialized = false;
    debugPrint('✅ 전체 데이터 리셋 완료');
  }

  /// API 연계 준비: 로컬 데이터 전체 삭제
  Future<void> prepareForApiMigration() async {
    debugPrint('🔄 API 연계 준비 시작...');

    await _migrator.clearAllDataForApiMigration();

    _isInitialized = false;
    debugPrint('✅ API 연계 준비 완료');
  }
}