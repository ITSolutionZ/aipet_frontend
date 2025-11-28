import 'dart:convert';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/domain.dart';
import '../firestore_schedule_service.dart';

/// 알림 스케줄 저장소 헬퍼 (Firebase + 로컬 백업)
///
/// Firebase Firestore를 우선 사용하고, 로컬 저장소를 백업으로 사용합니다.
class NotificationSchedulerStorageHelper {
  static const String schedulesKey = 'notification_schedules';

  /// 스케줄 저장 (Firebase + 로컬)
  static Future<NotificationSchedule?> saveSchedule(
    NotificationSchedule schedule,
  ) async {
    try {
      // Firebase에 저장
      final result = await FirestoreScheduleService.createSchedule(schedule);
      if (result.isSuccess && result.dataOrNull != null) {
        LoggerService.debug('✅ Firebase에 스케줄 저장 성공');
        // 로컬 백업도 업데이트
        await _updateLocalBackup();
        return result.dataOrNull;
      }
    } catch (e) {
      LoggerService.debug('⚠️ Firebase 스케줄 저장 실패, 로컬 저장: $e');
    }

    // Firebase 실패 시 로컬에만 저장
    final schedules = await _getLocalSchedules();
    schedules.add(schedule);
    await _saveLocalSchedules(schedules);
    return schedule;
  }

  /// 스케줄 업데이트 (Firebase + 로컬)
  static Future<void> updateSchedule(NotificationSchedule schedule) async {
    try {
      // Firebase 업데이트
      await FirestoreScheduleService.updateSchedule(schedule);
      LoggerService.debug('✅ Firebase 스케줄 업데이트 성공');
    } catch (e) {
      LoggerService.debug('⚠️ Firebase 스케줄 업데이트 실패: $e');
    }

    // 로컬도 업데이트
    final schedules = await _getLocalSchedules();
    final index = schedules.indexWhere((s) => s.id == schedule.id);
    if (index >= 0) {
      schedules[index] = schedule;
      await _saveLocalSchedules(schedules);
    }
  }

  /// 스케줄 삭제 (Firebase + 로컬)
  static Future<void> deleteSchedule(String scheduleId) async {
    try {
      // Firebase에서 삭제
      await FirestoreScheduleService.deleteSchedule(scheduleId);
      LoggerService.debug('✅ Firebase 스케줄 삭제 성공');
    } catch (e) {
      LoggerService.debug('⚠️ Firebase 스케줄 삭제 실패: $e');
    }

    // 로컬에서도 삭제
    final schedules = await _getLocalSchedules();
    schedules.removeWhere((s) => s.id == scheduleId);
    await _saveLocalSchedules(schedules);
  }

  /// 스케줄 조회 (Firebase 우선, 로컬 백업)
  static Future<List<NotificationSchedule>> getSchedules() async {
    try {
      // Firebase에서 조회
      final result = await FirestoreScheduleService.getAllSchedules();
      if (result.isSuccess) {
        final schedules = result.dataOrNull ?? [];
        if (schedules.isNotEmpty) {
          LoggerService.debug('✅ Firebase에서 ${schedules.length}개 스케줄 로드');
          // 로컬 백업 업데이트
          await _saveLocalSchedules(schedules);
          return schedules;
        }
      }
    } catch (e) {
      LoggerService.debug('⚠️ Firebase 스케줄 조회 실패, 로컬 사용: $e');
    }

    // Firebase 실패 또는 빈 결과 시 로컬에서 조회
    return _getLocalSchedules();
  }

  /// 활성화된 스케줄만 조회
  static Future<List<NotificationSchedule>> getActiveSchedules() async {
    try {
      final result = await FirestoreScheduleService.getActiveSchedules();
      if (result.isSuccess) {
        return result.dataOrNull ?? [];
      }
    } catch (e) {
      LoggerService.debug('⚠️ Firebase 활성 스케줄 조회 실패: $e');
    }

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
      // Firebase에서 모든 스케줄 삭제
      final schedules = await getSchedules();
      for (final schedule in schedules) {
        await FirestoreScheduleService.deleteSchedule(schedule.id);
      }
    } catch (e) {
      LoggerService.debug('⚠️ Firebase 전체 스케줄 삭제 실패: $e');
    }

    // 로컬도 삭제
    try {
      await SecureStorageService.remove(schedulesKey);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('로컬 스케줄 삭제 실패: $e');
      }
    }
  }

  /// 만료된 스케줄 정리
  static Future<List<NotificationSchedule>> cleanupExpiredSchedules() async {
    try {
      final schedules = await getSchedules();
      final validSchedules = schedules.where((schedule) {
        if (schedule.scheduleType == ScheduleType.once) {
          return !schedule.isExpired;
        }
        return schedule.isActive;
      }).toList();

      // 만료된 스케줄 삭제
      final expiredSchedules = schedules.where((s) => !validSchedules.contains(s));
      for (final expired in expiredSchedules) {
        await deleteSchedule(expired.id);
      }

      return validSchedules;
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('만료된 스케줄 정리 실패: $e');
      }
      return [];
    }
  }

  // ========== 로컬 저장소 헬퍼 메서드 ==========

  /// 로컬 스케줄 저장
  static Future<void> _saveLocalSchedules(
    List<NotificationSchedule> schedules,
  ) async {
    try {
      final schedulesJson = jsonEncode(
        schedules.map((s) => s.toJson()).toList(),
      );
      await SecureStorageService.setString(schedulesKey, schedulesJson);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('로컬 스케줄 저장 실패: $e');
      }
    }
  }

  /// 로컬 스케줄 조회
  static Future<List<NotificationSchedule>> _getLocalSchedules() async {
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
        LoggerService.debug('로컬 스케줄 조회 실패: $e');
      }
    }
    return [];
  }

  /// 로컬 백업 업데이트 (Firebase 데이터로)
  static Future<void> _updateLocalBackup() async {
    try {
      final result = await FirestoreScheduleService.getAllSchedules();
      if (result.isSuccess) {
        await _saveLocalSchedules(result.dataOrNull ?? []);
      }
    } catch (e) {
      LoggerService.debug('로컬 백업 업데이트 실패: $e');
    }
  }

  // ========== 레거시 호환성 메서드 ==========

  /// 레거시: 스케줄 목록 저장 (기존 코드 호환)
  @Deprecated('Use saveSchedule instead')
  static Future<void> saveSchedules(
    List<NotificationSchedule> schedules,
  ) async {
    await _saveLocalSchedules(schedules);
  }
}
