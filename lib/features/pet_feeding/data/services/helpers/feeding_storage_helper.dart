import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 급여 저장소 헬퍼
class FeedingStorageHelper {
  static const String _keyFeedingRecords = 'pet_feeding_records';

  /// 급여 기록 가져오기
  static Future<List<Map<String, dynamic>>> getFeedingRecords({
    String? petId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList(_keyFeedingRecords) ?? [];

      if (recordsJson.isEmpty) {
        return await _initializeDefaultRecords();
      }

      final records = recordsJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      if (petId != null) {
        return records.where((r) => r['petId'] == petId).toList();
      }

      return records;
    } catch (e) {
      debugPrint('급여 기록 로드 실패: $e');
      return [];
    }
  }

  /// 급여 기록 추가
  static Future<void> addFeedingRecord(Map<String, dynamic> record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = prefs.getStringList(_keyFeedingRecords) ?? [];

      // ID가 없으면 생성
      if (record['id'] == null || (record['id'] as String).isEmpty) {
        record['id'] = 'feeding-${DateTime.now().millisecondsSinceEpoch}';
      }

      // createdAt 추가
      if (record['createdAt'] == null) {
        record['createdAt'] = DateTime.now().toIso8601String();
      }

      records.add(jsonEncode(record));
      await prefs.setStringList(_keyFeedingRecords, records);

      debugPrint('급여 기록 추가 성공: ${record['id']}');
    } catch (e) {
      debugPrint('급여 기록 추가 실패: $e');
      rethrow;
    }
  }

  /// 급여 기록 업데이트
  static Future<void> updateFeedingRecord(Map<String, dynamic> record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = prefs.getStringList(_keyFeedingRecords) ?? [];

      final index = records.indexWhere((r) {
        final recordData = jsonDecode(r) as Map<String, dynamic>;
        return recordData['id'] == record['id'];
      });

      if (index != -1) {
        record['updatedAt'] = DateTime.now().toIso8601String();
        records[index] = jsonEncode(record);
        await prefs.setStringList(_keyFeedingRecords, records);
        debugPrint('급여 기록 업데이트 성공: ${record['id']}');
      }
    } catch (e) {
      debugPrint('급여 기록 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 급여 기록 삭제
  static Future<void> deleteFeedingRecord(String recordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = prefs.getStringList(_keyFeedingRecords) ?? [];

      records.removeWhere((r) {
        final recordData = jsonDecode(r) as Map<String, dynamic>;
        return recordData['id'] == recordId;
      });

      await prefs.setStringList(_keyFeedingRecords, records);
      debugPrint('급여 기록 삭제 성공: $recordId');
    } catch (e) {
      debugPrint('급여 기록 삭제 실패: $e');
      rethrow;
    }
  }

  /// 날짜별 급여 기록 가져오기
  static Future<List<Map<String, dynamic>>> getFeedingRecordsByDate(
    String petId,
    DateTime date,
  ) async {
    try {
      final allRecords = await getFeedingRecords(petId: petId);

      return allRecords.where((record) {
        final fedTime = DateTime.parse(record['fedTime'] as String);
        return fedTime.year == date.year &&
            fedTime.month == date.month &&
            fedTime.day == date.day;
      }).toList();
    } catch (e) {
      debugPrint('날짜별 급여 기록 로드 실패: $e');
      return [];
    }
  }

  /// 급여 기록 통계
  static Future<Map<String, dynamic>> getFeedingStats(String petId) async {
    try {
      final records = await getFeedingRecords(petId: petId);

      final completed = records.where((r) => r['status'] == 'completed').length;
      final skipped = records.where((r) => r['status'] == 'skipped').length;
      final partial = records.where((r) => r['status'] == 'partial').length;

      return {
        'total': records.length,
        'completed': completed,
        'skipped': skipped,
        'partial': partial,
        'completionRate': records.isNotEmpty ? completed / records.length : 0.0,
      };
    } catch (e) {
      debugPrint('급여 기록 통계 실패: $e');
      return {
        'total': 0,
        'completed': 0,
        'skipped': 0,
        'partial': 0,
        'completionRate': 0.0,
      };
    }
  }

  /// 초기 기본 급여 기록 생성
  static Future<List<Map<String, dynamic>>> _initializeDefaultRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultRecords = <Map<String, dynamic>>[];

    final recordsJson = defaultRecords.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList(_keyFeedingRecords, recordsJson);

    return defaultRecords;
  }
}
