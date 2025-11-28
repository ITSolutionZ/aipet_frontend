import 'dart:async';

import 'package:aipet_frontend/shared/services/cache_service.dart';
import 'package:flutter/foundation.dart';

import '../../domain/domain.dart' as domain;
import 'helpers/notification_display_helper.dart';
import 'helpers/notification_scheduler_executor_helper.dart';
import 'helpers/notification_scheduler_storage_helper.dart';
import 'notification_service.dart' as local;

/// 알림 스케줄링 서비스
class NotificationSchedulerService {
  static const String _schedulerEnabledKey = 'scheduler_enabled';

  final local.NotificationService _notificationService;
  bool _isInitialized = false;
  bool _isEnabled = true;

  // ✅ CacheService 사용
  final _cache = CacheService();

  Future<void> _init() async {
    await _cache.initialize();
  }

  // 스케줄 스트림
  final StreamController<List<domain.NotificationSchedule>>
  _schedulesController =
      StreamController<List<domain.NotificationSchedule>>.broadcast();

  Stream<List<domain.NotificationSchedule>> get schedulesStream =>
      _schedulesController.stream;

  NotificationSchedulerService(this._notificationService);

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 설정 로드
      await _init();
      _isEnabled = _cache.getBoolValue(_schedulerEnabledKey) ?? true;

      if (_isEnabled) {
        await _startScheduler();
      }

