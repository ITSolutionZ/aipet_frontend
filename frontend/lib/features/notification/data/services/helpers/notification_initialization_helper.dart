import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

/// 알림 초기화 헬퍼 (Awesome Notifications)
class NotificationInitializationHelper {
  /// Awesome Notifications 초기화
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // 기본 아이콘 사용
      [
        // 기본 채널
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: '基本通知',
          channelDescription: '一般的な通知',
          defaultColor: const Color(0xFFA88B5A),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
        // 스케줄 알람 채널 (커스텀 사운드 지원)
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'スケジュールアラーム',
          channelDescription: '予定されたアラーム通知',
          defaultColor: const Color(0xFFA88B5A),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          playSound: true, // 커스텀 사운드를 재생하려면 true 필요
          enableVibration: true,
          criticalAlerts: true,
          locked: true,
          onlyAlertOnce: false,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );

    // 권한 요청
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    debugPrint('✅ Awesome Notifications 초기화 완료');
  }

  /// Android 초기화 설정 (호환성 유지)
  static dynamic getAndroidSettings() {
    return null;
  }

  /// iOS 초기화 설정 (호환성 유지)
  static dynamic getIOSSettings() {
    return null;
  }

  /// 초기화 설정 생성 (호환성 유지)
  static dynamic getInitializationSettings() {
    return null;
  }
}
