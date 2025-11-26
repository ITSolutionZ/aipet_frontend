import 'dart:convert';

import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart'
    as domain;
import 'package:aipet_frontend/features/notification/domain/entities/notification_schedule.dart'
    as domain;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'notification_initialization_helper.dart';

/// 알림 표시 헬퍼 (flutter_local_notifications)
class NotificationDisplayHelper {
  static bool _tzInitialized = false;

  /// timezone 초기화
  static void _initializeTimeZone() {
    if (!_tzInitialized) {
      tz_data.initializeTimeZones();
      _tzInitialized = true;
    }
  }

  /// 즉시 알림 표시
  static Future<void> showLocalNotification(
    dynamic localNotifications, // 호환성 유지 (사용하지 않음)
    domain.NotificationModel notification,
    DateTime? scheduledDate,
  ) async {
    final plugin = NotificationInitializationHelper.plugin;
    final notificationId = int.parse(notification.id) % 2147483647;

    const androidDetails = AndroidNotificationDetails(
      'basic_channel',
      '基本通知',
      channelDescription: '一般的な通知',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.show(
      notificationId,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.toJson()),
    );

    if (kDebugMode) {
      print('✅ [flutter_local_notifications] 즉시 알림 표시 완료');
    }
  }

  /// 스케줄 알람 등록 (정확한 시간에 울림)
  static Future<void> scheduleNotification(
    dynamic localNotifications, // 호환성 유지 (사용하지 않음)
    domain.NotificationSchedule schedule,
  ) async {
    _initializeTimeZone();

    final plugin = NotificationInitializationHelper.plugin;
    final notificationId = int.parse(schedule.id) % 2147483647;

    // 다음 실행 시간 계산
    final nextTime = schedule.calculateNextExecutionTime();
    final now = DateTime.now();
    final timeUntilAlarm = nextTime.difference(now);

    if (kDebugMode) {
      print('🔔 [flutter_local_notifications] 스케줄 알람 등록 시작');
      print('   - ID: $notificationId');
      print('   - 제목: ${schedule.title}');
      print('   - 설명: ${schedule.description}');
      print('   - 스케줄 타입: ${schedule.scheduleType}');
      print('   - 요청 시간: ${schedule.time.hour}:${schedule.time.minute}');
      print('   - 다음 실행: $nextTime');
      print('   - 현재 시간: $now');
      print(
        '   - 남은 시간: ${timeUntilAlarm.inMinutes}분 ${timeUntilAlarm.inSeconds % 60}초',
      );
      print('   - 알람 소리: 시스템 기본');
      print('   - isActive: ${schedule.isActive}');
    }

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'スケジュールアラーム',
      channelDescription: '予定されたアラーム通知',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.from(nextTime, tz.local);
    final payload = jsonEncode({
      'scheduleId': schedule.id,
      'type': schedule.type.name,
    });

    // 스케줄 타입에 따라 다르게 처리
    if (schedule.scheduleType == domain.ScheduleType.daily) {
      // 매일 반복
      await plugin.zonedSchedule(
        notificationId,
        schedule.title,
        schedule.description,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (schedule.scheduleType == domain.ScheduleType.weekly) {
      // 주간 반복 (요일별로 별도 알람 등록 필요)
      await plugin.zonedSchedule(
        notificationId,
        schedule.title,
        schedule.description,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } else {
      // 1회성 알람
      await plugin.zonedSchedule(
        notificationId,
        schedule.title,
        schedule.description,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    }

    if (kDebugMode) {
      print('✅ [flutter_local_notifications] 스케줄 알람 등록 완료');
      print(
        '   ⏰ 알람이 ${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}에 울립니다',
      );

      // 등록된 알람 확인
      final pendingNotifications = await plugin.pendingNotificationRequests();
      final justScheduled = pendingNotifications
          .where((n) => n.id == notificationId)
          .toList();

      if (justScheduled.isNotEmpty) {
        print('✅ [flutter_local_notifications] 알람이 시스템에 등록됨!');
        print('   📋 제목: ${justScheduled.first.title}');
      } else {
        print('❌ [flutter_local_notifications] 알람이 시스템에 등록되지 않음!');
        print('   📋 전체 등록된 알람: ${pendingNotifications.length}개');
      }
    }
  }

  /// 스케줄 알람 취소
  static Future<void> cancelScheduledNotification(
    dynamic localNotifications, // 호환성 유지 (사용하지 않음)
    String scheduleId,
  ) async {
    final plugin = NotificationInitializationHelper.plugin;
    final notificationId = int.parse(scheduleId) % 2147483647;

    await plugin.cancel(notificationId);

    if (kDebugMode) {
      print('🔔 [flutter_local_notifications] 스케줄 알람 취소 - ID: $notificationId');
    }
  }

  /// 모든 알람 취소
  static Future<void> cancelAllNotifications() async {
    final plugin = NotificationInitializationHelper.plugin;
    await plugin.cancelAll();

    if (kDebugMode) {
      print('🔔 [flutter_local_notifications] 모든 알람 취소됨');
    }
  }

  /// 등록된 알람 목록 가져오기
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final plugin = NotificationInitializationHelper.plugin;
    return plugin.pendingNotificationRequests();
  }
}
