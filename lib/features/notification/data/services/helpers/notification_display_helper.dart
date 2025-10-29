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
      print(
        '   - 알람 소리: ${schedule.sound.displayName} (리소스: ${schedule.sound.resourcePath})',
      );
      print('   - customSound 값: ${schedule.sound.resourcePath}');
      print('   - isActive: ${schedule.isActive}');

      // raw 리소스 파일 존재 확인을 위한 로그
      if (schedule.sound.resourcePath != null) {
        print(
          '   ⚠️  확인: android/app/src/main/res/raw/${schedule.sound.resourcePath}.mp3 파일 존재 필요',
        );
      }
    }

    // NotificationContent 생성 (customSound null 처리)
    final NotificationContent content;

    if (schedule.sound.resourcePath != null) {
      // 커스텀 사운드가 있는 경우
      if (kDebugMode) {
        print('🔊 [사운드] 커스텀 사운드 사용: ${schedule.sound.resourcePath}');
      }
      content = NotificationContent(
        id: notificationId,
        channelKey: 'scheduled_channel',
        title: schedule.title,
        body: schedule.description,
        payload: {'scheduleId': schedule.id, 'type': schedule.type.name},
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
        customSound: schedule.sound.resourcePath,
        autoDismissible: false,
        displayOnForeground: true,
        displayOnBackground: true,
        locked: true,
        fullScreenIntent: true,
        criticalAlert: true,
      );
    } else {
      // 기본 사운드 사용
      if (kDebugMode) {
        print('🔊 [사운드] 기본 사운드 사용');
      }
      content = NotificationContent(
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
    }

    final success = await AwesomeNotifications().createNotification(
      content: content,
      schedule: NotificationCalendar.fromDate(
        date: nextTime,
        repeats: schedule.scheduleType == domain.ScheduleType.daily,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );

    if (kDebugMode) {
      print('✅ [AwesomeNotifications] 스케줄 알람 등록 결과: $success');
      print(
        '   ⏰ 알람이 ${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}에 울립니다',
      );
      print('   🔊 content.customSound 실제 값: ${content.customSound}');

      // 등록 직후 확인
      final scheduledList = await AwesomeNotifications()
          .listScheduledNotifications();
      final justScheduled = scheduledList
          .where((n) => n.content?.id == notificationId)
          .toList();

      if (justScheduled.isNotEmpty) {
        print('✅ [AwesomeNotifications] 알람이 시스템에 등록됨!');
        print('   📋 스케줄 상세: ${justScheduled.first.schedule?.toMap()}');
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
