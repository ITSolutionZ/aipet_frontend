import 'package:aipet_frontend/features/scheduling/presentation/controllers/feeding_schedule_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FeedingScheduleController controller;
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    controller = FeedingScheduleController();
  });

  tearDown(() {
    container.dispose();
  });

  group('FeedingScheduleController', () {
    group('createSchedule', () {
      test('should create feeding schedule successfully', () async {
        // Arrange
        const petId = 'pet-123';
        final scheduleData = {
          'time': '08:00',
          'amount': '1 cup',
          'feedType': 'dry food',
          'notes': 'Morning feeding',
        };

        // Act
        final result = await controller.createSchedule(petId, scheduleData);

        // Assert
        expect(result, isA<Result<Map<String, dynamic>>>());
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('급식 스케줄이 생성되었습니다'));
      });

      test('should return failure when petId is empty', () async {
        // Arrange
        const petId = '';
        final scheduleData = {
          'time': '08:00',
          'amount': '1 cup',
        };

        // Act
        final result = await controller.createSchedule(petId, scheduleData);

        // Assert
        expect(result, isA<Result<Map<String, dynamic>>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('펫 ID가 필요합니다'));
      });

      test('should return failure when required schedule data is missing', () async {
        // Arrange
        const petId = 'pet-123';
        final scheduleData = <String, dynamic>{}; // Empty data

        // Act
        final result = await controller.createSchedule(petId, scheduleData);

        // Assert
        expect(result, isA<Result<Map<String, dynamic>>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('급식 시간이 필요합니다'));
      });
    });

    group('getSchedules', () {
      test('should get feeding schedules for pet successfully', () async {
        // Arrange
        const petId = 'pet-123';

        // Act
        final result = await controller.getSchedules(petId);

        // Assert
        expect(result, isA<Result<List<Map<String, dynamic>>>>());
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('급식 스케줄을 불러왔습니다'));
      });

      test('should return empty list when no schedules found', () async {
        // Arrange
        const petId = 'pet-nonexistent';

        // Act
        final result = await controller.getSchedules(petId);

        // Assert
        expect(result, isA<Result<List<Map<String, dynamic>>>>());
        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
      });
    });

    group('updateSchedule', () {
      test('should update feeding schedule successfully', () async {
        // Arrange
        const scheduleId = 'schedule-123';
        final updateData = {
          'time': '09:00',
          'amount': '1.5 cups',
          'notes': 'Updated feeding time',
        };

        // Act
        final result = await controller.updateSchedule(scheduleId, updateData);

        // Assert
        expect(result, isA<Result<Map<String, dynamic>>>());
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('급식 스케줄이 수정되었습니다'));
      });

      test('should return failure when schedule ID is empty', () async {
        // Arrange
        const scheduleId = '';
        final updateData = {'time': '09:00'};

        // Act
        final result = await controller.updateSchedule(scheduleId, updateData);

        // Assert
        expect(result, isA<Result<Map<String, dynamic>>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('스케줄 ID가 필요합니다'));
      });
    });

    group('deleteSchedule', () {
      test('should delete feeding schedule successfully', () async {
        // Arrange
        const scheduleId = 'schedule-123';

        // Act
        final result = await controller.deleteSchedule(scheduleId);

        // Assert
        expect(result, isA<Result<void>>());
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('급식 스케줄이 삭제되었습니다'));
      });

      test('should return failure when schedule ID is empty', () async {
        // Arrange
        const scheduleId = '';

        // Act
        final result = await controller.deleteSchedule(scheduleId);

        // Assert
        expect(result, isA<Result<void>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('스케줄 ID가 필요합니다'));
      });
    });

    group('markFeedingComplete', () {
      test('should mark feeding as complete successfully', () async {
        // Arrange
        const scheduleId = 'schedule-123';
        final feedingData = {
          'actualTime': DateTime.now().toIso8601String(),
          'actualAmount': '1 cup',
          'notes': 'Fed as scheduled',
        };

        // Act
        final result = await controller.markFeedingComplete(scheduleId, feedingData);

        // Assert
        expect(result, isA<Result<Map<String, dynamic>>>());
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('급식이 완료로 표시되었습니다'));
      });
    });

    group('getUpcomingFeedings', () {
      test('should get upcoming feedings successfully', () async {
        // Arrange
        const petId = 'pet-123';

        // Act
        final result = await controller.getUpcomingFeedings(petId);

        // Assert
        expect(result, isA<Result<List<Map<String, dynamic>>>>());
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('다가오는 급식 일정을 불러왔습니다'));
      });
    });

    group('getFeedingHistory', () {
      test('should get feeding history successfully', () async {
        // Arrange
        const petId = 'pet-123';
        final startDate = DateTime.now().subtract(const Duration(days: 7));
        final endDate = DateTime.now();

        // Act
        final result = await controller.getFeedingHistory(petId, startDate, endDate);

        // Assert
        expect(result, isA<Result<List<Map<String, dynamic>>>>());
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('급식 기록을 불러왔습니다'));
      });

      test('should return failure when date range is invalid', () async {
        // Arrange
        const petId = 'pet-123';
        final startDate = DateTime.now();
        final endDate = DateTime.now().subtract(const Duration(days: 7)); // End before start

        // Act
        final result = await controller.getFeedingHistory(petId, startDate, endDate);

        // Assert
        expect(result, isA<Result<List<Map<String, dynamic>>>>());
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('날짜 범위가 올바르지 않습니다'));
      });
    });

    group('calculateFeedingStats', () {
      test('should calculate feeding statistics successfully', () async {
        // Arrange
        const petId = 'pet-123';
        final startDate = DateTime.now().subtract(const Duration(days: 30));
        final endDate = DateTime.now();

        // Act
        final result = await controller.calculateFeedingStats(petId, startDate, endDate);

        // Assert
        expect(result, isA<Result<Map<String, dynamic>>>());
        expect(result.isSuccess, isTrue);
        expect(result.message, contains('급식 통계를 계산했습니다'));
        expect(result.data, containsPair('totalFeedings', isA<int>()));
        expect(result.data, containsPair('averageDailyFeedings', isA<double>()));
        expect(result.data, containsPair('missedFeedings', isA<int>()));
      });
    });
  });
}