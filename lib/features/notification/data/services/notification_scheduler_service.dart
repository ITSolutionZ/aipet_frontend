import 'dart:async';

import '../../domain/domain.dart';
import 'package:flutter/foundation.dart';

import 'package:aipet_frontend/shared/services/cache_service.dart';
import 'helpers/notification_scheduler_executor_helper.dart';
import 'helpers/notification_scheduler_storage_helper.dart';
import 'notification_service.dart' as local;

  // ✅ SharedPreferences 인스턴스 재사용
  static final _cache = CacheService();
  static Future<void> _init() async {
    await _cache.initialize();
  }
/// 알림 스케줄링 서비스
class NotificationSchedulerService {
  static const String _schedulerEnabledKey = 'scheduler_enabled';

  final local.NotificationService _notificationService;
  Timer? _schedulerTimer;
  bool _isInitialized = false;
  bool _isEnabled = true;

  // 스케줄 스트림
  final StreamController<List<NotificationSchedule>> _schedulesController =
      StreamController<List<NotificationSchedule>>.broadcast();

  Stream<List<NotificationSchedule>> get schedulesStream =>
      _schedulesController.stream;

  NotificationSchedulerService(this._notificationService);

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 설정 로드
      await _init();
      _isEnabled = prefs.getBool(_schedulerEnabledKey) ?? true;

      if (_isEnabled) {
        await _startScheduler();
      }

      _isInitialized = true;
      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 스케줄러 시작
  Future<void> _startScheduler() async {
    _schedulerTimer?.cancel();

    // 1분마다 스케줄 확인
    _schedulerTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkSchedules();
    });

    if (kDebugMode) {}
  }

  /// 스케줄러 중지
  Future<void> _stopScheduler() async {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;

    if (kDebugMode) {}
  }

  /// 스케줄 확인 및 실행
  Future<void> _checkSchedules() async {
    try {
      final schedules = await getSchedules();

      for (final schedule in schedules) {
        if (NotificationSchedulerExecutorHelper.shouldExecuteSchedule(
          schedule,
        )) {
          await _executeSchedule(schedule);
        }
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 스케줄 실행
  Future<void> _executeSchedule(NotificationSchedule schedule) async {
    try {
      // 알림 생성 (헬퍼 위임)
      final notification =
          NotificationSchedulerExecutorHelper.createNotificationFromSchedule(
            schedule,
          );

      // 알림 발송
      await _notificationService.createNotification(
        title: notification.title,
        body: notification.body,
        type: notification.type,
        priority: notification.priority,
        data: notification.data,
      );

      // 마지막 실행 시간 업데이트
      final updatedSchedule = schedule.copyWith(lastExecuted: DateTime.now());
      await updateSchedule(updatedSchedule);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 스케줄 추가
  Future<void> addSchedule(NotificationSchedule schedule) async {
    try {
      final schedules = await getSchedules();
      schedules.add(schedule);
      await NotificationSchedulerStorageHelper.saveSchedules(schedules);
      _schedulesController.add(schedules);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 스케줄 업데이트
  Future<void> updateSchedule(NotificationSchedule schedule) async {
    try {
      final schedules = await getSchedules();
      final index = schedules.indexWhere((s) => s.id == schedule.id);

      if (index != -1) {
        schedules[index] = schedule;
        await NotificationSchedulerStorageHelper.saveSchedules(schedules);
        _schedulesController.add(schedules);

        if (kDebugMode) {}
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 스케줄 삭제
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      final schedules = await getSchedules();
      schedules.removeWhere((s) => s.id == scheduleId);
      await NotificationSchedulerStorageHelper.saveSchedules(schedules);
      _schedulesController.add(schedules);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 스케줄 활성화/비활성화
  Future<void> toggleSchedule(String scheduleId, bool isActive) async {
    try {
      final schedules = await getSchedules();
      final index = schedules.indexWhere((s) => s.id == scheduleId);

      if (index != -1) {
        schedules[index] = schedules[index].copyWith(isActive: isActive);
        await NotificationSchedulerStorageHelper.saveSchedules(schedules);
        _schedulesController.add(schedules);

        if (kDebugMode) {}
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 모든 스케줄 가져오기
  Future<List<NotificationSchedule>> getSchedules() async {
    return NotificationSchedulerStorageHelper.getSchedules();
  }

  /// 활성화된 스케줄만 가져오기
  Future<List<NotificationSchedule>> getActiveSchedules() async {
    return NotificationSchedulerStorageHelper.getActiveSchedules();
  }

  /// 특정 타입의 스케줄 가져오기
  Future<List<NotificationSchedule>> getSchedulesByType(
    NotificationType type,
  ) async {
    return NotificationSchedulerStorageHelper.getSchedulesByType(type);
  }

  /// 스케줄러 활성화/비활성화
  Future<void> setSchedulerEnabled(bool enabled) async {
    _isEnabled = enabled;

    try {
      await _init();
      await prefs.setBool(_schedulerEnabledKey, enabled);

      if (enabled) {
        await _startScheduler();
      } else {
        await _stopScheduler();
      }

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 스케줄러 상태 확인
  bool get isEnabled => _isEnabled;

  /// 모든 스케줄 삭제
  Future<void> clearAllSchedules() async {
    try {
      await NotificationSchedulerStorageHelper.clearAllSchedules();
      _schedulesController.add([]);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 만료된 스케줄 정리
  Future<void> cleanupExpiredSchedules() async {
    try {
      final validSchedules =
          await NotificationSchedulerStorageHelper.cleanupExpiredSchedules();
      _schedulesController.add(validSchedules);

      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 스케줄 통계 가져오기
  Future<Map<String, dynamic>> getScheduleStats() async {
    try {
      final schedules = await getSchedules();
      return NotificationSchedulerExecutorHelper.createScheduleStats(schedules);
    } catch (e) {
      if (kDebugMode) {}
      return {};
    }
  }

  /// 리소스 정리
  void dispose() {
    _schedulerTimer?.cancel();
    _schedulesController.close();
  }
}
