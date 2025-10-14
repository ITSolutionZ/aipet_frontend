import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 알림 액션 처리 헬퍼
class NotificationActionHandler {
  /// 현재 컨텍스트를 가져오는 헬퍼 메서드
  static BuildContext? getCurrentContext() {
    try {
      return AppRouter.navigatorKey.currentContext;
    } catch (e) {
      try {
        return WidgetsBinding.instance.rootElement;
      } catch (e) {
        return null;
      }
    }
  }

  /// 알림 액션 처리
  static void handleNotificationAction(
    NotificationModel notification,
    String actionId,
    Function(String) onMarkAsRead,
    Function(String) onDelete,
  ) {
    final action = notification.actions?.firstWhere(
      (action) => action.id == actionId,
      orElse: () =>
          const NotificationAction(id: 'default', title: '기본', type: 'default'),
    );

    if (kDebugMode) {
      debugPrint('🔔 Handling notification action: ${action?.type}');
    }

    switch (action?.type) {
      case 'open_screen':
        handleOpenScreenAction(action, notification);
        break;
      case 'dismiss':
        handleDismissAction(notification, onDelete);
        break;
      case 'confirm':
        handleConfirmAction(notification, onMarkAsRead);
        break;
      case 'cancel':
        handleCancelAction(notification, onMarkAsRead);
        break;
      case 'view_details':
        handleViewDetailsAction(notification);
        break;
      case 'take_action':
        handleTakeActionAction(notification, onMarkAsRead);
        break;
      default:
        handleDefaultAction(notification, onMarkAsRead);
        break;
    }
  }

  /// 화면 열기 액션 처리
  static void handleOpenScreenAction(
    NotificationAction? action,
    NotificationModel notification,
  ) {
    final screenPath = action?.data?['screen_path'] as String?;
    final petId = action?.data?['pet_id'] as String?;

    if (screenPath != null) {
      final context = getCurrentContext();
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
  static void handleDismissAction(
    NotificationModel notification,
    Function(String) onDelete,
  ) {
    onDelete(notification.id);
  }

  /// 확인 액션 처리
  static void handleConfirmAction(
    NotificationModel notification,
    Function(String) onMarkAsRead,
  ) {
    onMarkAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.feeding:
        navigateToFeeding();
        break;
      case NotificationType.walk:
        navigateToWalk();
        break;
      case NotificationType.health:
        navigateToHealth();
        break;
      case NotificationType.medication:
        navigateToMedication();
        break;
      default:
        break;
    }
  }

  /// 취소 액션 처리
  static void handleCancelAction(
    NotificationModel notification,
    Function(String) onMarkAsRead,
  ) {
    onMarkAsRead(notification.id);
  }

  /// 상세보기 액션 처리
  static void handleViewDetailsAction(NotificationModel notification) {
    final context = getCurrentContext();
    if (context != null) {
      context.go('${AppRouter.notificationDetailRoute}/${notification.id}');
    }
  }

  /// 액션 수행 액션 처리
  static void handleTakeActionAction(
    NotificationModel notification,
    Function(String) onMarkAsRead,
  ) {
    switch (notification.type) {
      case NotificationType.feeding:
        navigateToFeeding();
        break;
      case NotificationType.walk:
        navigateToWalk();
        break;
      case NotificationType.health:
        navigateToHealth();
        break;
      case NotificationType.medication:
        navigateToMedication();
        break;
      case NotificationType.reservation:
        navigateToReservation();
        break;
      default:
        navigateToHome();
        break;
    }
  }

  /// 기본 액션 처리
  static void handleDefaultAction(
    NotificationModel notification,
    Function(String) onMarkAsRead,
  ) {
    onMarkAsRead(notification.id);
    navigateToHome();
  }

  /// 급여 화면으로 이동
  static void navigateToFeeding() {
    final context = getCurrentContext();
    if (context != null) {
      context.go(AppRouter.feedingScheduleRoute);
    }
  }

  /// 산책 화면으로 이동
  static void navigateToWalk() {
    final context = getCurrentContext();
    if (context != null) {
      context.go(AppRouter.walkRoute);
    }
  }

  /// 건강 관리 화면으로 이동
  static void navigateToHealth() {
    final context = getCurrentContext();
    if (context != null) {
      context.go(AppRouter.vaccinesRoute);
    }
  }

  /// 약물 관리 화면으로 이동
  static void navigateToMedication() {
    final context = getCurrentContext();
    if (context != null) {
      context.go(AppRouter.schedulingRoute);
    }
  }

  /// 예약 화면으로 이동
  static void navigateToReservation() {
    final context = getCurrentContext();
    if (context != null) {
      context.go(AppRouter.schedulingRoute);
    }
  }

  /// 홈 화면으로 이동
  static void navigateToHome() {
    final context = getCurrentContext();
    if (context != null) {
      context.go(AppRouter.homeRoute);
    }
  }
}
