import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router/app_router.dart';
import '../../features/notification/domain/entities/notification_model.dart';
import '../shared.dart';

/// 알림 서비스
///
/// 로컬 알림 및 푸시 알림을 관리하는 서비스입니다.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _notificationsKey = 'notifications';
  static const String _settingsKey = 'notification_settings';

  late FlutterLocalNotificationsPlugin _localNotifications;
  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();

  /// 알림 스트림
  Stream<NotificationModel> get notificationStream =>
      _notificationController.stream;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Android 설정
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 초기화 설정
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 알림 서비스 초기화
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (kDebugMode) {
      print('알림 서비스 초기화 완료');
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
    // 알림 설정 확인
    final settings = await getNotificationSettings();
    if (!settings.isTypeEnabled(type)) {
      if (kDebugMode) {
        print('알림 타입이 비활성화됨: $type');
      }
      return;
    }

    // 조용한 시간 확인
    if (settings.isQuietTime) {
      if (kDebugMode) {
        print('조용한 시간 중이므로 알림을 표시하지 않음');
      }
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

    // 로컬 알림 표시
    await _showLocalNotification(notification, scheduledDate);

    // 알림 저장
    await _saveNotification(notification);

    // 스트림으로 알림 전송
    _notificationController.add(notification);

    if (kDebugMode) {
      print('알림 생성됨: ${notification.title}');
    }
  }

  /// 로컬 알림 표시
  Future<void> _showLocalNotification(
    NotificationModel notification,
    DateTime? scheduledDate,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'aipet_channel',
      'AI Pet 알림',
      channelDescription: 'AI Pet 앱의 모든 알림',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'aipet_category',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (scheduledDate != null) {
      // 예약된 알림 (현재는 즉시 알림으로 처리)
      await _localNotifications.show(
        int.parse(notification.id),
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(notification.toJson()),
      );
    } else {
      // 즉시 알림
      await _localNotifications.show(
        int.parse(notification.id),
        notification.title,
        notification.body,
        details,
        payload: jsonEncode(notification.toJson()),
      );
    }
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final notificationData = jsonDecode(response.payload!);
        final notification = NotificationModel.fromJson(notificationData);

        // 알림을 읽음 상태로 변경
        _markAsRead(notification.id);

        // 액션 처리
        if (response.actionId != null) {
          _handleNotificationAction(notification, response.actionId!);
        }
      } catch (e) {
        if (kDebugMode) {
          print('알림 탭 처리 오류: $e');
        }
      }
    }
  }

  /// 알림 액션 처리
  void _handleNotificationAction(
    NotificationModel notification,
    String actionId,
  ) {
    final action = notification.actions?.firstWhere(
      (action) => action.id == actionId,
      orElse: () =>
          const NotificationAction(id: 'default', title: '기본', type: 'default'),
    );

    if (kDebugMode) {
      print('알림 액션 실행: ${action?.title} (${action?.type})');
    }

    // 액션 타입별 처리 로직
    switch (action?.type) {
      case 'open_screen':
        _handleOpenScreenAction(action, notification);
        break;
      case 'dismiss':
        _handleDismissAction(notification);
        break;
      case 'confirm':
        _handleConfirmAction(notification);
        break;
      case 'cancel':
        _handleCancelAction(notification);
        break;
      case 'view_details':
        _handleViewDetailsAction(notification);
        break;
      case 'take_action':
        _handleTakeActionAction(notification);
        break;
      default:
        _handleDefaultAction(notification);
        break;
    }
  }

  /// 화면 열기 액션 처리
  void _handleOpenScreenAction(
    NotificationAction? action,
    NotificationModel notification,
  ) {
    final screenPath = action?.data?['screen_path'] as String?;
    final petId = action?.data?['pet_id'] as String?;

    if (screenPath != null) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        if (petId != null) {
          context.go('$screenPath/$petId');
        } else {
          context.go(screenPath);
        }
      }
    }
  }

  /// 알림 닫기 액션 처리
  void _handleDismissAction(NotificationModel notification) {
    deleteNotification(notification.id);
  }

  /// 확인 액션 처리
  void _handleConfirmAction(NotificationModel notification) {
    // 알림을 읽음 상태로 변경하고 관련 작업 수행
    _markAsRead(notification.id);

    // 알림 타입에 따른 추가 처리
    switch (notification.type) {
      case NotificationType.feeding:
        _navigateToFeeding();
        break;
      case NotificationType.walk:
        _navigateToWalk();
        break;
      case NotificationType.health:
        _navigateToHealth();
        break;
      case NotificationType.medication:
        _navigateToMedication();
        break;
      default:
        break;
    }
  }

  /// 취소 액션 처리
  void _handleCancelAction(NotificationModel notification) {
    // 알림을 읽음 상태로 변경
    _markAsRead(notification.id);
  }

  /// 상세보기 액션 처리
  void _handleViewDetailsAction(NotificationModel notification) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go('${AppRouter.notificationDetailRoute}/${notification.id}');
    }
  }

  /// 액션 수행 액션 처리
  void _handleTakeActionAction(NotificationModel notification) {
    // 알림 타입에 따른 즉시 액션 수행
    switch (notification.type) {
      case NotificationType.feeding:
        _navigateToFeeding();
        break;
      case NotificationType.walk:
        _navigateToWalk();
        break;
      case NotificationType.health:
        _navigateToHealth();
        break;
      case NotificationType.medication:
        _navigateToMedication();
        break;
      case NotificationType.reservation:
        _navigateToReservation();
        break;
      default:
        _navigateToHome();
        break;
    }
  }

  /// 기본 액션 처리
  void _handleDefaultAction(NotificationModel notification) {
    // 알림을 읽음 상태로 변경하고 홈으로 이동
    _markAsRead(notification.id);
    _navigateToHome();
  }

  /// 급여 화면으로 이동
  void _navigateToFeeding() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(AppRouter.feedingScheduleRoute);
    }
  }

  /// 산책 화면으로 이동
  void _navigateToWalk() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(AppRouter.walkRoute);
    }
  }

  /// 건강 관리 화면으로 이동
  void _navigateToHealth() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(AppRouter.vaccinesRoute);
    }
  }

  /// 약물 관리 화면으로 이동
  void _navigateToMedication() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(AppRouter.schedulingRoute);
    }
  }

  /// 예약 화면으로 이동
  void _navigateToReservation() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(AppRouter.schedulingRoute);
    }
  }

  /// 홈 화면으로 이동
  void _navigateToHome() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go(AppRouter.homeRoute);
    }
  }

  /// 알림 목록 가져오기
  Future<List<NotificationModel>> getNotifications({
    NotificationStatus? status,
    NotificationType? type,
    int limit = 50,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

      final notifications = notificationsJson
          .map((json) => NotificationModel.fromJson(jsonDecode(json)))
          .where((notification) {
            if (status != null && notification.status != status) return false;
            if (type != null && notification.type != type) return false;
            if (notification.isExpired) return false;
            return true;
          })
          .toList();

      // 최신순으로 정렬
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {
        print('알림 목록 가져오기 오류: $e');
      }
      return [];
    }
  }

  /// 알림 저장
  Future<void> _saveNotification(NotificationModel notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

      // 기존 알림 제거 (ID가 같은 경우)
      notificationsJson.removeWhere((json) {
        try {
          final existingNotification = NotificationModel.fromJson(
            jsonDecode(json),
          );
          return existingNotification.id == notification.id;
        } catch (e) {
          return false;
        }
      });

      // 새 알림 추가
      notificationsJson.add(jsonEncode(notification.toJson()));

      // 최대 100개까지만 유지
      if (notificationsJson.length > 100) {
        notificationsJson.removeRange(0, notificationsJson.length - 100);
      }

      await prefs.setStringList(_notificationsKey, notificationsJson);
    } catch (e) {
      if (kDebugMode) {
        print('알림 저장 오류: $e');
      }
    }
  }

  /// 알림 읽음 처리
  Future<void> _markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

      final updatedNotifications = notificationsJson.map((json) {
        try {
          final notification = NotificationModel.fromJson(jsonDecode(json));
          if (notification.id == notificationId) {
            return jsonEncode(notification.copyAsRead().toJson());
          }
          return json;
        } catch (e) {
          return json;
        }
      }).toList();

      await prefs.setStringList(_notificationsKey, updatedNotifications);
    } catch (e) {
      if (kDebugMode) {
        print('알림 읽음 처리 오류: $e');
      }
    }
  }

  /// 알림 삭제
  Future<void> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

      final updatedNotifications = notificationsJson.map((json) {
        try {
          final notification = NotificationModel.fromJson(jsonDecode(json));
          if (notification.id == notificationId) {
            return jsonEncode(notification.copyAsDeleted().toJson());
          }
          return json;
        } catch (e) {
          return json;
        }
      }).toList();

      await prefs.setStringList(_notificationsKey, updatedNotifications);

      // 로컬 알림도 취소
      await _localNotifications.cancel(int.parse(notificationId));
    } catch (e) {
      if (kDebugMode) {
        print('알림 삭제 오류: $e');
      }
    }
  }

  /// 모든 알림 삭제
  Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      await _localNotifications.cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print('모든 알림 삭제 오류: $e');
      }
    }
  }

  /// 읽지 않은 알림 개수 가져오기
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications(
        status: NotificationStatus.unread,
      );
      return notifications.length;
    } catch (e) {
      if (kDebugMode) {
        print('읽지 않은 알림 개수 가져오기 오류: $e');
      }
      return 0;
    }
  }

  /// 알림 설정 가져오기
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final settingsJson = await SecureStorageService.getStringUnencrypted(
        _settingsKey,
      );
      if (settingsJson != null) {
        return NotificationSettings.fromJson(jsonDecode(settingsJson));
      }
    } catch (e) {
      if (kDebugMode) {
        print('알림 설정 가져오기 오류: $e');
      }
    }
    return const NotificationSettings();
  }

  /// 알림 설정 저장
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final settingsJson = jsonEncode(settings.toJson());
      await SecureStorageService.setStringUnencrypted(
        _settingsKey,
        settingsJson,
      );
    } catch (e) {
      if (kDebugMode) {
        print('알림 설정 저장 오류: $e');
      }
    }
  }

  // 사용하지 않는 메서드들 제거

  /// 리소스 정리
  void dispose() {
    _notificationController.close();
  }
}
