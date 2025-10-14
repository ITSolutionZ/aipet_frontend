import 'dart:convert';

import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 알림 표시 헬퍼
class NotificationDisplayHelper {
  /// Android 알림 상세 설정
  static AndroidNotificationDetails getAndroidDetails() {
    return const AndroidNotificationDetails(
      'aipet_channel',
      'AI Pet 알림',
      channelDescription: 'AI Pet 앱의 모든 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
  }

  /// iOS 알림 상세 설정
  static DarwinNotificationDetails getIOSDetails() {
    return const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'aipet_category',
    );
  }

  /// 알림 상세 설정 생성
  static NotificationDetails getNotificationDetails() {
    return NotificationDetails(
      android: getAndroidDetails(),
      iOS: getIOSDetails(),
    );
  }

  /// 로컬 알림 표시
  static Future<void> showLocalNotification(
    FlutterLocalNotificationsPlugin localNotifications,
    NotificationModel notification,
    DateTime? scheduledDate,
  ) async {
    final details = getNotificationDetails();

    // 예약된 알림과 즉시 알림 모두 동일하게 처리
    await localNotifications.show(
      int.parse(notification.id),
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.toJson()),
    );
  }
}
