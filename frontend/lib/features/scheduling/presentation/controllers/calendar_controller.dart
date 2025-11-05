import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/calendar_event_service.dart';
import '../../data/services/google_calendar_service.dart';
import '../../domain/entities/calendar_event_entity.dart';


part 'calendar_controller.g.dart';

@riverpod
class CalendarController extends _$CalendarController {
  @override
  FutureOr<List<CalendarEventEntity>> build() {
    return _loadEvents();
  }

  Future<List<CalendarEventEntity>> _loadEvents() async {
    return CalendarEventService.instance.getCalendarEvents();
  }

  /// 새 이벤트 추가
  Future<void> addEvent(CalendarEventEntity event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CalendarEventService.instance.saveCalendarEvent(event);
      return _loadEvents();
    });
  }

  /// 이벤트 업데이트
  Future<void> updateEvent(CalendarEventEntity event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CalendarEventService.instance.updateCalendarEvent(event);
      return _loadEvents();
    });
  }

  /// 이벤트 삭제
  Future<void> deleteEvent(String eventId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await CalendarEventService.instance.deleteCalendarEvent(eventId);
      return _loadEvents();
    });
  }

  /// 특정 날짜의 이벤트 필터링
  List<CalendarEventEntity> getEventsForDay(DateTime day) {
    final events = state.value ?? [];
    return events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(day.year, day.month, day.day);
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Google Calendar와 동기화
  Future<void> syncWithGoogleCalendar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final googleService = GoogleCalendarService();

      if (!googleService.isAuthenticated) {
        // 인증되지 않은 경우 로컬 이벤트만 반환
        return _loadEvents();
      }

      // Google Calendar에서 이벤트 가져오기
      final googleEvents = await googleService.getEvents();

      // 로컬에 저장
      for (final event in googleEvents) {
        await CalendarEventService.instance.saveCalendarEvent(event);
      }

      return _loadEvents();
    });
  }
}
