import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../../shared/shared.dart';
import '../../../domain/domain.dart';

/// 알림 스케줄 저장소 헬퍼
class NotificationSchedulerStorageHelper {
  static const String schedulesKey = 'notification_schedules';

  /// 스케줄 저장
  static Future<void> saveSchedules(
    List<NotificationSchedule> schedules,
  ) async {
    try {
      final schedulesJson = jsonEncode(
        schedules.map((s) => s.toJson()).toList(),
      );
      await SecureStorageService.setString(schedulesKey, schedulesJson);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('스케줄 저장 실패: $e');
      }
    }
  }

  /// 스케줄 조회
  static Future<List<NotificationSchedule>> getSchedules() async {
    try {
      final schedulesJson = await SecureStorageService.getString(schedulesKey);
      if (schedulesJson != null) {
        final List<dynamic> schedulesList = jsonDecode(schedulesJson);
        return schedulesList
            .map((json) => NotificationSchedule.fromJson(json))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('스케줄 조회 실패: $e');
      }
    }
    return [];
  }

  /// 활성화된 스케줄만 조회
  static Future<List<NotificationSchedule>> getActiveSchedules() async {
    final schedules = await getSchedules();
    return schedules.where((s) => s.isActive).toList();
  }

  /// 특정 타입의 스케줄 조회
  static Future<List<NotificationSchedule>> getSchedulesByType(
    NotificationType type,
  ) async {
    final schedules = await getSchedules();
    return schedules.where((s) => s.type == type).toList();
  }

  /// 모든 스케줄 삭제
  static Future<void> clearAllSchedules() async {
    try {
      await SecureStorageService.remove(schedulesKey);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('스케줄 삭제 실패: $e');
      }
    }
  }

  /// 만료된 스케줄 정리
  static Future<List<NotificationSchedule>> cleanupExpiredSchedules() async {
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
        await saveSchedules(validSchedules);
      }

      return validSchedules;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('만료된 스케줄 정리 실패: $e');
      }
      return [];
    }
  }
}
