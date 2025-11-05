import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:awesome_notifications/awesome_notifications.dart';

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
    // Awesome Notifications 초기화
    await NotificationInitializationHelper.initialize();

    // 알림 탭 리스너 설정
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onNotificationTapped,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
    );

    if (kDebugMode) {
      debugPrint('✅ [$_tag] Awesome Notifications 초기화 완료');
    }
  }

  /// 알림 생성됨
  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreated(
    ReceivedNotification receivedNotification,
  ) async {
    if (kDebugMode) {
      debugPrint('🔔 [$_tag] 알림 생성됨: ${receivedNotification.title}');
    }
  }

  /// 알림 표시됨
  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(
    ReceivedNotification receivedNotification,
  ) async {
    if (kDebugMode) {
      debugPrint('🔔 [$_tag] 알림 표시됨: ${receivedNotification.title}');
    }
  }

  /// 알림 탭 처리
  @pragma('vm:entry-point')
  static Future<void> _onNotificationTapped(
    ReceivedAction receivedAction,
  ) async {
    if (kDebugMode) {
      debugPrint('🔔 [$_tag] 알림 탭됨: ${receivedAction.title}');
    }

    // TODO: 알림 탭 처리 로직 구현
    final payload = receivedAction.payload;
    if (payload != null && payload.containsKey('scheduleId')) {
      debugPrint('📋 스케줄 ID: ${payload['scheduleId']}');
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
    // 즉시 알림 생성
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch % 2147483647,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: data?.map((key, value) => MapEntry(key, value.toString())),
        notificationLayout: NotificationLayout.Default,
      ),
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

  /// 리소스 정리
  void dispose() {
    _notificationController.close();
  }
}
