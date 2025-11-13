import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/notification_controller_providers.dart';
import '../../data/services/notification_scheduler_service.dart';
import '../../domain/domain.dart';

part 'notification_schedule_controller.g.dart';

/// 알림 스케줄 상태
class NotificationScheduleState {
  final List<NotificationSchedule> schedules;
  final bool isLoading;
  final String? error;

  const NotificationScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationScheduleState copyWith({
    List<NotificationSchedule>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return NotificationScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 알림 스케줄 컨트롤러
@riverpod
class NotificationScheduleController extends _$NotificationScheduleController {
  @override
  NotificationScheduleState build() {
    return const NotificationScheduleState();
  }

  /// NotificationSchedulerService 가져오기
  NotificationSchedulerService get _schedulerService =>
      ref.read(notificationSchedulerServiceProvider);

  /// 스케줄 목록 로드
  Future<void> loadSchedules() async {
    print('🔔 [Controller] 스케줄 목록 로드 시작');

    state = state.copyWith(isLoading: true, error: null);
    try {
      final schedules = await _schedulerService.getSchedules();

      print('🔔 [Controller] 스케줄 목록 로드 완료 - ${schedules.length}개');
      for (final schedule in schedules) {
        print(
          '  📋 ${schedule.time.hour}:${schedule.time.minute} - ${schedule.title} (${schedule.isActive ? "ON" : "OFF"})',
        );
      }

      state = state.copyWith(schedules: schedules, isLoading: false);
    } catch (e) {
      print('❌ [Controller] 스케줄 목록 로드 실패: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 스케줄 추가
  Future<void> addSchedule(NotificationSchedule schedule) async {
    print('🔔 [Controller] 스케줄 추가 요청 - ID: ${schedule.id}');

    try {
      await _schedulerService.addSchedule(schedule);
      print('✅ [Controller] 스케줄 서비스 추가 완료, 목록 새로고침 시작');
      await loadSchedules(); // 목록 새로고침
    } catch (e) {
      print('❌ [Controller] 스케줄 추가 실패: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 스케줄 토글
  Future<void> toggleSchedule(String scheduleId, bool isActive) async {
    print('🔔 [Controller] 스케줄 토글 요청 - ID: $scheduleId, isActive: $isActive');

    try {
      await _schedulerService.toggleSchedule(scheduleId, isActive);
      print('✅ [Controller] 스케줄 서비스 토글 완료, 목록 새로고침 시작');
      await loadSchedules(); // 목록 새로고침
    } catch (e) {
      print('❌ [Controller] 스케줄 토글 실패: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 스케줄 삭제
  Future<void> deleteSchedule(String scheduleId) async {
    print('🔔 [Controller] 스케줄 삭제 요청 - ID: $scheduleId');

    try {
      await _schedulerService.deleteSchedule(scheduleId);
      print('✅ [Controller] 스케줄 서비스 삭제 완료, 목록 새로고침 시작');
      await loadSchedules(); // 목록 새로고침
    } catch (e) {
      print('❌ [Controller] 스케줄 삭제 실패: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 스케줄 업데이트
  Future<void> updateSchedule(NotificationSchedule schedule) async {
    print('🔔 [Controller] 스케줄 업데이트 요청 - ID: ${schedule.id}');
    print('  - 시간: ${schedule.time.hour}:${schedule.time.minute}');
    print('  - 활성화: ${schedule.isActive}');
    print('  - 생성일: ${schedule.createdAt}');

    try {
      await _schedulerService.updateSchedule(schedule);
      print('✅ [Controller] 스케줄 서비스 업데이트 완료, 목록 새로고침 시작');
      await loadSchedules(); // 목록 새로고침
    } catch (e) {
      print('❌ [Controller] 스케줄 업데이트 실패: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// 전체 스케줄 삭제
  Future<void> clearAllSchedules() async {
    print('🗑️ [Controller] 전체 스케줄 삭제 요청');

    try {
      await _schedulerService.clearAllSchedules();
      print('✅ [Controller] 전체 스케줄 삭제 완료, 목록 새로고침 시작');
      await loadSchedules(); // 목록 새로고침
    } catch (e) {
      print('❌ [Controller] 전체 스케줄 삭제 실패: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

/// NotificationSchedulerService Provider
@riverpod
NotificationSchedulerService notificationSchedulerService(Ref ref) {
  final notificationService = ref.read(notificationServiceProvider);
  return NotificationSchedulerService(notificationService);
}
