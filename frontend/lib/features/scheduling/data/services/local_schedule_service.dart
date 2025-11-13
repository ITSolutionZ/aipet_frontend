/// 스케줄 로컬 스토리지 서비스
library;
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
import 'package:aipet_frontend/shared/services/local_database_service.dart';
class LocalScheduleService {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  /// 모든 스케줄 조회
  Future<List<Map<String, dynamic>>> getAllSchedules() async {
    final db = await _dbService.database;
    return db.query(
      'schedules',
      where: 'is_enabled = ?',
      whereArgs: [1],
      orderBy: 'time ASC',
    );
  }

  /// 펫의 스케줄 조회
  Future<List<Map<String, dynamic>>> getPetSchedules(String petId) async {
    final db = await _dbService.database;
    return db.query(
      'schedules',
      where: 'pet_id = ? AND is_enabled = ?',
      whereArgs: [petId, 1],
      orderBy: 'time ASC',
    );
  }

  /// 특정 타입의 스케줄 조회
  Future<List<Map<String, dynamic>>> getSchedulesByType(String type) async {
    final db = await _dbService.database;
    return db.query(
      'schedules',
      where: 'type = ? AND is_enabled = ?',
      whereArgs: [type, 1],
      orderBy: 'time ASC',
    );
  }

  /// 스케줄 추가
  Future<String> addSchedule(Map<String, dynamic> schedule) async {
    final db = await _dbService.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();

    await db.insert('schedules', {
      'id': id,
      'pet_id': schedule['petId'],
      'type': schedule['type'],
      'title': schedule['title'],
      'time': schedule['time'],
      'repeat_type': schedule['repeatType'],
      'is_enabled': 1,
      'created_at': now,
      'updated_at': now,
    });
    return id;
  }

  /// 스케줄 업데이트
  Future<bool> updateSchedule(
    String scheduleId,
    Map<String, dynamic> schedule,
  ) async {
    final db = await _dbService.database;
    final count = await db.update(
      'schedules',
      {...schedule, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
    return count > 0;
  }

  /// 스케줄 활성화/비활성화
  Future<bool> toggleSchedule(String scheduleId, bool isEnabled) async {
    final db = await _dbService.database;
    final count = await db.update(
      'schedules',
      {
        'is_enabled': isEnabled ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
    return count > 0;
  }

  /// 스케줄 삭제
  Future<bool> deleteSchedule(String scheduleId) async {
    final db = await _dbService.database;
    final count = await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
    return count > 0;
  }

  /// 오늘의 스케줄 조회
  Future<List<Map<String, dynamic>>> getTodaySchedules() async {
    final db = await _dbService.database;
    final today = DateTime.now();
    final todayStr = DateTimeUtils.formatDateKey(today);

    return db.rawQuery(
      '''
      SELECT * FROM schedules
      WHERE is_enabled = 1
      AND (
        repeat_type = 'daily'
        OR (repeat_type = 'once' AND DATE(time) = ?)
      )
      ORDER BY time ASC
    ''',
      [todayStr],
    );
  }

  /// 다가오는 스케줄 조회
  Future<List<Map<String, dynamic>>> getUpcomingSchedules({
    int limit = 5,
  }) async {
    final db = await _dbService.database;
    final now = DateTime.now().toIso8601String();

    return db.query(
      'schedules',
      where: 'is_enabled = ? AND time >= ?',
      whereArgs: [1, now],
      orderBy: 'time ASC',
      limit: limit,
    );
  }
}
