import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 통합 로컬 데이터 관리자
/// Mock 데이터를 로컬 저장소로 마이그레이션하기 위한 중앙 관리 서비스
class LocalDataManager {
  static LocalDataManager? _instance;
  static LocalDataManager get instance => _instance ??= LocalDataManager._();

  LocalDataManager._();

  SharedPreferences? _prefs;
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// 초기화 상태 확인
  bool get isInitialized => _prefs != null;

  /// 초기화
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ================================
  // Pet 관련 데이터 저장/로드
  // ================================

  /// 펫 프로필 목록 저장
  Future<void> savePetProfiles(List<Map<String, dynamic>> profiles) async {
    final jsonString = jsonEncode(profiles);
    await _prefs!.setString('pet_profiles', jsonString);
  }

  /// 펫 프로필 목록 로드
  Future<List<Map<String, dynamic>>> loadPetProfiles() async {
    final jsonString = _prefs!.getString('pet_profiles');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    final profiles = jsonList.cast<Map<String, dynamic>>();

    // 디버그: 로드된 펫 데이터 확인
    if (kDebugMode) {
      debugPrint('🔍 LocalDataManager: 로드된 펫 프로필 수: ${profiles.length}');
      if (profiles.isNotEmpty) {
        debugPrint('🔍 LocalDataManager: 첫 번째 펫: ${profiles.first['name']}');
      }
    }

    return profiles;
  }

  /// 펫 등록 정보 저장
  Future<void> savePetRegistration(
    String petId,
    Map<String, dynamic> data,
  ) async {
    await _prefs!.setString('pet_registration_$petId', jsonEncode(data));
  }

