import 'dart:convert';

import 'package:aipet_frontend/features/scheduling/domain/entities/calendar_event_entity.dart';
import 'package:aipet_frontend/shared/core/services/firebase_token_service.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:aipet_frontend/shared/services/local_database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

/// 캘린더 이벤트 저장 서비스 (로컬 SQLite + Firebase Firestore)
class CalendarEventService {
  static CalendarEventService? _instance;
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'calendar_events';

  CalendarEventService._();

  static CalendarEventService get instance {
    _instance ??= CalendarEventService._();
    return _instance!;
  }

  String? get _currentUserId => FirebaseTokenService.getCurrentUserId();

  /// 캘린더 이벤트 저장 (로컬 + Firebase)
  Future<void> saveCalendarEvent(CalendarEventEntity event) async {
    try {
      LoggerService.debug('📝 CalendarEventService: イベント保存開始');

      // 1. 로컬 SQLite에 저장
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
        'recurrence_rule': event.recurrence != null ? jsonEncode(event.recurrence!.toJson()) : null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      LoggerService.debug('✅ ローカルDB保存成功');

      // 2. Firebase에 저장
      await _saveToFirestore(event);

      LoggerService.debug('✅ イベント保存成功: ${event.title} (ID: ${event.id})');
    } catch (e) {
      LoggerService.debug('❌ イベント保存失敗: $e');
      rethrow;
    }
  }