      _isInitialized = true;
      if (kDebugMode) {}
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 스케줄러 시작 (flutter_local_notifications 사용)
  Future<void> _startScheduler() async {
    try {
      if (kDebugMode) {
        print('✅ [Scheduler] flutter_local_notifications 스케줄러 시작');
      }
      // flutter_local_notifications는 각 알람을 개별적으로 스케줄링하므로
      // 별도의 백그라운드 작업이 불필요
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Scheduler] 스케줄러 시작 오류: $e');
      }
    }
  }

  /// 스케줄러 중지
  Future<void> _stopScheduler() async {
    try {
      if (kDebugMode) {
        print('⏹️ [Scheduler] 스케줄러 중지');
      }
      // 모든 예약된 알람 취소
      await NotificationDisplayHelper.cancelAllNotifications();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Scheduler] 스케줄러 중지 오류: $e');
      }
    }
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
  Future<void> _executeSchedule(domain.NotificationSchedule schedule) async {
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

  /// 스케줄 추가 (Firebase + 로컬)
  Future<void> addSchedule(domain.NotificationSchedule schedule) async {
    try {
      if (kDebugMode) {
        print('🔔 [Scheduler] 스케줄 추가 시작 - ID: ${schedule.id}');
      }

      // Firebase + 로컬에 저장
      final savedSchedule = await NotificationSchedulerStorageHelper.saveSchedule(schedule);

      if (kDebugMode) {
        print('✅ [Scheduler] 스케줄 저장 완료 - ID: ${savedSchedule?.id}');
      }

      // 스케줄 목록 새로고침
      final schedules = await getSchedules();
      _schedulesController.add(schedules);

      if (kDebugMode) {
        print('✅ [Scheduler] 스케줄 추가 완료 - 총 ${schedules.length}개');
      }

      // 🔔 실제 알람 등록 (flutter_local_notifications)
      if (schedule.isActive) {
        if (kDebugMode) {
          print('🔔 [Scheduler] 실제 알람 등록 시작...');
        }
        await _notificationService.scheduleNotification(savedSchedule ?? schedule);
        if (kDebugMode) {
          print('✅ [Scheduler] 실제 알람 등록 완료!');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Scheduler] 스케줄 추가 실패: $e');
      }
      rethrow;
    }
  }

  /// 스케줄 업데이트 (Firebase + 로컬)
  Future<void> updateSchedule(domain.NotificationSchedule schedule) async {
    try {
      if (kDebugMode) {
        print('🔔 [Scheduler] 스케줄 업데이트 시작 - ID: ${schedule.id}');
      }

      // Firebase + 로컬 업데이트
      await NotificationSchedulerStorageHelper.updateSchedule(schedule);

      // 스케줄 목록 새로고침
      final schedules = await getSchedules();
      _schedulesController.add(schedules);

      // 🔔 기존 알람 취소 후 새로 등록
      if (kDebugMode) {
        print('🔔 [Scheduler] 기존 알람 취소 후 새로 등록');
      }
      await _notificationService.cancelScheduledNotification(schedule.id);

      if (schedule.isActive) {
        await _notificationService.scheduleNotification(schedule);
      }

      if (kDebugMode) {
        print('✅ [Scheduler] 스케줄 업데이트 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Scheduler] 스케줄 업데이트 실패: $e');
      }
      rethrow;
    }
  }

  /// 스케줄 삭제 (Firebase + 로컬)
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      if (kDebugMode) {
        print('🔔 [Scheduler] 스케줄 삭제 시작 - ID: $scheduleId');
      }

      final beforeCount = (await getSchedules()).length;

      // Firebase + 로컬에서 삭제
      await NotificationSchedulerStorageHelper.deleteSchedule(scheduleId);

      // 스케줄 목록 새로고침
      final schedules = await getSchedules();
      _schedulesController.add(schedules);

      // 🔔 실제 알람 취소
      if (kDebugMode) {
        print('🔔 [Scheduler] 실제 알람 취소 중...');
      }
      await _notificationService.cancelScheduledNotification(scheduleId);

      if (kDebugMode) {
        print('✅ [Scheduler] 스케줄 삭제 완료 - $beforeCount개 → ${schedules.length}개');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Scheduler] 스케줄 삭제 실패: $e');
      }
      rethrow;
    }
  }

  /// 스케줄 활성화/비활성화 (Firebase + 로컬)
  Future<void> toggleSchedule(String scheduleId, bool isActive) async {
    try {
      if (kDebugMode) {
        print(
          '🔔 [Scheduler] 스케줄 토글 시작 - ID: $scheduleId, isActive: $isActive',
        );
      }

      final schedules = await getSchedules();
      final index = schedules.indexWhere((s) => s.id == scheduleId);

      if (index != -1) {
        final schedule = schedules[index].copyWith(isActive: isActive);

        // Firebase + 로컬 업데이트
        await NotificationSchedulerStorageHelper.updateSchedule(schedule);

        // 스케줄 목록 새로고침
        final updatedSchedules = await getSchedules();
        _schedulesController.add(updatedSchedules);

        // 🔔 실제 알람 등록/취소
        if (isActive) {
          if (kDebugMode) {
            print('🔔 [Scheduler] 알람 활성화 - 실제 알람 등록');
          }
          await _notificationService.scheduleNotification(schedule);
        } else {
          if (kDebugMode) {
            print('🔔 [Scheduler] 알람 비활성화 - 실제 알람 취소');
          }
          await _notificationService.cancelScheduledNotification(scheduleId);
        }

        if (kDebugMode) {
          print('✅ [Scheduler] 스케줄 토글 완료 - ${isActive ? "활성화" : "비활성화"}');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ [Scheduler] 스케줄을 찾을 수 없음: $scheduleId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Scheduler] 스케줄 토글 실패: $e');
      }
      rethrow;
    }
  }

  /// 모든 스케줄 가져오기
  Future<List<domain.NotificationSchedule>> getSchedules() async {
    return NotificationSchedulerStorageHelper.getSchedules();
  }

  /// 활성화된 스케줄만 가져오기
  Future<List<domain.NotificationSchedule>> getActiveSchedules() async {
    return NotificationSchedulerStorageHelper.getActiveSchedules();
  }

  /// 특정 타입의 스케줄 가져오기
  Future<List<domain.NotificationSchedule>> getSchedulesByType(
    domain.NotificationType type,
  ) async {
    return NotificationSchedulerStorageHelper.getSchedulesByType(type);
  }

  /// 스케줄러 활성화/비활성화
  Future<void> setSchedulerEnabled(bool enabled) async {
    _isEnabled = enabled;

    try {
      await _init();
      await _cache.setBoolValue(_schedulerEnabledKey, enabled);

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
    // 모든 스케줄 알람 취소
    NotificationDisplayHelper.cancelAllNotifications();
    _schedulesController.close();
  }
}