  /// 펫 등록 정보 로드
  Future<Map<String, dynamic>?> loadPetRegistration(String petId) async {
    final jsonString = _prefs!.getString('pet_registration_$petId');
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// 임시 펫 등록 폼 데이터 저장
  Future<void> savePetRegistrationFormData(
    Map<String, dynamic> formData,
  ) async {
    await _prefs!.setString(
      'pet_registration_form_draft',
      jsonEncode(formData),
    );
  }

  /// 임시 펫 등록 폼 데이터 로드
  Future<Map<String, dynamic>?> loadPetRegistrationFormData() async {
    final jsonString = _prefs!.getString('pet_registration_form_draft');
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// 임시 펫 등록 폼 데이터 삭제
  Future<void> clearPetRegistrationFormData() async {
    await _prefs!.remove('pet_registration_form_draft');
  }

  // ================================
  // Walk 관련 데이터 저장/로드
  // ================================

  /// 산책 기록 저장
  Future<void> saveWalkRecords(List<Map<String, dynamic>> records) async {
    await _prefs!.setString('walk_records', jsonEncode(records));
  }

  /// 산책 기록 로드
  Future<List<Map<String, dynamic>>> loadWalkRecords() async {
    final jsonString = _prefs!.getString('walk_records');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  /// 진행 중인 산책 저장
  Future<void> saveActiveWalk(Map<String, dynamic> walkData) async {
    await _prefs!.setString('active_walk', jsonEncode(walkData));
  }

  /// 진행 중인 산책 로드
  Future<Map<String, dynamic>?> loadActiveWalk() async {
    final jsonString = _prefs!.getString('active_walk');
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// 진행 중인 산책 삭제
  Future<void> clearActiveWalk() async {
    await _prefs!.remove('active_walk');
  }

  // ================================
  // Feeding 관련 데이터 저장/로드
  // ================================

  /// 급식 기록 저장
  Future<void> saveFeedingRecords(List<Map<String, dynamic>> records) async {
    await _prefs!.setString('feeding_records', jsonEncode(records));
  }

  /// 급식 기록 로드
  Future<List<Map<String, dynamic>>> loadFeedingRecords() async {
    final jsonString = _prefs!.getString('feeding_records');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  /// 급식 스케줄 저장
  Future<void> saveFeedingSchedules(
    List<Map<String, dynamic>> schedules,
  ) async {
    await _prefs!.setString('feeding_schedules', jsonEncode(schedules));
  }

  /// 급식 스케줄 로드
  Future<List<Map<String, dynamic>>> loadFeedingSchedules() async {
    final jsonString = _prefs!.getString('feeding_schedules');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  /// 펫 현재 상태 저장
  Future<void> savePetStatus(String petId, Map<String, dynamic> status) async {
    await _prefs!.setString('pet_status_$petId', jsonEncode(status));
  }

  /// 펫 현재 상태 로드
  Future<Map<String, dynamic>?> loadPetStatus(String petId) async {
    final jsonString = _prefs!.getString('pet_status_$petId');
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // ================================
  // Health 관련 데이터 저장/로드
  // ================================

  /// 건강 기록 저장
  Future<void> saveHealthRecords(List<Map<String, dynamic>> records) async {
    await _prefs!.setString('health_records', jsonEncode(records));
  }

  /// 건강 기록 로드
  Future<List<Map<String, dynamic>>> loadHealthRecords() async {
    final jsonString = _prefs!.getString('health_records');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  /// 예방접종 기록 저장
  Future<void> saveVaccineRecords(List<Map<String, dynamic>> records) async {
    await _prefs!.setString('vaccine_records', jsonEncode(records));
  }

  /// 예방접종 기록 로드
  Future<List<Map<String, dynamic>>> loadVaccineRecords() async {
    final jsonString = _prefs!.getString('vaccine_records');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // ================================
  // AI 관련 데이터 저장/로드
  // ================================

  /// AI 채팅 히스토리 저장
  Future<void> saveAiChatHistory(List<Map<String, dynamic>> history) async {
    await _prefs!.setString('ai_chat_history', jsonEncode(history));
  }

  /// AI 채팅 히스토리 로드
  Future<List<Map<String, dynamic>>> loadAiChatHistory() async {
    final jsonString = _prefs!.getString('ai_chat_history');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  /// AI 즐겨찾기 QA 저장
  Future<void> saveAiFavoriteQAs(List<Map<String, dynamic>> qas) async {
    await _prefs!.setString('ai_favorite_qas', jsonEncode(qas));
  }

  /// AI 즐겨찾기 QA 로드
  Future<List<Map<String, dynamic>>> loadAiFavoriteQAs() async {
    final jsonString = _prefs!.getString('ai_favorite_qas');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // ================================
  // Activities 관련 데이터 저장/로드
  // ================================

  /// 비디오 북마크 저장
  Future<void> saveVideoBookmarks(List<Map<String, dynamic>> bookmarks) async {
    await _prefs!.setString('video_bookmarks', jsonEncode(bookmarks));
  }

  /// 비디오 북마크 로드
  Future<List<Map<String, dynamic>>> loadVideoBookmarks() async {
    final jsonString = _prefs!.getString('video_bookmarks');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  /// 트릭 데이터 저장
  Future<void> saveTricks(List<Map<String, dynamic>> tricks) async {
    await _prefs!.setString('tricks', jsonEncode(tricks));
  }

  /// 트릭 데이터 로드
  Future<List<Map<String, dynamic>>> loadTricks() async {
    final jsonString = _prefs!.getString('tricks');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // ================================
  // Notification 관련 데이터 저장/로드
  // ================================

  /// 알림 설정 저장
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    await _prefs!.setString('notification_settings', jsonEncode(settings));
  }

  /// 알림 설정 로드
  Future<Map<String, dynamic>?> loadNotificationSettings() async {
    final jsonString = _prefs!.getString('notification_settings');
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// 알림 목록 저장
  Future<void> saveNotifications(
    List<Map<String, dynamic>> notifications,
  ) async {
    await _prefs!.setString('notifications', jsonEncode(notifications));
  }

  /// 알림 목록 로드
  Future<List<Map<String, dynamic>>> loadNotifications() async {
    final jsonString = _prefs!.getString('notifications');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // ================================
  // Facility 관련 데이터 저장/로드
  // ================================

  /// 시설 예약 정보 저장
  Future<void> saveFacilityBookings(List<Map<String, dynamic>> bookings) async {
    await _prefs!.setString('facility_bookings', jsonEncode(bookings));
  }

  /// 시설 예약 정보 로드
  Future<List<Map<String, dynamic>>> loadFacilityBookings() async {
    final jsonString = _prefs!.getString('facility_bookings');
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  // ================================
  // 보안 데이터 저장/로드 (SecureStorage)
  // ================================

  /// 민감한 데이터 저장 (토큰, 비밀번호 등)
  Future<void> saveSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// 민감한 데이터 로드
  Future<String?> loadSecureData(String key) async {
    return _secureStorage.read(key: key);
  }

  /// 민감한 데이터 삭제
  Future<void> deleteSecureData(String key) async {
    return _secureStorage.delete(key: key);
  }

  // ================================
  // 유틸리티 메서드
  // ================================

  /// 모든 로컬 데이터 삭제 (API 연계 시 사용)
  Future<void> clearAllLocalData() async {
    await _prefs!.clear();
    await _secureStorage.deleteAll();
  }

  /// 특정 키 패턴의 데이터 삭제
  Future<void> clearDataByPattern(String pattern) async {
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.contains(pattern)) {
        await _prefs!.remove(key);
      }
    }
  }

  /// 펫 데이터 완전 초기화 (빈 상태로 설정)
  Future<void> clearAllPetData() async {
    await _prefs!.remove('pet_profiles');
    await _prefs!.remove('migration_completed_pet_profiles');

    // 펫 관련 모든 패턴 삭제
    await clearDataByPattern('pet_');
    await clearDataByPattern('pet_registration_');

    if (kDebugMode) {
      debugPrint('🧹 LocalDataManager: 모든 펫 데이터 완전 초기화 완료');
    }
  }

  /// 데이터 존재 여부 확인
  bool hasData(String key) {
    return _prefs!.containsKey(key);
  }

  /// Mock 데이터 마이그레이션 플래그 설정
  Future<void> setMigrationCompleted(String feature) async {
    await _prefs!.setBool('migration_completed_$feature', true);
  }

  /// Mock 데이터 마이그레이션 완료 여부 확인
  bool isMigrationCompleted(String feature) {
    return _prefs!.getBool('migration_completed_$feature') ?? false;
  }
}
