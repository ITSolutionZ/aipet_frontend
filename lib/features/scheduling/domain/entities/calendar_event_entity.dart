import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event_entity.freezed.dart';
part 'calendar_event_entity.g.dart';

@freezed
class CalendarEventEntity with _$CalendarEventEntity {
  const factory CalendarEventEntity({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required CalendarEventType type,
    String? petId,
    String? petName,
    String? location,
    bool? isAllDay,
    CalendarEventRecurrence? recurrence,
    List<String>? attendees,
    Map<String, dynamic>? metadata,
    @Default(false) bool isSyncedWithGoogle,
    String? googleEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CalendarEventEntity;

  factory CalendarEventEntity.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventEntityFromJson(json);
}

@freezed
class CalendarEventRecurrence with _$CalendarEventRecurrence {
  const factory CalendarEventRecurrence({
    required CalendarRecurrenceType type,
    int? interval,
    List<int>? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
    int? count,
  }) = _CalendarEventRecurrence;

  factory CalendarEventRecurrence.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventRecurrenceFromJson(json);
}

enum CalendarEventType {
  feeding,
  watering,
  medication,
  exercise,
  grooming,
  veterinary,
  training,
  other,
}

enum CalendarRecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}

extension CalendarEventTypeExtension on CalendarEventType {
  String get displayName {
    switch (this) {
      case CalendarEventType.feeding:
        return '食事';
      case CalendarEventType.watering:
        return '給水';
      case CalendarEventType.medication:
        return '薬';
      case CalendarEventType.exercise:
        return '運動';
      case CalendarEventType.grooming:
        return 'グルーミング';
      case CalendarEventType.veterinary:
        return '獣医';
      case CalendarEventType.training:
        return 'トレーニング';
      case CalendarEventType.other:
        return 'その他';
    }
  }

  String get emoji {
    switch (this) {
      case CalendarEventType.feeding:
        return '🍽️';
      case CalendarEventType.watering:
        return '💧';
      case CalendarEventType.medication:
        return '💊';
      case CalendarEventType.exercise:
        return '🏃';
      case CalendarEventType.grooming:
        return '✂️';
      case CalendarEventType.veterinary:
        return '🏥';
      case CalendarEventType.training:
        return '🎓';
      case CalendarEventType.other:
        return '📝';
    }
  }
}