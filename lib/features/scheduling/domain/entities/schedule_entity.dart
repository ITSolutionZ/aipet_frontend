import 'package:flutter/material.dart';

/// 스케줄 타입
enum ScheduleType {
  // 기본 활동
  walk, // 산책
  feeding, // 급여
  medication, // 약물
  // 시설 예약
  grooming, // 미용
  medical, // 진료
  hotel, // 호텔
  daycare, // 데이케어
  training, // 훈련
  // 건강 관리
  checkup, // 검진
  vaccination, // 예방접종
  weight, // 체중 측정
  // 기타
  custom, // 사용자 정의
}

/// 스케줄 상태
enum ScheduleStatus {
  pending, // 대기중
  confirmed, // 확정
  inProgress, // 진행중
  completed, // 완료
  cancelled, // 취소
  missed, // 놓침
}

/// 스케줄 우선순위
enum SchedulePriority {
  low, // 낮음
  normal, // 보통
  high, // 높음
  urgent, // 긴급
}

/// 통합 스케줄 엔티티
class ScheduleEntity {
  final String id;
  final String title;
  final String? description;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final Duration? duration;
  final ScheduleType type;
  final ScheduleStatus status;
  final SchedulePriority priority;

  // 펫 정보
  final String petId;
  final String petName;
  final String? petImagePath;

  // 위치 정보
  final String? location;
  final double? latitude;
  final double? longitude;

  // 시설 예약 정보 (시설 예약인 경우)
  final String? facilityId;
  final String? facilityName;
  final String? staffName;
  final String? staffPhone;
  final double? price;
  final List<String>? services;

  // 알림 설정
  final bool hasReminder;
  final Duration? reminderTime;
  final List<Duration>? reminderTimes;

  // 반복 설정
  final bool isRecurring;
  final String? recurrenceRule; // RRULE 형식

  // 메타데이터
  final String? notes;
  final String? specialRequests;
  final Map<String, dynamic>? customData;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ScheduleEntity({
    required this.id,
    required this.title,
    this.description,
    required this.startDateTime,
    this.endDateTime,
    this.duration,
    required this.type,
    this.status = ScheduleStatus.pending,
    this.priority = SchedulePriority.normal,
    required this.petId,
    required this.petName,
    this.petImagePath,
    this.location,
    this.latitude,
    this.longitude,
    this.facilityId,
    this.facilityName,
    this.staffName,
    this.staffPhone,
    this.price,
    this.services,
    this.hasReminder = false,
    this.reminderTime,
    this.reminderTimes,
    this.isRecurring = false,
    this.recurrenceRule,
    this.notes,
    this.specialRequests,
    this.customData,
    required this.createdAt,
    this.updatedAt,
  });

  ScheduleEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    Duration? duration,
    ScheduleType? type,
    ScheduleStatus? status,
    SchedulePriority? priority,
    String? petId,
    String? petName,
    String? petImagePath,
    String? location,
    double? latitude,
    double? longitude,
    String? facilityId,
    String? facilityName,
    String? staffName,
    String? staffPhone,
    double? price,
    List<String>? services,
    bool? hasReminder,
    Duration? reminderTime,
    List<Duration>? reminderTimes,
    bool? isRecurring,
    String? recurrenceRule,
    String? notes,
    String? specialRequests,
    Map<String, dynamic>? customData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petImagePath: petImagePath ?? this.petImagePath,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      facilityId: facilityId ?? this.facilityId,
      facilityName: facilityName ?? this.facilityName,
      staffName: staffName ?? this.staffName,
      staffPhone: staffPhone ?? this.staffPhone,
      price: price ?? this.price,
      services: services ?? this.services,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      notes: notes ?? this.notes,
      specialRequests: specialRequests ?? this.specialRequests,
      customData: customData ?? this.customData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 스케줄 타입에 따른 색상 반환
  Color get color {
    switch (type) {
      case ScheduleType.walk:
        return Colors.green;
      case ScheduleType.feeding:
        return Colors.orange;
      case ScheduleType.medication:
        return Colors.pink;
      case ScheduleType.grooming:
        return Colors.purple;
      case ScheduleType.medical:
        return Colors.red;
      case ScheduleType.hotel:
        return Colors.blue;
      case ScheduleType.daycare:
        return Colors.cyan;
      case ScheduleType.training:
        return Colors.indigo;
      case ScheduleType.checkup:
        return Colors.amber;
      case ScheduleType.vaccination:
        return Colors.lightBlue;
      case ScheduleType.weight:
        return Colors.teal;
      case ScheduleType.custom:
        return Colors.grey;
    }
  }

  /// 스케줄 타입에 따른 아이콘 반환
  IconData get icon {
    switch (type) {
      case ScheduleType.walk:
        return Icons.directions_walk;
      case ScheduleType.feeding:
        return Icons.restaurant;
      case ScheduleType.medication:
        return Icons.medication;
      case ScheduleType.grooming:
        return Icons.content_cut;
      case ScheduleType.medical:
        return Icons.local_hospital;
      case ScheduleType.hotel:
        return Icons.hotel;
      case ScheduleType.daycare:
        return Icons.child_care;
      case ScheduleType.training:
        return Icons.school;
      case ScheduleType.checkup:
        return Icons.health_and_safety;
      case ScheduleType.vaccination:
        return Icons.vaccines;
      case ScheduleType.weight:
        return Icons.monitor_weight;
      case ScheduleType.custom:
        return Icons.event;
    }
  }

  /// 스케줄이 완료되었는지 확인
  bool get isCompleted => status == ScheduleStatus.completed;

  /// 스케줄이 취소되었는지 확인
  bool get isCancelled => status == ScheduleStatus.cancelled;

  /// 스케줄이 진행중인지 확인
  bool get isInProgress => status == ScheduleStatus.inProgress;

  /// 스케줄이 놓쳤는지 확인
  bool get isMissed => status == ScheduleStatus.missed;

  /// 스케줄이 시설 예약인지 확인
  bool get isFacilityBooking => facilityId != null;

  /// 스케줄이 반복되는지 확인
  bool get isRecurringSchedule => isRecurring && recurrenceRule != null;

  /// 스케줄이 알림이 있는지 확인
  bool get hasReminders =>
      hasReminder && (reminderTime != null || reminderTimes != null);

  /// 스케줄의 총 시간 (분)
  int get totalMinutes {
    if (endDateTime != null) {
      return endDateTime!.difference(startDateTime).inMinutes;
    }
    if (duration != null) {
      return duration!.inMinutes;
    }
    return 60; // 기본 1시간
  }

  /// 스케줄이 오늘인지 확인
  bool get isToday {
    final now = DateTime.now();
    return startDateTime.year == now.year &&
        startDateTime.month == now.month &&
        startDateTime.day == now.day;
  }

  /// 스케줄이 내일인지 확인
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return startDateTime.year == tomorrow.year &&
        startDateTime.month == tomorrow.month &&
        startDateTime.day == tomorrow.day;
  }

  /// 스케줄이 이번 주인지 확인
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return startDateTime.isAfter(
          startOfWeek.subtract(const Duration(days: 1)),
        ) &&
        startDateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ScheduleEntity(id: $id, title: $title, type: $type, status: $status, startDateTime: $startDateTime)';
  }
}
