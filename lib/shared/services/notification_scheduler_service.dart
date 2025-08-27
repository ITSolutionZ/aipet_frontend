import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/notification/domain/entities/notification_model.dart';
import '../../features/notification/domain/entities/notification_schedule.dart';
import 'notification_service.dart';
import 'secure_storage_service.dart';

/// 알림 스케줄링 서비스
class NotificationSchedulerService {
  static const String _schedulesKey = 'notification_schedules';
  static const String _schedulerEnabledKey = 'scheduler_enabled';

  final NotificationService _notificationService;
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
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_schedulerEnabledKey) ?? true;

      if (_isEnabled) {
        await _startScheduler();
      }

      _isInitialized = true;
      if (kDebugMode) {
        print('알림 스케줄러 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('알림 스케줄러 초기화 실패: $e');
      }
    }
  }

  /// 스케줄러 시작
  Future<void> _startScheduler() async {
    _schedulerTimer?.cancel();

    // 1분마다 스케줄 확인
    _schedulerTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkSchedules();
    });

    if (kDebugMode) {
      print('알림 스케줄러 시작됨');
    }
  }

  /// 스케줄러 중지
  Future<void> _stopScheduler() async {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;

    if (kDebugMode) {
      print('알림 스케줄러 중지됨');
    }
  }

  /// 스케줄 확인 및 실행
  Future<void> _checkSchedules() async {
    try {
      final schedules = await getSchedules();
      final now = DateTime.now();

      for (final schedule in schedules) {
        if (!schedule.isActive) continue;

        final nextTrigger = schedule.calculateNextExecutionTime();

        // 1분 이내에 실행될 스케줄 확인
        final timeUntilTrigger = nextTrigger.difference(now);
        if (timeUntilTrigger.inMinutes <= 1 &&
            timeUntilTrigger.inMinutes >= 0) {
          await _executeSchedule(schedule);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 확인 중 오류: $e');
      }
    }
  }

  /// 스케줄 실행
  Future<void> _executeSchedule(NotificationSchedule schedule) async {
    try {
      // 알림 생성
      final notification = NotificationModel(
        id: 'scheduled_${schedule.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: schedule.title,
        body: schedule.description,
        type: schedule.type,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now(),
        data: schedule.metadata,
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

      if (kDebugMode) {
        print('스케줄 실행됨: ${schedule.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 실행 실패: ${schedule.title}, 오류: $e');
      }
    }
  }

  /// 스케줄 추가
  Future<void> addSchedule(NotificationSchedule schedule) async {
    try {
      final schedules = await getSchedules();
      schedules.add(schedule);
      await _saveSchedules(schedules);
      _schedulesController.add(schedules);

      if (kDebugMode) {
        print('스케줄 추가됨: ${schedule.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 추가 실패: $e');
      }
    }
  }

  /// 스케줄 업데이트
  Future<void> updateSchedule(NotificationSchedule schedule) async {
    try {
      final schedules = await getSchedules();
      final index = schedules.indexWhere((s) => s.id == schedule.id);

      if (index != -1) {
        schedules[index] = schedule;
        await _saveSchedules(schedules);
        _schedulesController.add(schedules);

        if (kDebugMode) {
          print('스케줄 업데이트됨: ${schedule.title}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 업데이트 실패: $e');
      }
    }
  }

  /// 스케줄 삭제
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      final schedules = await getSchedules();
      schedules.removeWhere((s) => s.id == scheduleId);
      await _saveSchedules(schedules);
      _schedulesController.add(schedules);

      if (kDebugMode) {
        print('스케줄 삭제됨: $scheduleId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 삭제 실패: $e');
      }
    }
  }

  /// 스케줄 활성화/비활성화
  Future<void> toggleSchedule(String scheduleId, bool isActive) async {
    try {
      final schedules = await getSchedules();
      final index = schedules.indexWhere((s) => s.id == scheduleId);

      if (index != -1) {
        schedules[index] = schedules[index].copyWith(isActive: isActive);
        await _saveSchedules(schedules);
        _schedulesController.add(schedules);

        if (kDebugMode) {
          print('스케줄 상태 변경됨: $scheduleId, 활성화: $isActive');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 상태 변경 실패: $e');
      }
    }
  }

  /// 모든 스케줄 가져오기
  Future<List<NotificationSchedule>> getSchedules() async {
    try {
      final schedulesJson = await SecureStorageService.getStringUnencrypted(
        _schedulesKey,
      );
      if (schedulesJson != null) {
        final List<dynamic> schedulesList = jsonDecode(schedulesJson);
        return schedulesList
            .map((json) => NotificationSchedule.fromJson(json))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 로드 실패: $e');
      }
    }
    return [];
  }

  /// 활성화된 스케줄만 가져오기
  Future<List<NotificationSchedule>> getActiveSchedules() async {
    final schedules = await getSchedules();
    return schedules.where((s) => s.isActive).toList();
  }

  /// 특정 타입의 스케줄 가져오기
  Future<List<NotificationSchedule>> getSchedulesByType(
    NotificationType type,
  ) async {
    final schedules = await getSchedules();
    return schedules.where((s) => s.type == type).toList();
  }

  /// 스케줄러 활성화/비활성화
  Future<void> setSchedulerEnabled(bool enabled) async {
    _isEnabled = enabled;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_schedulerEnabledKey, enabled);

      if (enabled) {
        await _startScheduler();
      } else {
        await _stopScheduler();
      }

      if (kDebugMode) {
        print('스케줄러 ${enabled ? '활성화' : '비활성화'}됨');
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄러 상태 변경 실패: $e');
      }
    }
  }

  /// 스케줄러 상태 확인
  bool get isEnabled => _isEnabled;

  /// 스케줄 저장
  Future<void> _saveSchedules(List<NotificationSchedule> schedules) async {
    try {
      final schedulesJson = jsonEncode(
        schedules.map((s) => s.toJson()).toList(),
      );
      await SecureStorageService.setStringUnencrypted(
        _schedulesKey,
        schedulesJson,
      );
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 저장 실패: $e');
      }
    }
  }

  /// 모든 스케줄 삭제
  Future<void> clearAllSchedules() async {
    try {
      await SecureStorageService.remove(_schedulesKey);
      _schedulesController.add([]);

      if (kDebugMode) {
        print('모든 스케줄 삭제됨');
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 삭제 실패: $e');
      }
    }
  }

  /// 만료된 스케줄 정리
  Future<void> cleanupExpiredSchedules() async {
    try {
      final schedules = await getSchedules();
      final validSchedules = schedules.where((schedule) {
        // 한 번만 실행되는 스케줄은 이미 실행되었으면 제거
        if (schedule.scheduleType == ScheduleType.once) {
          return !schedule.isExpired;
        }
        // 활성화된 스케줄만 유지
        return schedule.isActive;
      }).toList();

      if (validSchedules.length != schedules.length) {
        await _saveSchedules(validSchedules);
        _schedulesController.add(validSchedules);

        if (kDebugMode) {
          print('만료된 스케줄 정리됨: ${schedules.length - validSchedules.length}개');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 정리 실패: $e');
      }
    }
  }

  /// 스케줄 통계 가져오기
  Future<Map<String, dynamic>> getScheduleStats() async {
    try {
      final schedules = await getSchedules();
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
    } catch (e) {
      if (kDebugMode) {
        print('스케줄 통계 가져오기 실패: $e');
      }
      return {};
    }
  }

  /// 리소스 정리
  void dispose() {
    _schedulerTimer?.cancel();
    _schedulesController.close();
  }
}
