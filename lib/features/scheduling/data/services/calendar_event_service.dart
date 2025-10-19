import 'dart:convert';

import 'package:aipet_frontend/features/scheduling/domain/entities/calendar_event_entity.dart';
import 'package:aipet_frontend/shared/services/local_database_service.dart';
import 'package:sqflite/sqflite.dart';

/// 캘린더 이벤트 로컬 저장 서비스
class CalendarEventService {
  static CalendarEventService? _instance;
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  CalendarEventService._();

  static CalendarEventService get instance {
    _instance ??= CalendarEventService._();
    return _instance!;
  }

  /// 캘린더 이벤트 저장
  Future<void> saveCalendarEvent(CalendarEventEntity event) async {
    final db = await _dbService.database;

    await db.insert('calendar_events', {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'start_time': event.startTime.toIso8601String(),
      'end_time': event.endTime.toIso8601String(),
      'is_all_day': event.isAllDay == true ? 1 : 0,
      'event_type': event.type.name,
      'pet_id': event.petId,
      'location': event.location,
      'has_alarm': event.hasAlarm ? 1 : 0,
      'alarm_settings': jsonEncode(
        event.alarmSettings.map((e) => e.toJson()).toList(),
      ),
      'is_recurring': event.recurrence != null ? 1 : 0,
      'recurrence_rule': event.recurrence?.toJson().toString(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 캘린더 이벤트 목록 조회
  Future<List<CalendarEventEntity>> getCalendarEvents() async {
    final db = await LocalDatabaseService.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'calendar_events',
      orderBy: 'start_time ASC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  /// 특정 날짜의 캘린더 이벤트 조회
  Future<List<CalendarEventEntity>> getCalendarEventsForDate(
    DateTime date,
  ) async {
    final db = await LocalDatabaseService.instance.database;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'calendar_events',
      where: 'start_time >= ? AND start_time < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'start_time ASC',
    );

    return maps.map((map) => _mapToEntity(map)).toList();
  }

  /// 캘린더 이벤트 업데이트
  Future<void> updateCalendarEvent(CalendarEventEntity event) async {
    final db = await LocalDatabaseService.instance.database;

    await db.update(
      'calendar_events',
      {
        'title': event.title,
        'description': event.description,
        'start_time': event.startTime.toIso8601String(),
        'end_time': event.endTime.toIso8601String(),
        'is_all_day': event.isAllDay == true ? 1 : 0,
        'event_type': event.type.name,
        'pet_id': event.petId,
        'location': event.location,
        'has_alarm': event.hasAlarm ? 1 : 0,
        'alarm_settings': jsonEncode(
          event.alarmSettings.map((e) => e.toJson()).toList(),
        ),
        'is_recurring': event.recurrence != null ? 1 : 0,
        'recurrence_rule': event.recurrence?.toJson().toString(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// 캘린더 이벤트 삭제
  Future<void> deleteCalendarEvent(String eventId) async {
    final db = await LocalDatabaseService.instance.database;

    await db.delete('calendar_events', where: 'id = ?', whereArgs: [eventId]);
  }

  /// Map을 CalendarEventEntity로 변환
  CalendarEventEntity _mapToEntity(Map<String, dynamic> map) {
    final alarmSettingsJson = jsonDecode(map['alarm_settings'] ?? '[]') as List;
    final alarmSettings = alarmSettingsJson
        .map((json) => AlarmSetting.fromJson(json as Map<String, dynamic>))
        .toList();

    return CalendarEventEntity(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      isAllDay: map['is_all_day'] == 1,
      type: CalendarEventType.values.firstWhere(
        (e) => e.name == map['event_type'],
        orElse: () => CalendarEventType.other,
      ),
      petId: map['pet_id'],
      location: map['location'],
      hasAlarm: map['has_alarm'] == 1,
      alarmSettings: alarmSettings,
      recurrence: map['recurrence_rule'] != null
          ? CalendarEventRecurrence.fromJson(jsonDecode(map['recurrence_rule']))
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
