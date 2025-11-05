import '../../../../../shared/shared.dart';

import 'dart:convert';


/// 급여 기록 저장 헬퍼

class FeedingStorageHelper {
  static const String _keyFeedingRecords = 'feeding_records';
  // ✅ SharedPreferences 인스턴스 재사용
  static final _cache = CacheService();
  static Future<void> _init() async {
    await _cache.initialize();
  }

  static const String _keyFeedingSchedules = 'feeding_schedules';

  /// 급여 기록 가져오기
  static Future<List<Map<String, dynamic>>> getFeedingRecords() async {
    try {
      await _init();
      final recordsJson =
          _cache.getPersistentCacheList(_keyFeedingRecords) ?? [];

      if (recordsJson.isEmpty) {
        return await _initializeDefaultRecords();
      }

      return recordsJson.map((json) {
        return jsonDecode(json) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      LoggerService.debug('急給記録取得エラー: $e');
      return [];
    }
  }

  /// 급여 기록 추가
  static Future<void> addFeedingRecord(Map<String, dynamic> record) async {
    try {
      await _init();
      final records = _cache.getPersistentCacheList(_keyFeedingRecords) ?? [];

      records.add(jsonEncode(record));
      await _cache.setPersistentCacheList(_keyFeedingRecords, records);

      LoggerService.debug('急給記録追加成功: ${record['id']}');
    } catch (e) {
      LoggerService.debug('急給記録追加エラー: $e');
    }
  }

  /// 급여 스케줄 가져오기
  static Future<List<Map<String, dynamic>>> getFeedingSchedules() async {
    try {
      await _init();
      final schedulesJson =
          _cache.getPersistentCacheList(_keyFeedingSchedules) ?? [];

      if (schedulesJson.isEmpty) {
        return await _initializeDefaultSchedules();
      }

      return schedulesJson.map((json) {
        return jsonDecode(json) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      LoggerService.debug('急給スケジュール取得エラー: $e');
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
      await _init();
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
      await _cache.setPersistentCacheList(_keyFeedingSchedules, schedulesJson);

      LoggerService.debug('急給スケジュール更新成功: $mealType');
    } catch (e) {
      LoggerService.debug('急給スケジュール更新エラー: $e');
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

    await _init();
    final recordsJson = defaultRecords.map((r) => jsonEncode(r)).toList();
    await _cache.setPersistentCacheList(_keyFeedingRecords, recordsJson);

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

    await _init();
    final schedulesJson = defaultSchedules.map((s) => jsonEncode(s)).toList();
    await _cache.setPersistentCacheList(_keyFeedingSchedules, schedulesJson);

    return defaultSchedules;
  }
}
