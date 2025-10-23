import 'package:aipet_frontend/features/scheduling/data/models/schedule_model.dart';
import 'package:aipet_frontend/features/scheduling/domain/entities/schedule_entity.dart';
import 'package:aipet_frontend/features/scheduling/domain/repositories/schedule_repository.dart';
import 'package:aipet_frontend/shared/core/domain/base_repository.dart';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'schedule_repository_impl.g.dart';

/// 스케줄 리포지토리 구현
/// Hybrid 패턴: API (추후) + 로컬 저장소
class ScheduleRepositoryImpl
    with MemoryRepositoryMixin<ScheduleModel, String>
    implements ScheduleRepository {
  @override
  String getId(ScheduleModel item) => item.id;

  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    await simulateDelay();
    LoggerService.debug('✅ ScheduleRepository: ${allItems.length}개 스케줄 조회');
    return allItems.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByPetId(String petId) async {
    await simulateDelay(const Duration(milliseconds: 300));
    return allItems
        .where((schedule) => schedule.petId == petId)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByDate(DateTime date) async {
    await simulateDelay(const Duration(milliseconds: 300));
    return allItems
        .where(
          (schedule) =>
              schedule.startDateTime.year == date.year &&
              schedule.startDateTime.month == date.month &&
              schedule.startDateTime.day == date.day,
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await simulateDelay(const Duration(milliseconds: 400));
    return allItems
        .where(
          (schedule) =>
              schedule.startDateTime.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              schedule.startDateTime.isBefore(
                endDate.add(const Duration(days: 1)),
              ),
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<ScheduleEntity?> getScheduleById(String id) async {
    await simulateDelay(const Duration(milliseconds: 200));
    final schedule = findById(id);
    return schedule?.toEntity();
  }

  @override
  Future<ScheduleEntity> createSchedule(ScheduleEntity schedule) async {
    await simulateDelay(const Duration(milliseconds: 600));
    final model = ScheduleModel(
      id: schedule.id,
      title: schedule.title,
      description: schedule.description,
      startDateTime: schedule.startDateTime,
      endDateTime: schedule.endDateTime,
      duration: schedule.duration,
      type: schedule.type,
      status: schedule.status,
      priority: schedule.priority,
      petId: schedule.petId,
      petName: schedule.petName,
      petImagePath: schedule.petImagePath,
      location: schedule.location,
      latitude: schedule.latitude,
      longitude: schedule.longitude,
      facilityId: schedule.facilityId,
      facilityName: schedule.facilityName,
      staffName: schedule.staffName,
      staffPhone: schedule.staffPhone,
      price: schedule.price,
      services: schedule.services,
      hasReminder: schedule.hasReminder,
      reminderTime: schedule.reminderTime,
      reminderTimes: schedule.reminderTimes,
      isRecurring: schedule.isRecurring,
      recurrenceRule: schedule.recurrenceRule,
      notes: schedule.notes,
      specialRequests: schedule.specialRequests,
      customData: schedule.customData,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
    addItem(model);
    LoggerService.debug('✅ ScheduleRepository: 스케줄 생성 - ID: ${model.id}');
    return model.toEntity();
  }

  @override
  Future<ScheduleEntity> updateSchedule(ScheduleEntity schedule) async {
    await simulateDelay(const Duration(milliseconds: 500));
    final updatedModel = ScheduleModel(
      id: schedule.id,
      title: schedule.title,
      description: schedule.description,
      startDateTime: schedule.startDateTime,
      endDateTime: schedule.endDateTime,
      duration: schedule.duration,
      type: schedule.type,
      status: schedule.status,
      priority: schedule.priority,
      petId: schedule.petId,
      petName: schedule.petName,
      petImagePath: schedule.petImagePath,
      location: schedule.location,
      latitude: schedule.latitude,
      longitude: schedule.longitude,
      facilityId: schedule.facilityId,
      facilityName: schedule.facilityName,
      staffName: schedule.staffName,
      staffPhone: schedule.staffPhone,
      price: schedule.price,
      services: schedule.services,
      hasReminder: schedule.hasReminder,
      reminderTime: schedule.reminderTime,
      reminderTimes: schedule.reminderTimes,
      isRecurring: schedule.isRecurring,
      recurrenceRule: schedule.recurrenceRule,
      notes: schedule.notes,
      specialRequests: schedule.specialRequests,
      customData: schedule.customData,
      createdAt: schedule.createdAt,
      updatedAt: schedule.updatedAt,
    );
    updateItem(updatedModel);
    LoggerService.debug('✅ ScheduleRepository: 스케줄 업데이트 - ID: ${schedule.id}');
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await simulateDelay(const Duration(milliseconds: 400));
    removeItem(id);
    LoggerService.debug('✅ ScheduleRepository: 스케줄 삭제 - ID: $id');
  }

  @override
  Future<ScheduleEntity> updateScheduleStatus(
    String id,
    ScheduleStatus status,
  ) async {
    await simulateDelay(const Duration(milliseconds: 300));
    final originalModel = findById(id);
    if (originalModel != null) {
      final updatedEntity = originalModel.toEntity().copyWith(status: status);
      final updatedModel = ScheduleModel.fromEntity(updatedEntity);
      updateItem(updatedModel);
      LoggerService.debug('✅ ScheduleRepository: 스케줄 상태 변경 - ID: $id');
      return updatedEntity;
    }
    throw Exception('스케줄을 찾을 수 없습니다.');
  }

  @override
  Future<List<ScheduleEntity>> getTodaySchedules() async {
    final today = DateTime.now();
    return getSchedulesByDate(today);
  }

  @override
  Future<List<ScheduleEntity>> getTomorrowSchedules() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return getSchedulesByDate(tomorrow);
  }

  @override
  Future<List<ScheduleEntity>> getThisWeekSchedules() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return getSchedulesByDateRange(startOfWeek, endOfWeek);
  }

  @override
  Future<List<ScheduleEntity>> getNextWeekSchedules() async {
    final now = DateTime.now();
    final startOfNextWeek = now.add(Duration(days: 8 - now.weekday));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
    return getSchedulesByDateRange(startOfNextWeek, endOfNextWeek);
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByType(ScheduleType type) async {
    await simulateDelay(const Duration(milliseconds: 300));
    return allItems
        .where((schedule) => schedule.type == type)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getFacilityBookings() async {
    await simulateDelay(const Duration(milliseconds: 400));
    return allItems
        .where((schedule) => schedule.isFacilityBooking)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getRecurringSchedules() async {
    await simulateDelay(const Duration(milliseconds: 300));
    return allItems
        .where((schedule) => schedule.isRecurringSchedule)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesWithReminders() async {
    await simulateDelay(const Duration(milliseconds: 300));
    return allItems
        .where((schedule) => schedule.hasReminders)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> searchSchedules(String query) async {
    await simulateDelay(const Duration(milliseconds: 400));
    final lowercaseQuery = query.toLowerCase();
    return allItems
        .where(
          (schedule) =>
              schedule.title.toLowerCase().contains(lowercaseQuery) ||
              (schedule.description?.toLowerCase().contains(lowercaseQuery) ??
                  false) ||
              schedule.petName.toLowerCase().contains(lowercaseQuery) ||
              (schedule.location?.toLowerCase().contains(lowercaseQuery) ??
                  false),
        )
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<ScheduleStatistics> getScheduleStatistics() async {
    await simulateDelay();

    final totalSchedules = allItems.length;
    final completedSchedules = allItems.where((s) => s.isCompleted).length;
    final pendingSchedules = allItems
        .where((s) => s.status == ScheduleStatus.pending)
        .length;
    final cancelledSchedules = allItems.where((s) => s.isCancelled).length;
    final missedSchedules = allItems.where((s) => s.isMissed).length;
    final todaySchedules = allItems.where((s) => s.isToday).length;
    final tomorrowSchedules = allItems.where((s) => s.isTomorrow).length;
    final thisWeekSchedules = allItems.where((s) => s.isThisWeek).length;

    final schedulesByType = <ScheduleType, int>{};
    for (final type in ScheduleType.values) {
      schedulesByType[type] = allItems.where((s) => s.type == type).length;
    }

    final schedulesByStatus = <ScheduleStatus, int>{};
    for (final status in ScheduleStatus.values) {
      schedulesByStatus[status] = allItems
          .where((s) => s.status == status)
          .length;
    }

    return ScheduleStatistics(
      totalSchedules: totalSchedules,
      completedSchedules: completedSchedules,
      pendingSchedules: pendingSchedules,
      cancelledSchedules: cancelledSchedules,
      missedSchedules: missedSchedules,
      todaySchedules: todaySchedules,
      tomorrowSchedules: tomorrowSchedules,
      thisWeekSchedules: thisWeekSchedules,
      schedulesByType: schedulesByType,
      schedulesByStatus: schedulesByStatus,
    );
  }

  @override
  Future<bool> hasScheduleConflict(ScheduleEntity schedule) async {
    await simulateDelay(const Duration(milliseconds: 200));

    return allItems.any((existingSchedule) {
      if (existingSchedule.id == schedule.id) return false;
      if (existingSchedule.petId != schedule.petId) return false;

      final existingStart = existingSchedule.startDateTime;
      final existingEnd =
          existingSchedule.endDateTime ??
          existingSchedule.startDateTime.add(
            Duration(minutes: existingSchedule.totalMinutes),
          );

      final newStart = schedule.startDateTime;
      final newEnd =
          schedule.endDateTime ??
          schedule.startDateTime.add(Duration(minutes: schedule.totalMinutes));

      return (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart));
    });
  }

  @override
  Future<ScheduleEntity> markScheduleAsCompleted(String id) async {
    return updateScheduleStatus(id, ScheduleStatus.completed);
  }

  @override
  Future<ScheduleEntity> cancelSchedule(String id, String reason) async {
    await simulateDelay(const Duration(milliseconds: 400));
    final originalModel = findById(id);
    if (originalModel != null) {
      final updatedEntity = originalModel.toEntity().copyWith(
        status: ScheduleStatus.cancelled,
        notes: reason,
      );
      final updatedModel = ScheduleModel.fromEntity(updatedEntity);
      updateItem(updatedModel);
      LoggerService.debug('✅ ScheduleRepository: 스케줄 취소 - ID: $id');
      return updatedEntity;
    }
    throw Exception('스케줄을 찾을 수 없습니다.');
  }
}

/// Schedule Repository Provider
@riverpod
ScheduleRepository scheduleRepository(Ref ref) {
  return ScheduleRepositoryImpl();
}
