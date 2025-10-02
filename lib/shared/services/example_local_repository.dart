import 'local_data_manager.dart';

/// 로컬 저장소 사용 예제 - Pet Repository 구현
/// 기존 Repository 구현체들을 로컬 저장소 버전으로 변경할 때 참고용
class ExampleLocalPetRepository {
  final LocalDataManager _localDataManager = LocalDataManager.instance;

  // ================================
  // Pet 프로필 관리
  // ================================

  /// 모든 펫 프로필 조회
  Future<List<Map<String, dynamic>>> getAllPetProfiles() async {
    return await _localDataManager.loadPetProfiles();
  }

  /// ID로 펫 프로필 조회
  Future<Map<String, dynamic>?> getPetProfileById(String petId) async {
    final profiles = await _localDataManager.loadPetProfiles();
    try {
      return profiles.firstWhere((pet) => pet['id'] == petId);
    } catch (e) {
      return null;
    }
  }

  /// 펫 프로필 생성
  Future<void> createPetProfile(Map<String, dynamic> petData) async {
    final profiles = await _localDataManager.loadPetProfiles();

    // ID가 없으면 생성
    if (petData['id'] == null) {
      petData['id'] = 'pet-${DateTime.now().millisecondsSinceEpoch}';
    }

    petData['createdAt'] = DateTime.now().toIso8601String();
    petData['updatedAt'] = DateTime.now().toIso8601String();

    profiles.add(petData);
    await _localDataManager.savePetProfiles(profiles);
  }

  /// 펫 프로필 수정
  Future<void> updatePetProfile(String petId, Map<String, dynamic> updatedData) async {
    final profiles = await _localDataManager.loadPetProfiles();

    final index = profiles.indexWhere((pet) => pet['id'] == petId);
    if (index != -1) {
      updatedData['updatedAt'] = DateTime.now().toIso8601String();
      profiles[index] = {...profiles[index], ...updatedData};
      await _localDataManager.savePetProfiles(profiles);
    }
  }

  /// 펫 프로필 삭제
  Future<void> deletePetProfile(String petId) async {
    final profiles = await _localDataManager.loadPetProfiles();
    profiles.removeWhere((pet) => pet['id'] == petId);
    await _localDataManager.savePetProfiles(profiles);

    // 관련 데이터도 삭제
    await _localDataManager.clearDataByPattern('pet_status_$petId');
    await _localDataManager.clearDataByPattern('pet_registration_$petId');
  }

  // ================================
  // Pet 상태 관리
  // ================================

  /// 펫 현재 상태 조회
  Future<Map<String, dynamic>?> getPetStatus(String petId) async {
    return await _localDataManager.loadPetStatus(petId);
  }

  /// 펫 상태 업데이트
  Future<void> updatePetStatus(String petId, Map<String, dynamic> status) async {
    status['updatedAt'] = DateTime.now().toIso8601String();
    await _localDataManager.savePetStatus(petId, status);
  }

  // ================================
  // Feeding 관련 데이터
  // ================================

  /// 급식 기록 조회
  Future<List<Map<String, dynamic>>> getFeedingRecords({String? petId}) async {
    final records = await _localDataManager.loadFeedingRecords();

    if (petId != null) {
      return records.where((record) => record['petId'] == petId).toList();
    }

    return records;
  }

  /// 급식 기록 추가
  Future<void> addFeedingRecord(Map<String, dynamic> record) async {
    final records = await _localDataManager.loadFeedingRecords();

    // ID가 없으면 생성
    if (record['id'] == null) {
      record['id'] = 'feeding-${DateTime.now().millisecondsSinceEpoch}';
    }

    record['createdAt'] = DateTime.now().toIso8601String();

    records.add(record);
    await _localDataManager.saveFeedingRecords(records);
  }

  /// 급식 기록 삭제
  Future<void> deleteFeedingRecord(String recordId) async {
    final records = await _localDataManager.loadFeedingRecords();
    records.removeWhere((record) => record['id'] == recordId);
    await _localDataManager.saveFeedingRecords(records);
  }

  // ================================
  // Walk 관련 데이터
  // ================================

  /// 산책 기록 조회
  Future<List<Map<String, dynamic>>> getWalkRecords({String? petId}) async {
    final records = await _localDataManager.loadWalkRecords();

    if (petId != null) {
      return records.where((record) => record['petId'] == petId).toList();
    }

    return records;
  }

  /// 산책 기록 추가
  Future<void> addWalkRecord(Map<String, dynamic> record) async {
    final records = await _localDataManager.loadWalkRecords();

    // ID가 없으면 생성
    if (record['id'] == null) {
      record['id'] = 'walk-${DateTime.now().millisecondsSinceEpoch}';
    }

    record['createdAt'] = DateTime.now().toIso8601String();

    records.add(record);
    await _localDataManager.saveWalkRecords(records);
  }

  /// 진행 중인 산책 저장
  Future<void> saveActiveWalk(Map<String, dynamic> walkData) async {
    await _localDataManager.saveActiveWalk(walkData);
  }

  /// 진행 중인 산책 조회
  Future<Map<String, dynamic>?> getActiveWalk() async {
    return await _localDataManager.loadActiveWalk();
  }

  /// 진행 중인 산책 완료
  Future<void> completeActiveWalk() async {
    final activeWalk = await _localDataManager.loadActiveWalk();
    if (activeWalk != null) {
      // 산책 기록으로 저장
      activeWalk['endTime'] = DateTime.now().toIso8601String();
      await addWalkRecord(activeWalk);

      // 진행 중인 산책 삭제
      await _localDataManager.clearActiveWalk();
    }
  }

  // ================================
  // 데이터 초기화 및 유틸리티
  // ================================

  /// 특정 펫의 모든 데이터 삭제
  Future<void> deleteAllPetData(String petId) async {
    // 펫 프로필 삭제
    await deletePetProfile(petId);

    // 급식 기록 삭제
    final feedingRecords = await _localDataManager.loadFeedingRecords();
    feedingRecords.removeWhere((record) => record['petId'] == petId);
    await _localDataManager.saveFeedingRecords(feedingRecords);

    // 산책 기록 삭제
    final walkRecords = await _localDataManager.loadWalkRecords();
    walkRecords.removeWhere((record) => record['petId'] == petId);
    await _localDataManager.saveWalkRecords(walkRecords);

    // 건강 기록 삭제
    final healthRecords = await _localDataManager.loadHealthRecords();
    healthRecords.removeWhere((record) => record['petId'] == petId);
    await _localDataManager.saveHealthRecords(healthRecords);
  }

  /// 데이터 존재 여부 확인
  Future<bool> hasAnyData() async {
    final profiles = await _localDataManager.loadPetProfiles();
    return profiles.isNotEmpty;
  }

  /// 데이터 통계 조회
  Future<Map<String, int>> getDataStats() async {
    final profiles = await _localDataManager.loadPetProfiles();
    final feedingRecords = await _localDataManager.loadFeedingRecords();
    final walkRecords = await _localDataManager.loadWalkRecords();
    final healthRecords = await _localDataManager.loadHealthRecords();

    return {
      'totalPets': profiles.length,
      'totalFeedingRecords': feedingRecords.length,
      'totalWalkRecords': walkRecords.length,
      'totalHealthRecords': healthRecords.length,
    };
  }
}