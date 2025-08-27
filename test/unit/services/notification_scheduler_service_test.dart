import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/features/notification/domain/entities/notification_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationSchedule Tests', () {
    test('should create notification schedule', () {
      // Arrange
      const id = 'test_schedule_id';
      const title = '테스트 스케줄';
      const description = '테스트용 스케줄입니다';
      const type = NotificationType.general;
      const scheduleType = ScheduleType.daily;
      const time = NotificationTimeOfDay(hour: 9, minute: 0);
      final createdAt = DateTime.now();

      // Act
      final schedule = NotificationSchedule(
        id: id,
        title: title,
        description: description,
        type: type,
        scheduleType: scheduleType,
        time: time,
        createdAt: createdAt,
      );

      // Assert
      expect(schedule.id, equals(id));
      expect(schedule.title, equals(title));
      expect(schedule.description, equals(description));
      expect(schedule.type, equals(type));
      expect(schedule.scheduleType, equals(scheduleType));
      expect(schedule.time, equals(time));
      expect(schedule.isActive, isTrue);
      expect(schedule.createdAt, equals(createdAt));
    });

    test('should calculate next execution time for daily schedule', () {
      // Arrange
      final now = DateTime.now();
      final time = NotificationTimeOfDay(hour: now.hour, minute: now.minute);
      final schedule = NotificationSchedule(
        id: 'test',
        title: '테스트',
        description: '테스트',
        type: NotificationType.general,
        scheduleType: ScheduleType.daily,
        time: time,
        createdAt: DateTime.now(),
      );

      // Act
      final nextExecution = schedule.calculateNextExecutionTime();

      // Assert
      expect(nextExecution, isA<DateTime>());
      expect(nextExecution.isAfter(now), isTrue);
    });

    test('should calculate next execution time for weekly schedule', () {
      // Arrange
      final now = DateTime.now();
      final time = NotificationTimeOfDay(
        hour: now.hour + 1,
        minute: now.minute,
      ); // 1시간 후
      final schedule = NotificationSchedule(
        id: 'test',
        title: '테스트',
        description: '테스트',
        type: NotificationType.general,
        scheduleType: ScheduleType.weekly,
        time: time,
        weekDays: [now.weekday], // 오늘 요일
        createdAt: DateTime.now(),
      );

      // Act
      final nextExecution = schedule.calculateNextExecutionTime();

      // Assert
      expect(nextExecution, isA<DateTime>());
      expect(nextExecution.isAfter(now), isTrue);
    });

    test('should calculate next execution time for monthly schedule', () {
      // Arrange
      final now = DateTime.now();
      const time = NotificationTimeOfDay(hour: 9, minute: 0);
      final schedule = NotificationSchedule(
        id: 'test',
        title: '테스트',
        description: '테스트',
        type: NotificationType.general,
        scheduleType: ScheduleType.monthly,
        time: time,
        dayOfMonth: now.day,
        createdAt: DateTime.now(),
      );

      // Act
      final nextExecution = schedule.calculateNextExecutionTime();

      // Assert
      expect(nextExecution, isA<DateTime>());
      expect(nextExecution.isAfter(now), isTrue);
    });

    test('should check if schedule is expired', () {
      // Arrange
      final schedule = NotificationSchedule(
        id: 'test',
        title: '테스트',
        description: '테스트',
        type: NotificationType.general,
        scheduleType: ScheduleType.once,
        time: const NotificationTimeOfDay(hour: 9, minute: 0),
        lastExecuted: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(schedule.isExpired, isTrue);
    });

    test('should convert to and from JSON', () {
      // Arrange
      final originalSchedule = NotificationSchedule(
        id: 'test_id',
        title: '테스트 스케줄',
        description: '테스트용 스케줄',
        type: NotificationType.general,
        scheduleType: ScheduleType.daily,
        time: const NotificationTimeOfDay(hour: 9, minute: 30),
        weekDays: [1, 3, 5],
        dayOfMonth: 15,
        isActive: true,
        lastExecuted: DateTime.now(),
        nextExecution: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        metadata: {'key': 'value'},
      );

      // Act
      final json = originalSchedule.toJson();
      final fromJson = NotificationSchedule.fromJson(json);

      // Assert
      expect(fromJson.id, equals(originalSchedule.id));
      expect(fromJson.title, equals(originalSchedule.title));
      expect(fromJson.description, equals(originalSchedule.description));
      expect(fromJson.type, equals(originalSchedule.type));
      expect(fromJson.scheduleType, equals(originalSchedule.scheduleType));
      expect(fromJson.time.hour, equals(originalSchedule.time.hour));
      expect(fromJson.time.minute, equals(originalSchedule.time.minute));
      expect(fromJson.weekDays, equals(originalSchedule.weekDays));
      expect(fromJson.dayOfMonth, equals(originalSchedule.dayOfMonth));
      expect(fromJson.isActive, equals(originalSchedule.isActive));
      expect(fromJson.metadata, equals(originalSchedule.metadata));
    });
  });

  group('NotificationTimeOfDay Tests', () {
    test('should create time of day', () {
      // Arrange & Act
      const time = NotificationTimeOfDay(hour: 14, minute: 30);

      // Assert
      expect(time.hour, equals(14));
      expect(time.minute, equals(30));
    });

    test('should convert to time string', () {
      // Arrange
      const time = NotificationTimeOfDay(hour: 9, minute: 5);

      // Act
      final timeString = time.toTimeString();

      // Assert
      expect(timeString, equals('09:05'));
    });

    test('should convert to DateTime', () {
      // Arrange
      const time = NotificationTimeOfDay(hour: 15, minute: 30);
      final now = DateTime.now();

      // Act
      final dateTime = time.toDateTime();

      // Assert
      expect(dateTime.hour, equals(15));
      expect(dateTime.minute, equals(30));
      expect(dateTime.year, equals(now.year));
      expect(dateTime.month, equals(now.month));
      expect(dateTime.day, equals(now.day));
    });

    test('should calculate next execution time', () {
      // Arrange
      final now = DateTime.now();
      final time = NotificationTimeOfDay(hour: now.hour, minute: now.minute);

      // Act
      final nextExecution = time.getNextExecutionTime();

      // Assert
      expect(nextExecution, isA<DateTime>());
      expect(nextExecution.isAfter(now), isTrue);
    });

    test('should convert to and from JSON', () {
      // Arrange
      const originalTime = NotificationTimeOfDay(hour: 12, minute: 45);

      // Act
      final json = originalTime.toJson();
      final fromJson = NotificationTimeOfDay.fromJson(json);

      // Assert
      expect(fromJson.hour, equals(originalTime.hour));
      expect(fromJson.minute, equals(originalTime.minute));
    });

    test('should create from now', () {
      // Act
      final now = NotificationTimeOfDay.now();
      final currentTime = DateTime.now();

      // Assert
      expect(now.hour, equals(currentTime.hour));
      expect(now.minute, equals(currentTime.minute));
    });
  });

  group('ScheduleType Tests', () {
    test('should have correct schedule type values', () {
      // Assert
      expect(ScheduleType.once, isNotNull);
      expect(ScheduleType.daily, isNotNull);
      expect(ScheduleType.weekly, isNotNull);
      expect(ScheduleType.monthly, isNotNull);
      expect(ScheduleType.custom, isNotNull);
    });
  });
}
