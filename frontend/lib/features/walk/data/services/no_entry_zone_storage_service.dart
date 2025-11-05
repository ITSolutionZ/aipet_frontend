import '../../../../shared/shared.dart';

import 'dart:convert';

import '../../../../../features/walk/domain/entities/no_entry_zone_entity.dart';


/// 금지구역 로컬 저장소 서비스
class NoEntryZoneStorageService {
  static const String _storageKey = 'no_entry_zones';

  // ✅ SharedPreferences 인스턴스 재사용
  static final _cache = CacheService();
  static Future<void> _init() async {
    await _cache.initialize();
  }

  /// 모든 금지구역 로드
  static Future<List<NoEntryZone>> loadNoEntryZones() async {
    try {
      await _init();
      final jsonString = _cache.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => NoEntryZone.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.debug('금지구역 로드 실패: $e');
      return [];
    }
  }

  /// 금지구역 추가
  static Future<void> addNoEntryZone(NoEntryZone zone) async {
    try {
      final zones = await loadNoEntryZones();
      zones.add(zone);
      await _saveZones(zones);
    } catch (e) {
      LoggerService.debug('금지구역 추가 실패: $e');
    }
  }

  /// 금지구역 삭제
  static Future<void> removeNoEntryZone(String zoneId) async {
    try {
      final zones = await loadNoEntryZones();
      zones.removeWhere((zone) => zone.id == zoneId);
      await _saveZones(zones);
    } catch (e) {
      LoggerService.debug('금지구역 삭제 실패: $e');
    }
  }

  /// 모든 금지구역 삭제
  static Future<void> clearNoEntryZones() async {
    try {
      await _init();
      await _cache.removeKey(_storageKey);
    } catch (e) {
      LoggerService.debug('금지구역 초기화 실패: $e');
    }
  }

  /// 금지구역 저장
  static Future<void> _saveZones(List<NoEntryZone> zones) async {
    try {
      await _init();
      final jsonList = zones.map((zone) => zone.toJson()).toList();
      await _cache.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      LoggerService.debug('금지구역 저장 실패: $e');
    }
  }

  /// 특정 펫의 금지구역 로드
  static Future<List<NoEntryZone>> loadPetNoEntryZones(String petId) async {
    // 현재는 전역 금지구역만 관리
    // 추후 펫별 금지구역 관리 시 구현
    return loadNoEntryZones();
  }
}
