import 'dart:async';
import 'dart:convert';

import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 알림 서비스
///
/// 로컬 알림 및 푸시 알림을 관리하는 서비스입니다.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _tag = 'NotificationService';

  static const String _notificationsKey = 'notifications';
  static const String _settingsKey = 'notification_settings';

  late FlutterLocalNotificationsPlugin _localNotifications;
  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();

  /// 알림 스트림
  Stream<NotificationModel> get notificationStream => _notificationController.stream;

  /// 알림 서비스 초기화
  Future<void> initialize() async {
    _localNotifications = FlutterLocalNotificationsPlugin();

    // Android 설정
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 초기화 설정
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    // 알림 서비스 초기화
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 🔄 레거시 데이터 마이그레이션 수행
    await _performDataMigration();

    if (kDebugMode) {
      debugPrint('알림 서비스 초기화 완료');
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
      if (kDebugMode) {}
      return;
    }

    // 조용한 시간 확인
    if (settings.isQuietTime) {
      if (kDebugMode) {}
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

    if (kDebugMode) {}
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

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

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
        if (kDebugMode) {}
      }
    }
  }

  /// 알림 액션 처리
  void _handleNotificationAction(NotificationModel notification, String actionId) {
    final action = notification.actions?.firstWhere(
      (action) => action.id == actionId,
      orElse: () => const NotificationAction(id: 'default', title: '기본', type: 'default'),
    );

    if (kDebugMode) {}

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
  void _handleOpenScreenAction(NotificationAction? action, NotificationModel notification) {
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
      // API 연계 전까지는 Mock 데이터 사용
      List<NotificationModel> notifications = NotificationMockService.getMockNotifications();

      // 필터링 적용
      notifications = notifications.where((notification) {
        if (status != null && notification.status != status) return false;
        if (type != null && notification.type != type) return false;
        if (notification.isExpired) return false;
        return true;
      }).toList();

      // 최신순으로 정렬
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications.take(limit).toList();
    } catch (e) {
      if (kDebugMode) {}
      return [];
    }
  }

  /// 🔄 레거시 데이터 마이그레이션 수행
  Future<void> _performDataMigration() async {
    try {
      // 프론트엔드 중심 구조에서는 단순히 캐시를 정리
      if (kDebugMode) {
        debugPrint('[$_tag] 🗄️ 캐시 초기화 수행 (레거시 마이그레이션 대체)');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('❌ 알림 데이터 마이그레이션 실패: $error');
      }
    }
  }

  /// 알림 저장 (프론트엔드 중심 - 로그만 기록)
  Future<void> _saveNotification(NotificationModel notification) async {
    try {
      // 프론트엔드 중심 구조에서는 API를 통해 알림이 관리되므로
      // 로컬 저장 대신 간단한 로그만 기록
      if (kDebugMode) {
        debugPrint('[$_tag] 📝 알림 수신 기록: ${notification.title}');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[$_tag] ❌ 알림 기록 중 오류: $error');
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
      if (kDebugMode) {}
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

      // 로컬 알림도 취소 (ID가 숫자인 경우에만)
      try {
        final id = int.parse(notificationId);
        await _localNotifications.cancel(id);
      } catch (e) {
        // ID가 숫자가 아닌 경우 (mock_data 등) 로컬 알림 취소 건너뛰기
        if (kDebugMode) {}
      }
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 모든 알림 삭제
  Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      await _localNotifications.cancelAll();
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 알림을 읽음으로 표시
  Future<void> markNotificationAsRead(String notificationId) async {
    await _markAsRead(notificationId);
  }

  /// 읽지 않은 알림 개수 가져오기
  Future<int> getUnreadCount() async {
    try {
      final notifications = await getNotifications(status: NotificationStatus.unread);
      return notifications.length;
    } catch (e) {
      if (kDebugMode) {}
      return 0;
    }
  }

  /// 알림 설정 가져오기
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      // API 연계 전까지는 Mock 데이터 사용
      return NotificationMockService.getMockNotificationSettings();
    } catch (e) {
      if (kDebugMode) {}
      return const NotificationSettings();
    }
  }

  /// 알림 설정 저장
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final settingsJson = jsonEncode(settings.toJson());
      await SecureStorageService.setString(_settingsKey, settingsJson);
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  // 사용하지 않는 메서드들 제거

  /// 리소스 정리
  void dispose() {
    _notificationController.close();
  }
}
