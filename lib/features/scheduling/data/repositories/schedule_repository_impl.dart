import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../models/schedule_model.dart';

/// 스케줄 리포지토리 구현
class ScheduleRepositoryImpl implements ScheduleRepository {
  final List<ScheduleModel> _schedules = [];

  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 500));
    return _schedules.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByPetId(String petId) async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 300));
    return _schedules
        .where((schedule) => schedule.petId == petId)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByDate(DateTime date) async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 300));
    return _schedules
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
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 400));
    return _schedules
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
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final schedule = _schedules.firstWhere((schedule) => schedule.id == id);
      return schedule.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ScheduleEntity> createSchedule(ScheduleEntity schedule) async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 600));
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
    _schedules.add(model);
    return model.toEntity();
  }

  @override
  Future<ScheduleEntity> updateSchedule(ScheduleEntity schedule) async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
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
      _schedules[index] = updatedModel;
      return updatedModel;
    }
    throw Exception('스케줄을 찾을 수 없습니다.');
  }

  @override
  Future<void> deleteSchedule(String id) async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 400));
    _schedules.removeWhere((schedule) => schedule.id == id);
  }

  @override
  Future<ScheduleEntity> updateScheduleStatus(
    String id,
    ScheduleStatus status,
  ) async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      final originalModel = _schedules[index];
      final updatedModel = originalModel.toEntity().copyWith(status: status);
      _schedules[index] = ScheduleModel.fromEntity(updatedModel);
      return updatedModel;
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
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 300));
    return _schedules
        .where((schedule) => schedule.type == type)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getFacilityBookings() async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 400));
    return _schedules
        .where((schedule) => schedule.isFacilityBooking)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getRecurringSchedules() async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 300));
    return _schedules
        .where((schedule) => schedule.isRecurringSchedule)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesWithReminders() async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 300));
    return _schedules
        .where((schedule) => schedule.hasReminders)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> searchSchedules(String query) async {
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 400));
    final lowercaseQuery = query.toLowerCase();
    return _schedules
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
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 500));

    final totalSchedules = _schedules.length;
    final completedSchedules = _schedules.where((s) => s.isCompleted).length;
    final pendingSchedules = _schedules
        .where((s) => s.status == ScheduleStatus.pending)
        .length;
    final cancelledSchedules = _schedules.where((s) => s.isCancelled).length;
    final missedSchedules = _schedules.where((s) => s.isMissed).length;
    final todaySchedules = _schedules.where((s) => s.isToday).length;
    final tomorrowSchedules = _schedules.where((s) => s.isTomorrow).length;
    final thisWeekSchedules = _schedules.where((s) => s.isThisWeek).length;

    final schedulesByType = <ScheduleType, int>{};
    for (final type in ScheduleType.values) {
      schedulesByType[type] = _schedules.where((s) => s.type == type).length;
    }

    final schedulesByStatus = <ScheduleStatus, int>{};
    for (final status in ScheduleStatus.values) {
      schedulesByStatus[status] = _schedules
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
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 200));

    return _schedules.any((existingSchedule) {
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
    // TODO: 실제 API 호출로 대체
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      final originalModel = _schedules[index];
      final updatedModel = originalModel.toEntity().copyWith(
        status: ScheduleStatus.cancelled,
        notes: reason,
      );
      _schedules[index] = ScheduleModel.fromEntity(updatedModel);
      return updatedModel;
    }
    throw Exception('스케줄을 찾을 수 없습니다.');
  }
}
