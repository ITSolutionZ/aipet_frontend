import 'dart:async';
import 'package:aipet_frontend/shared/core/services/logger_service.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../domain/domain.dart';
import 'helpers/helpers.dart';
import 'notification_local_storage_service.dart';

/// 알림 서비스
///
/// 로컬 알림 및 푸시 알림을 관리하는 서비스입니다.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _tag = 'NotificationService';

  late FlutterLocalNotificationsPlugin _localNotifications;
  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();

  /// 알림 스트림
  Stream<NotificationModel> get notificationStream =>
      _notificationController.stream;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // 초기화 설정 (헬퍼 위임)
    final initSettings =
        NotificationInitializationHelper.getInitializationSettings();

    // 알림 서비스 초기화
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (kDebugMode) {
      LoggerService.debug('알림 서비스 초기화 완료');
    }
  }

  /// 알림 생성
  Future<void> createNotification({
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.normal,
    DateTime? scheduledDate,
    Duration? expiresAfter,
    Map<String, dynamic>? data,
    List<NotificationAction>? actions,
    String? imageUrl,
    String? icon,
  }) async {
    // 알림 유효성 검사 (헬퍼 위임)
    final settings = await getNotificationSettings();
    if (!NotificationValidationHelper.canSendNotification(settings, type)) {
      return;
    }

    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      priority: priority,
      createdAt: DateTime.now(),
      expiresAt: expiresAfter != null ? DateTime.now().add(expiresAfter) : null,
      data: data,
      actions: actions,
      imageUrl: imageUrl,
      icon: icon,
    );

    // 로컬 알림 표시 (헬퍼 위임)
    await NotificationDisplayHelper.showLocalNotification(
      _localNotifications,
      notification,
      scheduledDate,
    );

    // 알림 저장 (로그만 기록)
    await NotificationLocalOperations.saveNotification(notification);

    // 스트림으로 알림 전송
    _notificationController.add(notification);

    if (kDebugMode) {
      LoggerService.debug('[$_tag] ✅ 알림 생성 완료: ${notification.title}');
    }
  }

  /// 알림 탭 처리 (헬퍼 위임)
  void _onNotificationTapped(NotificationResponse response) {
    NotificationResponseHelper.handleNotificationResponse(
      response,
      deleteNotification,
    );
  }

  /// 알림 목록 가져오기
  Future<List<NotificationModel>> getNotifications({
    NotificationStatus? status,
    NotificationType? type,
    int limit = 50,
  }) async {
    try {
      // 로컬 저장소에서 알림 가져오기
      final notificationsData =
          await NotificationLocalStorageService.getNotifications();

      final notifications = notificationsData
          .map((data) => NotificationModel.fromJson(data))
          .toList();

      // 필터링, 정렬, 제한 (헬퍼 위임)
      return NotificationQueryHelper.processNotifications(
        notifications,
        status: status,
        type: type,
        limit: limit,
      );
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('알림 목록 가져오기 실패: $e');
      }
      return [];
    }
  }

  /// 알림 삭제 (헬퍼 위임)
  Future<void> deleteNotification(String notificationId) async {
    await NotificationLocalOperations.deleteNotification(
      notificationId,
      _localNotifications,
    );
  }

  /// 모든 알림 삭제 (헬퍼 위임)
  Future<void> clearAllNotifications() async {
    await NotificationLocalOperations.clearAllNotifications(
      _localNotifications,
    );
  }

  /// 알림을 읽음으로 표시 (헬퍼 위임)
  Future<void> markNotificationAsRead(String notificationId) async {
    await NotificationLocalOperations.markAsRead(notificationId);
  }

  /// 읽지 않은 알림 개수 가져오기
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications(
        status: NotificationStatus.unread,
      );
      return notifications.length;
    } catch (e) {
      if (kDebugMode) {}
      return 0;
    }
  }

  /// 알림 설정 가져오기
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      // 로컬 저장소에서 설정 가져오기
      final settingsData = await NotificationLocalStorageService.getSettings();
      return NotificationSettings.fromJson(settingsData);
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('알림 설정 가져오기 실패: $e');
      }
      return const NotificationSettings();
    }
  }

  /// 알림 설정 저장
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      await NotificationLocalStorageService.saveSettings(settings.toJson());
    } catch (e) {
      if (kDebugMode) {
        LoggerService.debug('알림 설정 저장 실패: $e');
      }
    }
  }

  // 사용하지 않는 메서드들 제거

  /// 리소스 정리
  void dispose() {
    _notificationController.close();
  }
}
