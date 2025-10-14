import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 알림 초기화 헬퍼
class NotificationInitializationHelper {
  /// Android 초기화 설정
  static AndroidInitializationSettings getAndroidSettings() {
    return const AndroidInitializationSettings('@mipmap/ic_launcher');
  }

  /// iOS 초기화 설정
  static DarwinInitializationSettings getIOSSettings() {
    return const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
  }

  /// 초기화 설정 생성
  static InitializationSettings getInitializationSettings() {
    return InitializationSettings(
      android: getAndroidSettings(),
      iOS: getIOSSettings(),
    );
  }
}
