import 'dart:developer';

import 'package:googleapis/calendar/v3.dart' as calendar;

import '../../domain/entities/calendar_event_entity.dart';

/// Google Calendar Service
/// 현재는 로컬 유저만 사용하므로, 향후 기능 확장을 위해 구조만 유지
class GoogleCalendarService {
  calendar.CalendarApi? _calendarApi;

  GoogleCalendarService() {
    log('🔐 Google Calendar Service initialized');
  }

  /// 인증 상태 확인
  bool get isAuthenticated => _calendarApi != null;

  /// 로그아웃
  Future<void> signOut() async {
    try {
      _calendarApi = null;
      log('✅ Signed out from Google');
    } catch (e) {
      log('❌ Sign out failed: $e');
    }
  }

  /// Google Calendar에서 이벤트 목록 가져오기
  Future<List<CalendarEventEntity>> getEvents({
    DateTime? startTime,
    DateTime? endTime,
    int? maxResults = 100,
  }) async {
    if (_calendarApi == null) {
      throw Exception('Google Calendar API not authenticated');
    }

    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: startTime ?? DateTime.now().subtract(const Duration(days: 30)),
        timeMax: endTime ?? DateTime.now().add(const Duration(days: 30)),
        maxResults: maxResults,
        singleEvents: true,
        orderBy: 'startTime',
      );

