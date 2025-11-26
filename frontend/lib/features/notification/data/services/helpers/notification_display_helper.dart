import 'dart:convert';

import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart'
    as domain;
import 'package:aipet_frontend/features/notification/domain/entities/notification_schedule.dart'
    as domain;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';

/// 알림 표시 헬퍼 (Awesome Notifications)
class NotificationDisplayHelper {
  /// 즉시 알림 표시
  static Future<void> showLocalNotification(
    dynamic localNotifications, // 사용하지 않음
    domain.NotificationModel notification,
    DateTime? scheduledDate,
  ) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: int.parse(notification.id) % 2147483647,
        channelKey: 'basic_channel',
        title: notification.title,
        body: notification.body,
        payload: {'data': jsonEncode(notification.toJson())},
        notificationLayout: NotificationLayout.Default,
      ),
    );

    if (kDebugMode) {
      print('✅ [AwesomeNotifications] 즉시 알림 표시 완료');
    }
  }

  /// 스케줄 알람 등록 (정확한 시간에 울림)
  static Future<void> scheduleNotification(
    dynamic localNotifications, // 사용하지 않음
    domain.NotificationSchedule schedule,
  ) async {
    final notificationId = int.parse(schedule.id) % 2147483647;

    // 다음 실행 시간 계산
    final nextTime = schedule.calculateNextExecutionTime();
    final now = DateTime.now();
    final timeUntilAlarm = nextTime.difference(now);

    if (kDebugMode) {
      print('🔔 [AwesomeNotifications] 스케줄 알람 등록 시작');
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

    final content = NotificationContent(
      id: notificationId,
      channelKey: 'scheduled_channel',
      title: schedule.title,
      body: schedule.description,
      payload: {'scheduleId': schedule.id, 'type': schedule.type.name},
      notificationLayout: NotificationLayout.Default,
      wakeUpScreen: true,
      category: NotificationCategory.Alarm,
      autoDismissible: false,
      displayOnForeground: true,
      displayOnBackground: true,
      locked: true,
      fullScreenIntent: true,
      criticalAlert: true,
    );

    // ✅ 스케줄 타입에 따라 다르게 설정
    final NotificationCalendar notificationSchedule;

    if (schedule.scheduleType == domain.ScheduleType.weekly ||
        schedule.scheduleType == domain.ScheduleType.daily) {
      // Weekly / Daily: 매일 반복 (시간만 지정, 날짜 지정 X)
      // ⚠️ 참고: AwesomeNotifications는 여러 요일 지정이 어려워 일단 매일 반복으로 설정
      notificationSchedule = NotificationCalendar(
        hour: schedule.time.hour,
        minute: schedule.time.minute,
        second: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
      );
    } else {
      // Once: 특정 날짜/시간 1회
      notificationSchedule = NotificationCalendar(
        year: nextTime.year,
        month: nextTime.month,
        day: nextTime.day,
        hour: schedule.time.hour,
        minute: schedule.time.minute,
        second: 0,
        repeats: false,
        allowWhileIdle: true,
        preciseAlarm: true,
      );
    }

    if (kDebugMode) {
      print('📋 [알람등록] NotificationCalendar 상세:');
      print('   - hour: ${notificationSchedule.hour}');
      print('   - minute: ${notificationSchedule.minute}');
      print('   - repeats: ${notificationSchedule.repeats}');
      print('   - scheduleType: ${schedule.scheduleType}');
      if (notificationSchedule.year != null) {
        print('   - year: ${notificationSchedule.year}');
        print('   - month: ${notificationSchedule.month}');
        print('   - day: ${notificationSchedule.day}');
      }
    }

    final success = await AwesomeNotifications().createNotification(
      content: content,
      schedule: notificationSchedule,
    );

    if (kDebugMode) {
      print('✅ [AwesomeNotifications] 스케줄 알람 등록 결과: $success');
      print(
        '   ⏰ 알람이 ${schedule.time.hour.toString().padLeft(2, '0')}:${schedule.time.minute.toString().padLeft(2, '0')}에 울립니다',
      );
      print('   🔊 사운드: 시스템 기본');

      // 등록 직후 확인
      final scheduledList = await AwesomeNotifications()
          .listScheduledNotifications();
      final justScheduled = scheduledList
          .where((n) => n.content?.id == notificationId)
          .toList();

      if (justScheduled.isNotEmpty) {
        print('✅ [AwesomeNotifications] 알람이 시스템에 등록됨!');
        final scheduleMap = justScheduled.first.schedule?.toMap();
        print('   📋 스케줄 상세: $scheduleMap');
        if (scheduleMap != null) {
          print(
            '   ✅ 시스템 등록 시간 확인: ${scheduleMap['hour']}:${scheduleMap['minute']}',
          );
        }
      } else {
        print('❌ [AwesomeNotifications] 알람이 시스템에 등록되지 않음!');
        print('   📋 전체 등록된 알람: ${scheduledList.length}개');
      }
    }
  }

  /// 스케줄 알람 취소
  static Future<void> cancelScheduledNotification(
    dynamic localNotifications, // 사용하지 않음
    String scheduleId,
  ) async {
    final notificationId = int.parse(scheduleId) % 2147483647;
    await AwesomeNotifications().cancel(notificationId);

    if (kDebugMode) {
      print('🔔 [AwesomeNotifications] 스케줄 알람 취소 - ID: $notificationId');
    }
  }
}
