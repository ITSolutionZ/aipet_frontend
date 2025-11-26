import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 알림 초기화 헬퍼 (flutter_local_notifications)
class NotificationInitializationHelper {
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;

  /// FlutterLocalNotificationsPlugin 인스턴스 (싱글톤)
  static FlutterLocalNotificationsPlugin get plugin {
    _notificationsPlugin ??= FlutterLocalNotificationsPlugin();
    return _notificationsPlugin!;
  }

  /// flutter_local_notifications 초기화
  static Future<void> initialize() async {
    // Android 설정
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    // macOS 설정
    const macOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: macOSSettings,
    );

    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // 권한 요청 (iOS/Android 13+)
    await _requestPermissions();

    if (kDebugMode) {
      debugPrint('✅ flutter_local_notifications 초기화 완료');
    }
  }

  /// 권한 요청
  static Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    } else if (Platform.isAndroid) {
      final androidPlugin = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // Android 13+ 권한 요청
      await androidPlugin?.requestNotificationsPermission();

      // Android 12+ 정확한 알람 권한 요청
      await androidPlugin?.requestExactAlarmsPermission();
    }
  }

  /// 알림 탭 처리
  static void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('🔔 알림 탭됨: ${response.payload}');
    }
    // TODO: 알림 탭 처리 로직 구현
  }

  /// 백그라운드 알림 탭 처리
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('🔔 백그라운드 알림 탭됨: ${response.payload}');
    }
    // TODO: 백그라운드 알림 탭 처리 로직 구현
  }

  /// Android 알림 채널 생성
  static Future<void> createNotificationChannel({
    required String id,
    required String name,
    required String description,
    Importance importance = Importance.high,
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    if (!Platform.isAndroid) return;

    final channel = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
      playSound: playSound,
      enableVibration: enableVibration,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    if (kDebugMode) {
      debugPrint('✅ Android 알림 채널 생성됨: $id');
    }
  }

  /// 기본 채널 생성
  static Future<void> createDefaultChannels() async {
    // 기본 알림 채널
    await createNotificationChannel(
      id: 'basic_channel',
      name: '基本通知',
      description: '一般的な通知',
    );

    // 스케줄 알람 채널
    await createNotificationChannel(
      id: 'scheduled_channel',
      name: 'スケジュールアラーム',
      description: '予定されたアラーム通知',
      importance: Importance.max,
    );
  }

  /// 권한 확인
  static Future<bool> isNotificationAllowed() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final iosPlugin = plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      // iOS에서는 별도 확인 방법 없음, true 반환
      return iosPlugin != null;
    } else if (Platform.isAndroid) {
      final androidPlugin = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    }
    return true;
  }
}
