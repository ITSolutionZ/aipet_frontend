import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 급여 기록 저장 헬퍼
class FeedingStorageHelper {
  static const String _keyFeedingRecords = 'feeding_records';
  static const String _keyFeedingSchedules = 'feeding_schedules';

  /// 급여 기록 가져오기
  static Future<List<Map<String, dynamic>>> getFeedingRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getStringList(_keyFeedingRecords) ?? [];

      if (recordsJson.isEmpty) {
        return await _initializeDefaultRecords();
      }

      return recordsJson.map((json) {
        return jsonDecode(json) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      debugPrint('急給記録取得エラー: $e');
      return [];
    }
  }

  /// 급여 기록 추가
  static Future<void> addFeedingRecord(Map<String, dynamic> record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final records = prefs.getStringList(_keyFeedingRecords) ?? [];

      records.add(jsonEncode(record));
      await prefs.setStringList(_keyFeedingRecords, records);

      debugPrint('急給記録追加成功: ${record['id']}');
    } catch (e) {
      debugPrint('急給記録追加エラー: $e');
    }
  }

  /// 급여 스케줄 가져오기
  static Future<List<Map<String, dynamic>>> getFeedingSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedulesJson = prefs.getStringList(_keyFeedingSchedules) ?? [];

      if (schedulesJson.isEmpty) {
        return await _initializeDefaultSchedules();
      }

      return schedulesJson.map((json) {
        return jsonDecode(json) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      debugPrint('急給スケジュール取得エラー: $e');
      return [];
    }
  }

  /// 급여 스케줄 업데이트
  static Future<void> updateFeedingSchedule(
    String mealType,
    String time,
    String amount,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schedules = await getFeedingSchedules();

      final updatedSchedules = schedules.map((schedule) {
        if (schedule['mealType'] == mealType) {
          return {
            ...schedule,
            'time': time,
            'amount': amount,
            'updatedAt': DateTime.now().toIso8601String(),
          };
        }
        return schedule;
      }).toList();

      final schedulesJson = updatedSchedules.map((s) => jsonEncode(s)).toList();
      await prefs.setStringList(_keyFeedingSchedules, schedulesJson);

      debugPrint('急給スケジュール更新成功: $mealType');
    } catch (e) {
      debugPrint('急給スケジュール更新エラー: $e');
    }
  }

  /// 오늘의 급여 상태 가져오기
  static Future<List<Map<String, dynamic>>> getTodayMeals() async {
    final schedules = await getFeedingSchedules();
    final now = DateTime.now();

    return schedules.map((schedule) {
      final timeStr = schedule['time'] as String;
      final timeParts = timeStr.split(':');
      final scheduleHour = int.parse(timeParts[0]);
      final scheduleMinute = int.parse(timeParts[1]);

      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        scheduleHour,
        scheduleMinute,
      );

      final isCompleted = now.isAfter(
        scheduledTime.add(const Duration(minutes: 30)),
      );

      return {
        'scheduleName': schedule['mealType'],
        'scheduledTime': scheduledTime,
        'isCompleted': isCompleted,
      };
    }).toList();
  }

  /// 초기 기본 급여 기록 생성
  static Future<List<Map<String, dynamic>>> _initializeDefaultRecords() async {
    final now = DateTime.now();
    final defaultRecords = [
      {
        'id': '1',
        'petId': '1',
        'petName': 'マックス',
        'fedTime': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'amount': 100.0,
        'foodType': 'ドライフード',
        'foodBrand': 'ロイヤルカナン',
        'status': 'completed',
        'notes': '完食',
        'createdAt': now.toIso8601String(),
      },
    ];

    final prefs = await SharedPreferences.getInstance();
    final recordsJson = defaultRecords.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList(_keyFeedingRecords, recordsJson);

    return defaultRecords;
  }

  /// 초기 기본 급여 스케줄 생성
  static Future<List<Map<String, dynamic>>>
  _initializeDefaultSchedules() async {
    final defaultSchedules = [
      {
        'mealType': '朝食',
        'time': '08:00',
        'amount': '100g',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'mealType': '昼食',
        'time': '12:00',
        'amount': '100g',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'mealType': '夕食',
        'time': '18:00',
        'amount': '100g',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    final prefs = await SharedPreferences.getInstance();
    final schedulesJson = defaultSchedules.map((s) => jsonEncode(s)).toList();
    await prefs.setStringList(_keyFeedingSchedules, schedulesJson);

    return defaultSchedules;
  }
}