      return events.items
              ?.map((event) => _convertToCalendarEvent(event))
              .toList() ??
          [];
    } catch (e) {
      log('Failed to fetch Google Calendar events: $e');
      rethrow;
    }
  }

  /// Google Calendar에 이벤트 생성
  Future<String?> createEvent(CalendarEventEntity event) async {
    if (_calendarApi == null) {
      throw Exception('Google Calendar API not authenticated');
    }

    try {
      final googleEvent = _convertToGoogleEvent(event);
      final createdEvent = await _calendarApi!.events.insert(
        googleEvent,
        'primary',
      );

      log('Event created successfully: ${createdEvent.id}');
      return createdEvent.id;
    } catch (e) {
      log('Failed to create Google Calendar event: $e');
      rethrow;
    }
  }

  /// Google Calendar 이벤트 업데이트
  Future<void> updateEvent(CalendarEventEntity event) async {
    if (_calendarApi == null) {
      throw Exception('Google Calendar API not authenticated');
    }

    if (event.googleEventId == null) {
      throw Exception('Google event ID is required for update');
    }

    try {
      final googleEvent = _convertToGoogleEvent(event);
      await _calendarApi!.events.update(
        googleEvent,
        'primary',
        event.googleEventId!,
      );
      log('Event updated successfully: ${event.googleEventId}');
    } catch (e) {
      log('Failed to update Google Calendar event: $e');
      rethrow;
    }
  }

  /// Google Calendar 이벤트 삭제
  Future<void> deleteEvent(String googleEventId) async {
    if (_calendarApi == null) {
      throw Exception('Google Calendar API not authenticated');
    }

    try {
      await _calendarApi!.events.delete('primary', googleEventId);
      log('Event deleted successfully: $googleEventId');
    } catch (e) {
      log('Failed to delete Google Calendar event: $e');
      rethrow;
    }
  }

  /// Google Calendar Event를 CalendarEventEntity로 변환
  CalendarEventEntity _convertToCalendarEvent(calendar.Event googleEvent) {
    final startTime =
        googleEvent.start?.dateTime ??
        googleEvent.start?.date ??
        DateTime.now();
    final endTime =
        googleEvent.end?.dateTime ??
        googleEvent.end?.date ??
        startTime.add(const Duration(hours: 1));

    return CalendarEventEntity(
      id: googleEvent.id ?? '',
      title: googleEvent.summary ?? '',
      description: googleEvent.description ?? '',
      startTime: startTime,
      endTime: endTime,
      type: _parseEventType(googleEvent.summary ?? ''),
      location: googleEvent.location,
      isAllDay: googleEvent.start?.date != null,
      isSyncedWithGoogle: true,
      googleEventId: googleEvent.id,
      createdAt: googleEvent.created,
      updatedAt: googleEvent.updated,
    );
  }

  /// CalendarEventEntity를 Google Calendar Event로 변환
  calendar.Event _convertToGoogleEvent(CalendarEventEntity event) {
    final googleEvent = calendar.Event();

    googleEvent.summary = event.title;
    googleEvent.description = event.description;
    googleEvent.location = event.location;

    if (event.isAllDay == true) {
      // 하루 종일 이벤트의 경우 날짜만 설정 (시간을 00:00:00으로 설정)
      final startDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final endDate = DateTime(
        event.endTime.year,
        event.endTime.month,
        event.endTime.day,
      );

      googleEvent.start = calendar.EventDateTime(dateTime: startDate);
      googleEvent.end = calendar.EventDateTime(dateTime: endDate);
    } else {
      googleEvent.start = calendar.EventDateTime(dateTime: event.startTime);
      googleEvent.end = calendar.EventDateTime(dateTime: event.endTime);
    }

    // 반복 설정
    if (event.recurrence != null) {
      googleEvent.recurrence = [_buildRecurrenceRule(event.recurrence!)];
    }

    return googleEvent;
  }

  /// 이벤트 제목에서 타입 추론
  CalendarEventType _parseEventType(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('食事') ||
        lowerTitle.contains('feeding') ||
        lowerTitle.contains('meal')) {
      return CalendarEventType.feeding;
    } else if (lowerTitle.contains('水') || lowerTitle.contains('water')) {
      return CalendarEventType.watering;
    } else if (lowerTitle.contains('薬') ||
        lowerTitle.contains('medication') ||
        lowerTitle.contains('medicine')) {
      return CalendarEventType.medication;
    } else if (lowerTitle.contains('運動') ||
        lowerTitle.contains('exercise') ||
        lowerTitle.contains('walk')) {
      return CalendarEventType.exercise;
    } else if (lowerTitle.contains('グルーミング') ||
        lowerTitle.contains('grooming')) {
      return CalendarEventType.grooming;
    } else if (lowerTitle.contains('獣医') ||
        lowerTitle.contains('vet') ||
        lowerTitle.contains('doctor')) {
      return CalendarEventType.veterinary;
    } else if (lowerTitle.contains('トレーニング') ||
        lowerTitle.contains('training')) {
      return CalendarEventType.training;
    }

    return CalendarEventType.other;
  }

  /// 반복 규칙 생성
  String _buildRecurrenceRule(CalendarEventRecurrence recurrence) {
    String rule = 'RRULE:FREQ=';

    switch (recurrence.type) {
      case CalendarRecurrenceType.daily:
        rule += 'DAILY';
        break;
      case CalendarRecurrenceType.weekly:
        rule += 'WEEKLY';
        break;
      case CalendarRecurrenceType.monthly:
        rule += 'MONTHLY';
        break;
      case CalendarRecurrenceType.yearly:
        rule += 'YEARLY';
        break;
    }

    if (recurrence.interval != null && recurrence.interval! > 1) {
      rule += ';INTERVAL=${recurrence.interval}';
    }

    if (recurrence.count != null) {
      rule += ';COUNT=${recurrence.count}';
    } else if (recurrence.endDate != null) {
      final endDateStr = recurrence.endDate!
          .toUtc()
          .toIso8601String()
          .replaceAll(RegExp(r'[-:]'), '')
          .split('T')[0];
      rule += ';UNTIL=${endDateStr}T235959Z';
    }

    if (recurrence.daysOfWeek != null && recurrence.daysOfWeek!.isNotEmpty) {
      final days = recurrence.daysOfWeek!
          .map((day) {
            switch (day) {
              case 1:
                return 'MO';
              case 2:
                return 'TU';
              case 3:
                return 'WE';
              case 4:
                return 'TH';
              case 5:
                return 'FR';
              case 6:
                return 'SA';
              case 7:
                return 'SU';
              default:
                return 'MO';
            }
          })
          .join(',');
      rule += ';BYDAY=$days';
    }

    return rule;
  }
}
