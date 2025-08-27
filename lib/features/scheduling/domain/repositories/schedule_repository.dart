import '../entities/schedule_entity.dart';

/// 스케줄 리포지토리 인터페이스
abstract class ScheduleRepository {
  /// 모든 스케줄 가져오기
  Future<List<ScheduleEntity>> getAllSchedules();

  /// 특정 펫의 스케줄 가져오기
  Future<List<ScheduleEntity>> getSchedulesByPetId(String petId);

  /// 특정 날짜의 스케줄 가져오기
  Future<List<ScheduleEntity>> getSchedulesByDate(DateTime date);

  /// 특정 기간의 스케줄 가져오기
  Future<List<ScheduleEntity>> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// 특정 스케줄 가져오기
  Future<ScheduleEntity?> getScheduleById(String id);

  /// 스케줄 생성
  Future<ScheduleEntity> createSchedule(ScheduleEntity schedule);

  /// 스케줄 업데이트
  Future<ScheduleEntity> updateSchedule(ScheduleEntity schedule);

  /// 스케줄 삭제
  Future<void> deleteSchedule(String id);

  /// 스케줄 상태 업데이트
  Future<ScheduleEntity> updateScheduleStatus(String id, ScheduleStatus status);

  /// 오늘의 스케줄 가져오기
  Future<List<ScheduleEntity>> getTodaySchedules();

  /// 내일의 스케줄 가져오기
  Future<List<ScheduleEntity>> getTomorrowSchedules();

  /// 이번 주 스케줄 가져오기
  Future<List<ScheduleEntity>> getThisWeekSchedules();

  /// 다음 주 스케줄 가져오기
  Future<List<ScheduleEntity>> getNextWeekSchedules();

  /// 특정 타입의 스케줄 가져오기
  Future<List<ScheduleEntity>> getSchedulesByType(ScheduleType type);

  /// 시설 예약 스케줄 가져오기
  Future<List<ScheduleEntity>> getFacilityBookings();

  /// 반복 스케줄 가져오기
  Future<List<ScheduleEntity>> getRecurringSchedules();

  /// 알림이 있는 스케줄 가져오기
  Future<List<ScheduleEntity>> getSchedulesWithReminders();

  /// 스케줄 검색
  Future<List<ScheduleEntity>> searchSchedules(String query);

  /// 스케줄 통계 가져오기
  Future<ScheduleStatistics> getScheduleStatistics();

  /// 스케줄 충돌 확인
  Future<bool> hasScheduleConflict(ScheduleEntity schedule);

  /// 스케줄 완료 처리
  Future<ScheduleEntity> markScheduleAsCompleted(String id);

  /// 스케줄 취소 처리
  Future<ScheduleEntity> cancelSchedule(String id, String reason);
}

/// 스케줄 통계
class ScheduleStatistics {
  final int totalSchedules;
  final int completedSchedules;
  final int pendingSchedules;
  final int cancelledSchedules;
  final int missedSchedules;
  final int todaySchedules;
  final int tomorrowSchedules;
  final int thisWeekSchedules;
  final Map<ScheduleType, int> schedulesByType;
  final Map<ScheduleStatus, int> schedulesByStatus;

  const ScheduleStatistics({
    required this.totalSchedules,
    required this.completedSchedules,
    required this.pendingSchedules,
    required this.cancelledSchedules,
    required this.missedSchedules,
    required this.todaySchedules,
    required this.tomorrowSchedules,
    required this.thisWeekSchedules,
    required this.schedulesByType,
    required this.schedulesByStatus,
  });

  /// 완료율 계산
  double get completionRate {
    if (totalSchedules == 0) return 0.0;
    return completedSchedules / totalSchedules;
  }

  /// 취소율 계산
  double get cancellationRate {
    if (totalSchedules == 0) return 0.0;
    return cancelledSchedules / totalSchedules;
  }

  /// 놓친 비율 계산
  double get missedRate {
    if (totalSchedules == 0) return 0.0;
    return missedSchedules / totalSchedules;
  }
}
