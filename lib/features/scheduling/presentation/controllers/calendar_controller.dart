import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/calendar_event_entity.dart';

part 'calendar_controller.g.dart';

@riverpod
class CalendarController extends _$CalendarController {
  @override
  FutureOr<List<CalendarEventEntity>> build() {
    return _loadEvents();
  }

  Future<List<CalendarEventEntity>> _loadEvents() async {
    // TODO: 실제 로컬/리모트 데이터 로딩 구현
    // 현재는 빈 리스트 반환
    return [];
  }

  /// 새 이벤트 추가
  Future<void> addEvent(CalendarEventEntity event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: 실제 저장 로직 구현
      final currentEvents = state.value ?? [];
      return [...currentEvents, event];
    });
  }

  /// 이벤트 업데이트
  Future<void> updateEvent(CalendarEventEntity event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: 실제 업데이트 로직 구현
      final currentEvents = state.value ?? [];
      final index = currentEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        final updatedEvents = [...currentEvents];
        updatedEvents[index] = event;
        return updatedEvents;
      }
      return currentEvents;
    });
  }

  /// 이벤트 삭제
  Future<void> deleteEvent(String eventId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: 실제 삭제 로직 구현
      final currentEvents = state.value ?? [];
      return currentEvents.where((e) => e.id != eventId).toList();
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
      // TODO: Google Calendar 동기화 로직 구현
      // GoogleCalendarService를 사용한 동기화
      final currentEvents = state.value ?? [];
      return currentEvents;
    });
  }
}
