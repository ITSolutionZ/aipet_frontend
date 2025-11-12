import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/shared.dart';
import '../../../../../features/scheduling/domain/entities/schedule_entity.dart';
import '../../../../../features/scheduling/domain/repositories/schedule_repository.dart';
import '../services/backend_schedule_api_service.dart';

part 'schedule_repository_impl.g.dart';

/// 스케줄 리포지토리 구현
/// Backend API를 사용하여 스케줄 데이터를 관리합니다.
class ScheduleRepositoryImpl implements ScheduleRepository {
  // 캐시된 스케줄 목록 (성능 최적화용)
  List<ScheduleEntity>? _cachedSchedules;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  /// 캐시가 유효한지 확인
  bool get _isCacheValid {
    if (_cachedSchedules == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  /// 캐시 무효화
  void _invalidateCache() {
    _cachedSchedules = null;
    _lastFetchTime = null;
  }

  /// 모든 스케줄을 가져오고 캐시에 저장
  Future<List<ScheduleEntity>> _fetchAndCacheSchedules() async {
    final result = await BackendScheduleApiService.getSchedules();
    if (result.isSuccess && result.data != null) {
      _cachedSchedules = result.data;
      _lastFetchTime = DateTime.now();
      return result.data!;
    }
    return [];
  }

  @override
  Future<List<ScheduleEntity>> getAllSchedules() async {
    LoggerService.debug('=== getAllSchedules (Backend API) called ===');
    if (_isCacheValid) {
      LoggerService.debug('✅ 캐시에서 스케줄 반환: ${_cachedSchedules!.length}개');
      return _cachedSchedules!;
    }
    return await _fetchAndCacheSchedules();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByPetId(String petId) async {
    LoggerService.debug('=== getSchedulesByPetId (Backend API) called with petId: $petId ===');
    final petIdInt = int.tryParse(petId);
    if (petIdInt == null) {
      LoggerService.error('Invalid petId format: $petId');
      return [];
    }

    final result = await BackendScheduleApiService.getSchedules(petId: petIdInt);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    return [];
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByDate(DateTime date) async {
    LoggerService.debug('=== getSchedulesByDate called for date: $date ===');
    // 전체 스케줄을 가져온 후 클라이언트 측에서 필터링
    final allSchedules = await getAllSchedules();
    return allSchedules
        .where(
          (schedule) =>
              schedule.startDateTime.year == date.year &&
              schedule.startDateTime.month == date.month &&
              schedule.startDateTime.day == date.day,
        )
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    LoggerService.debug('=== getSchedulesByDateRange called ===');
    final result = await BackendScheduleApiService.getSchedules(
      startDate: startDate,
      endDate: endDate,
    );
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    return [];
  }

  @override
  Future<ScheduleEntity?> getScheduleById(String id) async {
    LoggerService.debug('=== getScheduleById (Backend API) called with id: $id ===');
    final result = await BackendScheduleApiService.getScheduleById(id);
    if (result.isSuccess) {
      return result.data;
    }
    return null;
  }

  @override
  Future<ScheduleEntity> createSchedule(ScheduleEntity schedule) async {
    LoggerService.debug('=== createSchedule (Backend API) called ===');
    final result = await BackendScheduleApiService.createSchedule(schedule);
    if (result.isSuccess && result.data != null) {
      _invalidateCache(); // 캐시 무효화
      LoggerService.debug('✅ ScheduleRepository: 스케줄 생성 - ID: ${result.data!.id}');
      return result.data!;
    }
    throw Exception(result.message);
  }

  @override
  Future<ScheduleEntity> updateSchedule(ScheduleEntity schedule) async {
    LoggerService.debug('=== updateSchedule (Backend API) called for schedule: ${schedule.id} ===');
    final result = await BackendScheduleApiService.updateSchedule(schedule);
    if (result.isSuccess && result.data != null) {
      _invalidateCache(); // 캐시 무효화
      LoggerService.debug('✅ ScheduleRepository: 스케줄 업데이트 - ID: ${schedule.id}');
      return result.data!;
    }
    throw Exception(result.message);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    LoggerService.debug('=== deleteSchedule (Backend API) called for id: $id ===');
    final result = await BackendScheduleApiService.deleteSchedule(id);
    if (result.isSuccess) {
      _invalidateCache(); // 캐시 무효화
      LoggerService.debug('✅ ScheduleRepository: 스케줄 삭제 - ID: $id');
    } else {
      throw Exception(result.message);
    }
  }

  @override
  Future<ScheduleEntity> updateScheduleStatus(
    String id,
    ScheduleStatus status,
  ) async {
    LoggerService.debug('=== updateScheduleStatus (Backend API) called ===');
    final result = await BackendScheduleApiService.updateScheduleStatus(id, status);
    if (result.isSuccess) {
      _invalidateCache(); // 캐시 무효화
      LoggerService.debug('✅ ScheduleRepository: 스케줄 상태 변경 - ID: $id');
      // 업데이트된 스케줄 가져오기
      final updatedSchedule = await getScheduleById(id);
      if (updatedSchedule != null) {
        return updatedSchedule;
      }
    }
    throw Exception(result.message);
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
    LoggerService.debug('=== getSchedulesByType called for type: $type ===');
    final result = await BackendScheduleApiService.getSchedules(type: type);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    }
    return [];
  }

  @override
  Future<List<ScheduleEntity>> getFacilityBookings() async {
    LoggerService.debug('=== getFacilityBookings called ===');
    // 시설 예약 타입들을 모두 가져옴
    final allSchedules = await getAllSchedules();
    return allSchedules
        .where(
          (schedule) =>
              schedule.type == ScheduleType.grooming ||
              schedule.type == ScheduleType.medical ||
              schedule.type == ScheduleType.hotel ||
              schedule.type == ScheduleType.daycare ||
              schedule.type == ScheduleType.training,
        )
        .toList();
  }

  @override
  Future<List<ScheduleEntity>> getRecurringSchedules() async {
    LoggerService.debug('=== getRecurringSchedules called ===');
    // 클라이언트 측 필터링
    final allSchedules = await getAllSchedules();
    return allSchedules.where((schedule) => schedule.isRecurring).toList();
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesWithReminders() async {
    LoggerService.debug('=== getSchedulesWithReminders called ===');
    // 클라이언트 측 필터링
    final allSchedules = await getAllSchedules();
    return allSchedules.where((schedule) => schedule.hasReminder).toList();
  }

  @override
  Future<List<ScheduleEntity>> searchSchedules(String query) async {
    LoggerService.debug('=== searchSchedules called with query: $query ===');
    // 클라이언트 측 검색
    final allSchedules = await getAllSchedules();
    final lowercaseQuery = query.toLowerCase();
    return allSchedules
        .where(
          (schedule) =>
              schedule.title.toLowerCase().contains(lowercaseQuery) ||
              (schedule.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
              schedule.petName.toLowerCase().contains(lowercaseQuery) ||
              (schedule.location?.toLowerCase().contains(lowercaseQuery) ?? false),
        )
        .toList();
  }

  @override
  Future<ScheduleStatistics> getScheduleStatistics() async {
    LoggerService.debug('=== getScheduleStatistics called ===');
    final allSchedules = await getAllSchedules();

    final totalSchedules = allSchedules.length;
    final completedSchedules =
        allSchedules.where((s) => s.status == ScheduleStatus.completed).length;
    final pendingSchedules = allSchedules.where((s) => s.status == ScheduleStatus.pending).length;
    final cancelledSchedules =
        allSchedules.where((s) => s.status == ScheduleStatus.cancelled).length;
    final missedSchedules = allSchedules.where((s) => s.status == ScheduleStatus.missed).length;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final todaySchedules = allSchedules
        .where((s) =>
            s.startDateTime.year == today.year &&
            s.startDateTime.month == today.month &&
            s.startDateTime.day == today.day)
        .length;

    final tomorrowSchedules = allSchedules
        .where((s) =>
            s.startDateTime.year == tomorrow.year &&
            s.startDateTime.month == tomorrow.month &&
            s.startDateTime.day == tomorrow.day)
        .length;

    final thisWeekSchedules = allSchedules
        .where((s) => s.startDateTime.isAfter(startOfWeek) && s.startDateTime.isBefore(endOfWeek))
        .length;

    final schedulesByType = <ScheduleType, int>{};
    for (final type in ScheduleType.values) {
      schedulesByType[type] = allSchedules.where((s) => s.type == type).length;
    }

    final schedulesByStatus = <ScheduleStatus, int>{};
    for (final status in ScheduleStatus.values) {
      schedulesByStatus[status] = allSchedules.where((s) => s.status == status).length;
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
    LoggerService.debug('=== hasScheduleConflict called ===');
    // 클라이언트 측 충돌 확인
    final allSchedules = await getAllSchedules();

    return allSchedules.any((existingSchedule) {
      if (existingSchedule.id == schedule.id) return false;
      if (existingSchedule.petId != schedule.petId) return false;

      final existingStart = existingSchedule.startDateTime;
      final existingEnd = existingSchedule.endDateTime ??
          existingSchedule.startDateTime.add(
            existingSchedule.duration ?? const Duration(hours: 1),
          );

      final newStart = schedule.startDateTime;
      final newEnd = schedule.endDateTime ??
          schedule.startDateTime.add(
            schedule.duration ?? const Duration(hours: 1),
          );

      return (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart));
    });
  }

  @override
  Future<ScheduleEntity> markScheduleAsCompleted(String id) async {
    return updateScheduleStatus(id, ScheduleStatus.completed);
  }

  @override
  Future<ScheduleEntity> cancelSchedule(String id, String reason) async {
    LoggerService.debug('=== cancelSchedule (Backend API) called for id: $id ===');
    // 스케줄을 가져와서 취소 상태로 업데이트
    final schedule = await getScheduleById(id);
    if (schedule != null) {
      final updatedSchedule = schedule.copyWith(
        status: ScheduleStatus.cancelled,
        notes: reason,
      );
      return await updateSchedule(updatedSchedule);
    }
    throw Exception('스케줄을 찾을 수 없습니다.');
  }
}

/// Schedule Repository Provider
@riverpod
ScheduleRepository scheduleRepository(Ref ref) {
  return ScheduleRepositoryImpl();
}
