import '../../../domain/domain.dart';

/// 알림 스케줄 실행 헬퍼
class NotificationSchedulerExecutorHelper {
  /// 스케줄이 실행될 시간인지 확인
  static bool shouldExecuteSchedule(NotificationSchedule schedule) {
    if (!schedule.isActive) return false;

    final now = DateTime.now();
    final nextTrigger = schedule.calculateNextExecutionTime();

    // 1분 이내에 실행될 스케줄 확인
    final timeUntilTrigger = nextTrigger.difference(now);
    return timeUntilTrigger.inMinutes <= 1 && timeUntilTrigger.inMinutes >= 0;
  }

  /// 스케줄에서 알림 모델 생성
  static NotificationModel createNotificationFromSchedule(
    NotificationSchedule schedule,
  ) {
    return NotificationModel(
      id: 'scheduled_${schedule.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: schedule.title,
      body: schedule.description,
      type: schedule.type,
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
      data: schedule.metadata,
    );
  }

  /// 스케줄 통계 생성
  static Map<String, dynamic> createScheduleStats(
    List<NotificationSchedule> schedules,
  ) {
    final activeSchedules = schedules.where((s) => s.isActive).length;
    final totalSchedules = schedules.length;

    final typeStats = <String, int>{};
    for (final schedule in schedules) {
      final typeName = schedule.type.name;
      typeStats[typeName] = (typeStats[typeName] ?? 0) + 1;
    }

    return {
      'total': totalSchedules,
      'active': activeSchedules,
      'inactive': totalSchedules - activeSchedules,
      'byType': typeStats,
    };
  }
}
