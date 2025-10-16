import 'package:flutter/material.dart';
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
    // アラーム設定
    @Default(false) bool hasAlarm,
    @Default([]) List<AlarmSetting> alarmSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CalendarEventEntity;

  factory CalendarEventEntity.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventEntityFromJson(json);

  /// 이벤트 타입에 따른 기본 알람 설정이 적용된 팩토리 생성자
  factory CalendarEventEntity.withDefaultAlarms({
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
    bool isSyncedWithGoogle = false,
    String? googleEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final shouldHaveAlarm = shouldHaveDefaultAlarm(type);
    final defaultAlarms = shouldHaveAlarm
        ? getDefaultAlarmsForType(type)
        : <AlarmSetting>[];

    return CalendarEventEntity(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      type: type,
      petId: petId,
      petName: petName,
      location: location,
      isAllDay: isAllDay,
      recurrence: recurrence,
      attendees: attendees,
      metadata: metadata,
      isSyncedWithGoogle: isSyncedWithGoogle,
      googleEventId: googleEventId,
      hasAlarm: shouldHaveAlarm,
      alarmSettings: defaultAlarms,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 이벤트 타입에 따라 기본 알람이 필요한지 확인
  static bool shouldHaveDefaultAlarm(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.feeding:
      case CalendarEventType.medication:
      case CalendarEventType.walking:
      case CalendarEventType.exercise:
        return true;
      default:
        return false;
    }
  }

  /// 이벤트 타입에 따른 기본 알람 설정 반환
  static List<AlarmSetting> getDefaultAlarmsForType(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.feeding:
        return [
          const AlarmSetting(minutesBefore: 0), // 식사 시간에 정확히
        ];
      case CalendarEventType.medication:
        return [
          const AlarmSetting(minutesBefore: 0), // 복용 시간에 정확히
        ];
      case CalendarEventType.walking:
        return [
          const AlarmSetting(minutesBefore: 10), // 10분 전 준비 알림
        ];
      case CalendarEventType.exercise:
        return [
          const AlarmSetting(minutesBefore: 15), // 15분 전 준비 알림
        ];
      default:
        return [];
    }
  }
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

@freezed
class AlarmSetting with _$AlarmSetting {
  const factory AlarmSetting({
    required int minutesBefore,
    @Default(AlarmType.notification) AlarmType type,
    @Default(true) bool isEnabled,
    String? soundPath,
    String? message,
  }) = _AlarmSetting;

  factory AlarmSetting.fromJson(Map<String, dynamic> json) =>
      _$AlarmSettingFromJson(json);
}

enum CalendarEventType {
  feeding, // 食事アラーム
  medication, // 薬アラーム
  walking, // 散歩アラーム
  exercise, // 運動アラーム
  system, // システムアラーム
  watering, // 給水
  grooming, // グルーミング
  veterinary, // 獣医
  training, // トレーニング
  other, // その他
}

enum CalendarRecurrenceType { daily, weekly, monthly, yearly }

enum AlarmType { notification, sound, vibration, soundAndVibration }

/// 알람 카테고리 (푸시 알림 설정 화면의 분류)
enum AlarmCategory {
  meal, // 食事アラーム (feeding, medication)
  walk, // 散歩アラーム (walking, exercise)
  system, // システムアラーム (system, veterinary, training, watering, grooming, other)
}

extension CalendarEventTypeExtension on CalendarEventType {
  String get displayName {
    switch (this) {
      case CalendarEventType.feeding:
        return '食事';
      case CalendarEventType.medication:
        return '薬';
      case CalendarEventType.walking:
        return '散歩';
      case CalendarEventType.exercise:
        return '運動';
      case CalendarEventType.system:
        return 'システム';
      case CalendarEventType.watering:
        return '給水';
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

  /// 알람 카테고리 분류
  AlarmCategory get alarmCategory {
    switch (this) {
      case CalendarEventType.feeding:
      case CalendarEventType.medication:
        return AlarmCategory.meal; // 食事アラーム
      case CalendarEventType.walking:
      case CalendarEventType.exercise:
        return AlarmCategory.walk; // 散歩アラーム
      case CalendarEventType.system:
      case CalendarEventType.veterinary:
      case CalendarEventType.training:
        return AlarmCategory.system; // システムアラーム
      case CalendarEventType.watering:
      case CalendarEventType.grooming:
      case CalendarEventType.other:
        return AlarmCategory.system; // その他はシステムに分類
    }
  }

  /// 알람이 필요한 이벤트 타입인지 확인
  bool get needsAlarm {
    switch (this) {
      case CalendarEventType.feeding:
      case CalendarEventType.medication:
      case CalendarEventType.walking:
      case CalendarEventType.exercise:
      case CalendarEventType.system:
        return true;
      default:
        return false;
    }
  }

  String get emoji {
    switch (this) {
      case CalendarEventType.feeding:
        return '🍽️';
      case CalendarEventType.medication:
        return '💊';
      case CalendarEventType.walking:
        return '🚶';
      case CalendarEventType.exercise:
        return '🏃';
      case CalendarEventType.system:
        return '⚙️';
      case CalendarEventType.watering:
        return '💧';
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

extension AlarmTypeExtension on AlarmType {
  String get displayName {
    switch (this) {
      case AlarmType.notification:
        return '通知のみ';
      case AlarmType.sound:
        return 'サウンド';
      case AlarmType.vibration:
        return 'バイブレーション';
      case AlarmType.soundAndVibration:
        return 'サウンド+バイブレーション';
    }
  }

  IconData get icon {
    switch (this) {
      case AlarmType.notification:
        return Icons.notifications;
      case AlarmType.sound:
        return Icons.volume_up;
      case AlarmType.vibration:
        return Icons.vibration;
      case AlarmType.soundAndVibration:
        return Icons.notification_important;
    }
  }
}

extension AlarmCategoryExtension on AlarmCategory {
  String get displayName {
    switch (this) {
      case AlarmCategory.meal:
        return '食事アラーム';
      case AlarmCategory.walk:
        return '散歩アラーム';
      case AlarmCategory.system:
        return 'システムアラーム';
    }
  }

  String get description {
    switch (this) {
      case AlarmCategory.meal:
        return '食事給与時間をお知らせいたします';
      case AlarmCategory.walk:
        return '決めた時間に散歩時間をわかるように';
      case AlarmCategory.system:
        return '予約などをお知らせいたします';
    }
  }

  IconData get icon {
    switch (this) {
      case AlarmCategory.meal:
        return Icons.restaurant;
      case AlarmCategory.walk:
        return Icons.pets;
      case AlarmCategory.system:
        return Icons.notifications;
    }
  }
}

extension AlarmSettingExtension on AlarmSetting {
  String get displayText {
    if (minutesBefore == 0) {
      return 'イベント時刻';
    } else if (minutesBefore < 60) {
      return '$minutesBefore分前';
    } else {
      final hours = minutesBefore ~/ 60;
      return '$hours時間前';
    }
  }

  static List<AlarmSetting> get presets => [
    const AlarmSetting(minutesBefore: 0), // イベント時刻
    const AlarmSetting(minutesBefore: 5), // 5分前
    const AlarmSetting(minutesBefore: 10), // 10分前
    const AlarmSetting(minutesBefore: 15), // 15分前
    const AlarmSetting(minutesBefore: 30), // 30分前
    const AlarmSetting(minutesBefore: 60), // 1時間前
    const AlarmSetting(minutesBefore: 120), // 2時間前
  ];
}
