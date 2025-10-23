import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 시설 로컬 저장소 서비스
///
/// 시설 정보와 즐겨찾기를 SharedPreferences에 저장/관리합니다
class FacilityLocalStorageService {
  static const String _keyFacilities = 'facilities';
  static const String _keyFavorites = 'favorite_facilities';
  static const String _keyHistory = 'facility_history';

  /// 시설 가져오기
  static Future<List<Map<String, dynamic>>> getFacilities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facilitiesJson = prefs.getStringList(_keyFacilities) ?? [];

      return facilitiesJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      LoggerService.debug('시설 로드 실패: $e');
      return [];
    }
  }

  /// 시설 추가
  static Future<void> addFacility(Map<String, dynamic> facility) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facilities = prefs.getStringList(_keyFacilities) ?? [];

      if (facility['id'] == null || (facility['id'] as String).isEmpty) {
        facility['id'] = 'facility-${DateTime.now().millisecondsSinceEpoch}';
      }

      if (facility['createdAt'] == null) {
        facility['createdAt'] = DateTime.now().toIso8601String();
      }

      facilities.add(jsonEncode(facility));
      await prefs.setStringList(_keyFacilities, facilities);

      LoggerService.debug('시설 추가 성공: ${facility['id']}');
    } catch (e) {
      LoggerService.debug('시설 추가 실패: $e');
    }
  }

  /// 여러 시설 추가 (Google Maps 검색 결과 저장)
  static Future<void> addFacilities(
    List<Map<String, dynamic>> facilitiesList,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingFacilities = prefs.getStringList(_keyFacilities) ?? [];

      // 기존 시설 ID 맵 생성
      final existingIds = <String>{};
      for (final facilityJson in existingFacilities) {
        final facility = jsonDecode(facilityJson) as Map<String, dynamic>;
        existingIds.add(facility['id'] as String);
      }

      // 중복되지 않은 새 시설만 추가
      for (final facility in facilitiesList) {
        if (facility['id'] != null && !existingIds.contains(facility['id'])) {
          if (facility['createdAt'] == null) {
            facility['createdAt'] = DateTime.now().toIso8601String();
          }
          existingFacilities.add(jsonEncode(facility));
        }
      }

      await prefs.setStringList(_keyFacilities, existingFacilities);

      LoggerService.debug('시설 일괄 추가 성공: ${facilitiesList.length}개');
    } catch (e) {
      LoggerService.debug('시설 일괄 추가 실패: $e');
    }
  }

  /// 시설 업데이트
  static Future<void> updateFacility(Map<String, dynamic> facility) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facilities = prefs.getStringList(_keyFacilities) ?? [];

      final index = facilities.indexWhere((f) {
        final facilityData = jsonDecode(f) as Map<String, dynamic>;
        return facilityData['id'] == facility['id'];
      });

      if (index != -1) {
        facility['updatedAt'] = DateTime.now().toIso8601String();
        facilities[index] = jsonEncode(facility);
        await prefs.setStringList(_keyFacilities, facilities);
        LoggerService.debug('시설 업데이트 성공: ${facility['id']}');
      }
    } catch (e) {
      LoggerService.debug('시설 업데이트 실패: $e');
    }
  }

  /// 시설 삭제
  static Future<void> deleteFacility(String facilityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final facilities = prefs.getStringList(_keyFacilities) ?? [];

      facilities.removeWhere((f) {
        final facilityData = jsonDecode(f) as Map<String, dynamic>;
        return facilityData['id'] == facilityId;
      });

      await prefs.setStringList(_keyFacilities, facilities);
      LoggerService.debug('시설 삭제 성공: $facilityId');
    } catch (e) {
      LoggerService.debug('시설 삭제 실패: $e');
    }
  }

  /// 즐겨찾기 가져오기
  static Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyFavorites) ?? [];
    } catch (e) {
      LoggerService.debug('즐겨찾기 로드 실패: $e');
      return [];
    }
  }

  /// 즐겨찾기 토글
  static Future<void> toggleFavorite(String facilityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_keyFavorites) ?? [];

      if (favorites.contains(facilityId)) {
        favorites.remove(facilityId);
      } else {
        favorites.add(facilityId);
      }

      await prefs.setStringList(_keyFavorites, favorites);
      LoggerService.debug('즐겨찾기 토글 성공: $facilityId');
    } catch (e) {
      LoggerService.debug('즐겨찾기 토글 실패: $e');
    }
  }

  /// 방문 기록 추가
  static Future<void> addToHistory(String facilityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_keyHistory) ?? [];

      // 중복 제거
      history.remove(facilityId);
      // 맨 앞에 추가 (최근 방문 순)
      history.insert(0, facilityId);

      // 최대 50개까지만 유지
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }

      await prefs.setStringList(_keyHistory, history);
      LoggerService.debug('방문 기록 추가 성공: $facilityId');
    } catch (e) {
      LoggerService.debug('방문 기록 추가 실패: $e');
    }
  }

  /// 방문 기록 가져오기
  static Future<List<String>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyHistory) ?? [];
    } catch (e) {
      LoggerService.debug('방문 기록 로드 실패: $e');
      return [];
    }
  }

  /// 모든 시설 데이터 삭제
  static Future<void> clearAllFacilities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyFacilities);
      LoggerService.debug('모든 시설 삭제 성공');
    } catch (e) {
      LoggerService.debug('모든 시설 삭제 실패: $e');
    }
  }
}