  /// Firebase Firestore에 이벤트 저장
  Future<void> _saveToFirestore(CalendarEventEntity event) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        LoggerService.debug('⚠️ ログインしていないため、Firebaseには保存しません');
        return;
      }

      final eventData = {
        'userId': userId,
        'title': event.title,
        'description': event.description,
        'startTime': Timestamp.fromDate(event.startTime),
        'endTime': Timestamp.fromDate(event.endTime),
        'isAllDay': event.isAllDay,
        'eventType': event.type.name,
        'petId': event.petId,
        'location': event.location,
        'hasAlarm': event.hasAlarm,
        'alarmSettings': event.alarmSettings.map((e) => e.toJson()).toList(),
        'isRecurring': event.recurrence != null,
        'recurrenceRule': event.recurrence?.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_collectionName).doc(event.id).set(eventData);
      LoggerService.debug('✅ Firebase保存成功 (ID: ${event.id})');
    } catch (e) {
      LoggerService.debug('⚠️ Firebase保存失敗 (ローカルには保存済み): $e');
      // Firebase 저장 실패해도 로컬에는 저장되어 있으므로 예외를 던지지 않음
    }
  }

  /// 캘린더 이벤트 목록 조회 (Firebase 우선, 로컬 백업)
  Future<List<CalendarEventEntity>> getCalendarEvents() async {
    LoggerService.debug('📥 CalendarEventService: イベント取得開始');

    // 1. Firebase에서 먼저 시도
    final userId = _currentUserId;
    if (userId != null) {
      try {
        final events = await _getFromFirestore(userId);
        if (events.isNotEmpty) {
          LoggerService.debug('✅ Firebaseからイベント取得成功: ${events.length}件');
          // 로컬에도 동기화
          await _syncToLocal(events);
          return events;
        }
      } catch (e) {
        LoggerService.debug('⚠️ Firebase取得失敗、ローカルから取得します: $e');
      }
    }

    // 2. 로컬에서 가져오기
    try {
      final db = await LocalDatabaseService.instance.database;

      final List<Map<String, dynamic>> maps = await db.query(
        'calendar_events',
        orderBy: 'start_time ASC',
      );

      final events = maps.map((map) => _mapToEntity(map)).toList();
      LoggerService.debug('✅ ローカルDBからイベント取得成功: ${events.length}件');
      return events;
    } catch (e) {
      LoggerService.debug('❌ イベント取得失敗: $e');
      return [];
    }
  }

  /// Firebase에서 이벤트 가져오기 (인덱스 없이)
  Future<List<CalendarEventEntity>> _getFromFirestore(String userId) async {
    // orderBy 제거하여 인덱스 없이 작동하도록 함
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .get();

    final events = snapshot.docs.map((doc) => _mapFirestoreToEntity(doc)).toList();
    // 클라이언트 측에서 정렬
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    return events;
  }

  /// Firebase 이벤트를 로컬에 동기화
  Future<void> _syncToLocal(List<CalendarEventEntity> events) async {
    try {
      final db = await _dbService.database;
      for (final event in events) {
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
          'recurrence_rule': event.recurrence != null ? jsonEncode(event.recurrence!.toJson()) : null,
          'created_at': event.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': event.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      LoggerService.debug('⚠️ ローカル同期失敗: $e');
    }
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

  /// 캘린더 이벤트 업데이트 (로컬 + Firebase)
  Future<void> updateCalendarEvent(CalendarEventEntity event) async {
    try {
      LoggerService.debug('📝 CalendarEventService: イベント更新開始 (ID: ${event.id})');

      // 1. 로컬 업데이트
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
          'recurrence_rule': event.recurrence != null ? jsonEncode(event.recurrence!.toJson()) : null,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [event.id],
      );
      LoggerService.debug('✅ ローカルDB更新成功');

      // 2. Firebase 업데이트
      await _updateInFirestore(event);

      LoggerService.debug('✅ イベント更新成功: ${event.title}');
    } catch (e) {
      LoggerService.debug('❌ イベント更新失敗: $e');
      rethrow;
    }
  }

  /// Firebase에서 이벤트 업데이트
  Future<void> _updateInFirestore(CalendarEventEntity event) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await _firestore.collection(_collectionName).doc(event.id).update({
        'title': event.title,
        'description': event.description,
        'startTime': Timestamp.fromDate(event.startTime),
        'endTime': Timestamp.fromDate(event.endTime),
        'isAllDay': event.isAllDay,
        'eventType': event.type.name,
        'petId': event.petId,
        'location': event.location,
        'hasAlarm': event.hasAlarm,
        'alarmSettings': event.alarmSettings.map((e) => e.toJson()).toList(),
        'isRecurring': event.recurrence != null,
        'recurrenceRule': event.recurrence?.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      LoggerService.debug('✅ Firebase更新成功');
    } catch (e) {
      LoggerService.debug('⚠️ Firebase更新失敗: $e');
    }
  }

  /// 캘린더 이벤트 삭제 (로컬 + Firebase)
  Future<void> deleteCalendarEvent(String eventId) async {
    try {
      LoggerService.debug('🗑️ CalendarEventService: イベント削除開始 (ID: $eventId)');

      // 1. 로컬 삭제
      final db = await LocalDatabaseService.instance.database;
      await db.delete('calendar_events', where: 'id = ?', whereArgs: [eventId]);
      LoggerService.debug('✅ ローカルDB削除成功');

      // 2. Firebase 삭제
      await _deleteFromFirestore(eventId);

      LoggerService.debug('✅ イベント削除成功');
    } catch (e) {
      LoggerService.debug('❌ イベント削除失敗: $e');
      rethrow;
    }
  }

  /// Firebase에서 이벤트 삭제
  Future<void> _deleteFromFirestore(String eventId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return;

      await _firestore.collection(_collectionName).doc(eventId).delete();
      LoggerService.debug('✅ Firebase削除成功');
    } catch (e) {
      LoggerService.debug('⚠️ Firebase削除失敗: $e');
    }
  }

  /// Map을 CalendarEventEntity로 변환 (로컬 SQLite용)
  CalendarEventEntity _mapToEntity(Map<String, dynamic> map) {
    final alarmSettingsJson = jsonDecode(map['alarm_settings'] ?? '[]') as List;
    final alarmSettings = alarmSettingsJson
        .map((json) => AlarmSetting.fromJson(json as Map<String, dynamic>))
        .toList();

    // recurrence_rule 파싱 (기존 잘못된 형식도 처리)
    CalendarEventRecurrence? recurrence;
    if (map['recurrence_rule'] != null) {
      try {
        final ruleStr = map['recurrence_rule'] as String;
        // JSON 형식인지 확인 ({}로 시작하고 "로 키를 감싸는 경우)
        if (ruleStr.startsWith('{"') || ruleStr.startsWith('{ "')) {
          recurrence = CalendarEventRecurrence.fromJson(jsonDecode(ruleStr));
        } else {
          // 기존 잘못된 형식은 무시 (다음 저장 시 올바른 형식으로 저장됨)
          LoggerService.debug('⚠️ 기존 형식의 recurrence_rule 스킵: $ruleStr');
        }
      } catch (e) {
        LoggerService.debug('⚠️ recurrence_rule 파싱 실패, 스킵: $e');
      }
    }

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
      recurrence: recurrence,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Firestore Document를 CalendarEventEntity로 변환
  CalendarEventEntity _mapFirestoreToEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final alarmSettingsList = (data['alarmSettings'] as List<dynamic>?) ?? [];
    final alarmSettings = alarmSettingsList
        .map((json) => AlarmSetting.fromJson(json as Map<String, dynamic>))
        .toList();

    return CalendarEventEntity(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      isAllDay: data['isAllDay'] ?? false,
      type: CalendarEventType.values.firstWhere(
        (e) => e.name == data['eventType'],
        orElse: () => CalendarEventType.other,
      ),
      petId: data['petId'],
      location: data['location'],
      hasAlarm: data['hasAlarm'] ?? false,
      alarmSettings: alarmSettings,
      recurrence: data['recurrenceRule'] != null
          ? CalendarEventRecurrence.fromJson(data['recurrenceRule'] as Map<String, dynamic>)
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
