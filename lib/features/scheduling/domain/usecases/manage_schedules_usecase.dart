import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

/// 스케줄 생성 Use Case
class CreateScheduleUseCase {
  final ScheduleRepository repository;

  CreateScheduleUseCase(this.repository);

  Future<ScheduleEntity> call(ScheduleEntity schedule) async {
    // 스케줄 충돌 확인
    final hasConflict = await repository.hasScheduleConflict(schedule);
    if (hasConflict) {
      throw Exception('スケジュールの時間が重複しています。');
    }

    return repository.createSchedule(schedule);
  }
}

/// 스케줄 업데이트 Use Case
class UpdateScheduleUseCase {
  final ScheduleRepository repository;

  UpdateScheduleUseCase(this.repository);

  Future<ScheduleEntity> call(ScheduleEntity schedule) async {
    // 스케줄 충돌 확인 (자신 제외)
    final hasConflict = await repository.hasScheduleConflict(schedule);
    if (hasConflict) {
      throw Exception('スケジュールの時間が重複しています。');
    }

    return repository.updateSchedule(schedule);
  }
}

/// 스케줄 삭제 Use Case
class DeleteScheduleUseCase {
  final ScheduleRepository repository;

  DeleteScheduleUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteSchedule(id);
  }
}

/// 스케줄 상태 업데이트 Use Case
class UpdateScheduleStatusUseCase {
  final ScheduleRepository repository;

  UpdateScheduleStatusUseCase(this.repository);

  Future<ScheduleEntity> call(String id, ScheduleStatus status) async {
    return repository.updateScheduleStatus(id, status);
  }
}

/// 스케줄 완료 처리 Use Case
class MarkScheduleAsCompletedUseCase {
  final ScheduleRepository repository;

  MarkScheduleAsCompletedUseCase(this.repository);

  Future<ScheduleEntity> call(String id) async {
    return repository.markScheduleAsCompleted(id);
  }
}

/// 스케줄 취소 처리 Use Case
class CancelScheduleUseCase {
  final ScheduleRepository repository;

  CancelScheduleUseCase(this.repository);

  Future<ScheduleEntity> call(String id, String reason) async {
    return repository.cancelSchedule(id, reason);
  }
}

/// 스케줄 충돌 확인 Use Case
class CheckScheduleConflictUseCase {
  final ScheduleRepository repository;

  CheckScheduleConflictUseCase(this.repository);

  Future<bool> call(ScheduleEntity schedule) async {
    return repository.hasScheduleConflict(schedule);
  }
}

/// 반복 스케줄 생성 Use Case
class CreateRecurringScheduleUseCase {
  final ScheduleRepository repository;

  CreateRecurringScheduleUseCase(this.repository);

  Future<List<ScheduleEntity>> call(
    ScheduleEntity baseSchedule,
    DateTime endDate,
    String recurrenceRule,
  ) async {
    final schedules = <ScheduleEntity>[];

    // RRULE 파싱 및 반복 스케줄 생성
    final parsedRule = _parseRRule(recurrenceRule);
    final occurrences = _generateOccurrences(
      baseSchedule.startDateTime,
      endDate,
      parsedRule,
    );

    for (final occurrence in occurrences) {
      final schedule = baseSchedule.copyWith(
        id: '${baseSchedule.id}_${occurrence.millisecondsSinceEpoch}',
        startDateTime: occurrence,
        endDateTime: baseSchedule.duration != null
            ? occurrence.add(baseSchedule.duration!)
            : occurrence.add(const Duration(hours: 1)),
        createdAt: DateTime.now(),
      );
      schedules.add(schedule);
    }

    for (final schedule in schedules) {
      await repository.createSchedule(schedule);
    }

    return schedules;
  }

  /// RRULE 파싱
  Map<String, dynamic> _parseRRule(String rrule) {
    final parts = rrule.split(';');
    final rule = <String, dynamic>{};

    for (final part in parts) {
      final keyValue = part.split('=');
      if (keyValue.length == 2) {
        final key = keyValue[0];
        final value = keyValue[1];

        switch (key) {
          case 'FREQ':
            rule['freq'] = value;
            break;
          case 'INTERVAL':
            rule['interval'] = int.tryParse(value) ?? 1;
            break;
          case 'BYDAY':
            rule['byday'] = value.split(',');
            break;
          case 'COUNT':
            rule['count'] = int.tryParse(value);
            break;
          case 'UNTIL':
            rule['until'] = DateTime.parse(value);
            break;
        }
      }
    }

    return rule;
  }

  /// 반복 일정 생성
  List<DateTime> _generateOccurrences(
    DateTime startDate,
    DateTime endDate,
    Map<String, dynamic> rule,
  ) {
    final occurrences = <DateTime>[startDate];
    final freq = rule['freq'] as String? ?? 'DAILY';
    final interval = rule['interval'] as int? ?? 1;
    final count = rule['count'] as int?;
    final until = rule['until'] as DateTime?;

    DateTime current = startDate;
    int generatedCount = 1;

    while (current.isBefore(endDate) &&
        (count == null || generatedCount < count) &&
        (until == null || current.isBefore(until))) {
      switch (freq) {
        case 'DAILY':
          current = current.add(Duration(days: interval));
          break;
        case 'WEEKLY':
          current = current.add(Duration(days: 7 * interval));
          break;
        case 'MONTHLY':
          current = DateTime(
            current.year,
            current.month + interval,
            current.day,
            current.hour,
            current.minute,
          );
          break;
        case 'YEARLY':
          current = DateTime(
            current.year + interval,
            current.month,
            current.day,
            current.hour,
            current.minute,
          );
          break;
      }

      if (current.isBefore(endDate)) {
        occurrences.add(current);
        generatedCount++;
      }
    }

    return occurrences;
  }
}

/// 스케줄 알림 설정 Use Case
class SetScheduleReminderUseCase {
  final ScheduleRepository repository;

  SetScheduleReminderUseCase(this.repository);

  Future<ScheduleEntity> call(
    String scheduleId,
    bool hasReminder,
    Duration? reminderTime,
    List<Duration>? reminderTimes,
  ) async {
    final schedule = await repository.getScheduleById(scheduleId);
    if (schedule == null) {
      throw Exception('スケジュールを見つけることができませんでした。');
    }

    final updatedSchedule = schedule.copyWith(
      hasReminder: hasReminder,
      reminderTime: reminderTime,
      reminderTimes: reminderTimes,
    );

    return repository.updateSchedule(updatedSchedule);
  }
}

/// 스케줄 위치 설정 Use Case
class SetScheduleLocationUseCase {
  final ScheduleRepository repository;

  SetScheduleLocationUseCase(this.repository);

  Future<ScheduleEntity> call(
    String scheduleId,
    String? location,
    double? latitude,
    double? longitude,
  ) async {
    final schedule = await repository.getScheduleById(scheduleId);
    if (schedule == null) {
      throw Exception('スケジュールを見つけることができませんでした。');
    }

    final updatedSchedule = schedule.copyWith(
      location: location,
      latitude: latitude,
      longitude: longitude,
    );

    return repository.updateSchedule(updatedSchedule);
  }
}
