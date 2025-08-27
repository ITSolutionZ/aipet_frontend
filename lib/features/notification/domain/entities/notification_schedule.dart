import 'notification_model.dart';

/// 알림 스케줄 타입
enum ScheduleType {
  once, // 한 번만
  daily, // 매일
  weekly, // 매주
  monthly, // 매월
  custom, // 사용자 정의
}

/// 알림 시간 클래스 (Flutter TimeOfDay와 충돌 방지)
class NotificationTimeOfDay {
  final int hour;
  final int minute;

  const NotificationTimeOfDay({required this.hour, required this.minute});

  /// 현재 시간으로 생성
  factory NotificationTimeOfDay.now() {
    final now = DateTime.now();
    return NotificationTimeOfDay(hour: now.hour, minute: now.minute);
  }

  /// 문자열로 변환 (HH:mm 형식)
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// DateTime으로 변환 (오늘 날짜 기준)
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// 다음 실행 시간 계산
  DateTime getNextExecutionTime() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, hour, minute);

    if (today.isAfter(now)) {
      return today;
    } else {
      return today.add(const Duration(days: 1));
    }
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {'hour': hour, 'minute': minute};
  }

  /// JSON에서 생성
  factory NotificationTimeOfDay.fromJson(Map<String, dynamic> json) {
    return NotificationTimeOfDay(
      hour: json['hour'] ?? 0,
      minute: json['minute'] ?? 0,
    );
  }

  @override
  String toString() {
    return toTimeString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationTimeOfDay &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

/// 알림 스케줄 모델
class NotificationSchedule {
  final String id;
  final String title;
  final String description;
  final NotificationType type;
  final ScheduleType scheduleType;
  final NotificationTimeOfDay time;
  final List<int>? weekDays; // 1=월요일, 7=일요일
  final int? dayOfMonth; // 1-31
  final bool isActive;
  final DateTime? lastExecuted;
  final DateTime? nextExecution;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const NotificationSchedule({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.scheduleType,
    required this.time,
    this.weekDays,
    this.dayOfMonth,
    this.isActive = true,
    this.lastExecuted,
    this.nextExecution,
    required this.createdAt,
    this.metadata,
  });

  /// 다음 실행 시간 계산
  DateTime calculateNextExecutionTime() {
    final now = DateTime.now();
    final baseTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    switch (scheduleType) {
      case ScheduleType.once:
        return baseTime.isAfter(now)
            ? baseTime
            : baseTime.add(const Duration(days: 1));

      case ScheduleType.daily:
        if (baseTime.isAfter(now)) {
          return baseTime;
        } else {
          return baseTime.add(const Duration(days: 1));
        }

      case ScheduleType.weekly:
        if (weekDays == null || weekDays!.isEmpty) {
          return baseTime.add(const Duration(days: 1));
        }

        // 현재 요일 (1=월요일, 7=일요일)
        final currentWeekDay = now.weekday;

        // 다음 실행할 요일 찾기
        int? nextWeekDay;
        for (final weekDay in weekDays!) {
          if (weekDay > currentWeekDay ||
              (weekDay == currentWeekDay && baseTime.isAfter(now))) {
            nextWeekDay = weekDay;
            break;
          }
        }

        // 다음 주로 넘어가야 하는 경우
        nextWeekDay ??= weekDays!.first;

        final daysToAdd = (nextWeekDay - currentWeekDay + 7) % 7;
        return baseTime.add(Duration(days: daysToAdd));

      case ScheduleType.monthly:
        if (dayOfMonth == null) {
          return baseTime.add(const Duration(days: 1));
        }

        // 이번 달의 해당 날짜
        DateTime monthlyDate;
        try {
          monthlyDate = DateTime(
            now.year,
            now.month,
            dayOfMonth!,
            time.hour,
            time.minute,
          );
        } catch (e) {
          // 해당 날짜가 존재하지 않는 경우 (예: 2월 30일)
          monthlyDate = DateTime(
            now.year,
            now.month + 1,
            1,
            time.hour,
            time.minute,
          );
        }

        if (monthlyDate.isAfter(now)) {
          return monthlyDate;
        } else {
          // 다음 달의 해당 날짜
          try {
            return DateTime(
              now.year,
              now.month + 1,
              dayOfMonth!,
              time.hour,
              time.minute,
            );
          } catch (e) {
            return DateTime(now.year, now.month + 2, 1, time.hour, time.minute);
          }
        }

      case ScheduleType.custom:
        // 사용자 정의 로직 (현재는 매일과 동일하게 처리)
        if (baseTime.isAfter(now)) {
          return baseTime;
        } else {
          return baseTime.add(const Duration(days: 1));
        }
    }
  }

  /// 스케줄이 만료되었는지 확인
  bool get isExpired {
    if (scheduleType == ScheduleType.once) {
      return lastExecuted != null;
    }
    return false;
  }

  /// 스케줄 복사본 생성
  NotificationSchedule copyWith({
    String? id,
    String? title,
    String? description,
    NotificationType? type,
    ScheduleType? scheduleType,
    NotificationTimeOfDay? time,
    List<int>? weekDays,
    int? dayOfMonth,
    bool? isActive,
    DateTime? lastExecuted,
    DateTime? nextExecution,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationSchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      scheduleType: scheduleType ?? this.scheduleType,
      time: time ?? this.time,
      weekDays: weekDays ?? this.weekDays,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      lastExecuted: lastExecuted ?? this.lastExecuted,
      nextExecution: nextExecution ?? this.nextExecution,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'scheduleType': scheduleType.name,
      'time': time.toJson(),
      'weekDays': weekDays,
      'dayOfMonth': dayOfMonth,
      'isActive': isActive,
      'lastExecuted': lastExecuted?.toIso8601String(),
      'nextExecution': nextExecution?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// JSON에서 생성
  factory NotificationSchedule.fromJson(Map<String, dynamic> json) {
    return NotificationSchedule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      scheduleType: ScheduleType.values.firstWhere(
        (e) => e.name == json['scheduleType'],
      ),
      time: NotificationTimeOfDay.fromJson(json['time']),
      weekDays: json['weekDays'] != null
          ? List<int>.from(json['weekDays'])
          : null,
      dayOfMonth: json['dayOfMonth'],
      isActive: json['isActive'] ?? true,
      lastExecuted: json['lastExecuted'] != null
          ? DateTime.parse(json['lastExecuted'])
          : null,
      nextExecution: json['nextExecution'] != null
          ? DateTime.parse(json['nextExecution'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  @override
  String toString() {
    return 'NotificationSchedule(id: $id, title: $title, type: $type, scheduleType: $scheduleType, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
