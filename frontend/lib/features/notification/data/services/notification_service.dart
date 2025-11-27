import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/domain.dart' as domain;
import 'helpers/notification_display_helper.dart';
import 'helpers/notification_initialization_helper.dart';

/// 알림 서비스
///
/// 로컬 알림 및 푸시 알림을 관리하는 서비스입니다.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _tag = 'NotificationService';

  final StreamController<domain.NotificationModel> _notificationController =
      StreamController<domain.NotificationModel>.broadcast();

  /// 알림 스트림
  Stream<domain.NotificationModel> get notificationStream =>
      _notificationController.stream;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    // flutter_local_notifications 초기화
    await NotificationInitializationHelper.initialize();

    // 기본 채널 생성 (Android)
    await NotificationInitializationHelper.createDefaultChannels();

    if (kDebugMode) {
      debugPrint('✅ [$_tag] flutter_local_notifications 초기화 완료');
    }
  }

  /// 알림 생성
  Future<void> createNotification({
    required String title,
    required String body,
    required domain.NotificationType type,
    domain.NotificationPriority priority = domain.NotificationPriority.normal,
    DateTime? scheduledDate,
    Duration? expiresAfter,
    Map<String, dynamic>? data,
    List<domain.NotificationAction>? actions,
    String? imageUrl,
    String? icon,
  }) async {
    final plugin = NotificationInitializationHelper.plugin;
    final notificationId = DateTime.now().millisecondsSinceEpoch % 2147483647;

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

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.show(
      notificationId,
      title,
      body,
      details,
      payload: data?.toString(),
    );

    if (kDebugMode) {
      debugPrint('[$_tag] ✅ 알림 생성 완료: $title');
    }
  }

  /// 알림 설정 가져오기
  Future<domain.NotificationSettings> getNotificationSettings() async {
    // 기본 설정 반환
    return const domain.NotificationSettings(enabled: true);
  }

  /// 알림 설정 저장
  Future<void> saveNotificationSettings(
    domain.NotificationSettings settings,
  ) async {
    // TODO: 설정 저장 구현
    if (kDebugMode) {
      debugPrint('알림 설정 저장: enabled=${settings.enabled}');
    }
  }

  /// 스케줄 알람 등록
  Future<void> scheduleNotification(
    domain.NotificationSchedule schedule,
  ) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '[$_tag] 🔔 스케줄 알람 등록 - ${schedule.time.hour}:${schedule.time.minute}',
        );
      }

      await NotificationDisplayHelper.scheduleNotification(null, schedule);

      if (kDebugMode) {
        debugPrint('[$_tag] ✅ 스케줄 알람 등록 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 스케줄 알람 등록 실패: $e');
      }
      rethrow;
    }
  }

  /// 스케줄 알람 취소
  Future<void> cancelScheduledNotification(String scheduleId) async {
    try {
      if (kDebugMode) {
        debugPrint('[$_tag] 🔔 스케줄 알람 취소 - ID: $scheduleId');
      }

      await NotificationDisplayHelper.cancelScheduledNotification(
        null,
        scheduleId,
      );

      if (kDebugMode) {
        debugPrint('[$_tag] ✅ 스케줄 알람 취소 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 스케줄 알람 취소 실패: $e');
      }
      rethrow;
    }
  }

  /// 권한 확인
  Future<bool> isNotificationAllowed() async {
    return NotificationInitializationHelper.isNotificationAllowed();
  }

  /// 리소스 정리
  void dispose() {
    _notificationController.close();
  }
}
