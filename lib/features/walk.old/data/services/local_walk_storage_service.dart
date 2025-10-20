import 'dart:convert';

import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 산책 데이터 저장 서비스
class LocalWalkStorageService {
  static const String _walkRecordsKey = 'walk_records';
  static const String _currentWalkKey = 'current_walk';

  /// 모든 산책 기록 저장
  static Future<bool> saveWalkRecords(
    List<WalkRecordEntity> walkRecords,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = walkRecords.map((record) => record.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      final result = await prefs.setString(_walkRecordsKey, jsonString);
      debugPrint('📱 산책 기록 저장 완료: ${walkRecords.length}개');
      return result;
    } catch (e) {
      debugPrint('❌ 산책 기록 저장 실패: $e');
      return false;
    }
  }

  /// 모든 산책 기록 불러오기
  static Future<List<WalkRecordEntity>> loadWalkRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_walkRecordsKey);

      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('📱 저장된 산책 기록이 없습니다');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final walkRecords = jsonList
          .map(
            (json) => WalkRecordEntity.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      debugPrint('📱 산책 기록 불러오기 완료: ${walkRecords.length}개');
      return walkRecords;
    } catch (e) {
      debugPrint('❌ 산책 기록 불러오기 실패: $e');
      return [];
    }
  }

  /// 새 산책 기록 추가
  static Future<bool> addWalkRecord(WalkRecordEntity walkRecord) async {
    try {
      final existingRecords = await loadWalkRecords();

      // 중복 체크 (ID 기준)
      final index = existingRecords.indexWhere(
        (record) => record.id == walkRecord.id,
      );
      if (index != -1) {
        // 기존 기록 업데이트
        existingRecords[index] = walkRecord;
      } else {
        // 새 기록 추가
        existingRecords.add(walkRecord);
      }

      return await saveWalkRecords(existingRecords);
    } catch (e) {
      debugPrint('❌ 산책 기록 추가 실패: $e');
      return false;
    }
  }

  /// 산책 기록 업데이트
  static Future<bool> updateWalkRecord(WalkRecordEntity walkRecord) async {
    try {
      final existingRecords = await loadWalkRecords();
      final index = existingRecords.indexWhere(
        (record) => record.id == walkRecord.id,
      );

      if (index != -1) {
        existingRecords[index] = walkRecord;
        return await saveWalkRecords(existingRecords);
      } else {
        debugPrint('⚠️ 업데이트할 산책 기록을 찾을 수 없습니다: ${walkRecord.id}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 산책 기록 업데이트 실패: $e');
      return false;
    }
  }

  /// 산책 기록 삭제
  static Future<bool> deleteWalkRecord(String walkId) async {
    try {
      final existingRecords = await loadWalkRecords();
      final updatedRecords = existingRecords
          .where((record) => record.id != walkId)
          .toList();

      if (updatedRecords.length < existingRecords.length) {
        debugPrint('📱 산책 기록 삭제: $walkId');
        return await saveWalkRecords(updatedRecords);
      } else {
        debugPrint('⚠️ 삭제할 산책 기록을 찾을 수 없습니다: $walkId');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 산책 기록 삭제 실패: $e');
      return false;
    }
  }

  /// 현재 진행 중인 산책 저장
  static Future<bool> saveCurrentWalk(WalkRecordEntity? walkRecord) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (walkRecord == null) {
        final result = await prefs.remove(_currentWalkKey);
        debugPrint('📱 현재 산책 기록 제거');
        return result;
      } else {
        final jsonString = jsonEncode(walkRecord.toJson());
        final result = await prefs.setString(_currentWalkKey, jsonString);
        debugPrint('📱 현재 산책 기록 저장: ${walkRecord.id}');
        return result;
      }
    } catch (e) {
      debugPrint('❌ 현재 산책 저장 실패: $e');
      return false;
    }
  }

  /// 현재 진행 중인 산책 불러오기
  static Future<WalkRecordEntity?> loadCurrentWalk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_currentWalkKey);

      if (jsonString == null || jsonString.isEmpty) {
        debugPrint('📱 현재 진행 중인 산책이 없습니다');
        return null;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final walkRecord = WalkRecordEntity.fromJson(json);

      debugPrint('📱 현재 산책 기록 불러오기: ${walkRecord.id}');
      return walkRecord;
    } catch (e) {
      debugPrint('❌ 현재 산책 불러오기 실패: $e');
      return null;
    }
  }

  /// 모든 로컬 데이터 삭제 (테스트용)
  static Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result1 = await prefs.remove(_walkRecordsKey);
      final result2 = await prefs.remove(_currentWalkKey);

      debugPrint('📱 모든 산책 데이터 삭제 완료');
      return result1 && result2;
    } catch (e) {
      debugPrint('❌ 데이터 삭제 실패: $e');
      return false;
    }
  }

  /// 저장된 데이터 통계
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final walkRecords = await loadWalkRecords();
      final currentWalk = await loadCurrentWalk();

      return {
        'totalRecords': walkRecords.length,
        'hasCurrentWalk': currentWalk != null,
        'currentWalkId': currentWalk?.id,
        'lastUpdateTime': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ 저장소 통계 조회 실패: $e');
      return {};
    }
  }
}
