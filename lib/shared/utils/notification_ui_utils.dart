import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 🎯 알림 UI 유틸리티
///
/// 알림 관련 UI 처리를 위한 공통 유틸리티
class NotificationUIUtils {
  /// 알림 타입별 아이콘 가져오기
  static IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.reservation:
        return Icons.calendar_today;
      case NotificationType.walk:
        return Icons.directions_walk;
      case NotificationType.feeding:
        return Icons.restaurant;
      case NotificationType.health:
        return Icons.favorite;
      case NotificationType.medication:
        return Icons.medication;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.food:
        return Icons.restaurant;
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.medical:
        return Icons.medical_services;
      case NotificationType.grooming:
        return Icons.content_cut;
      case NotificationType.emergency:
        return Icons.warning;
    }
  }

  /// 알림 타입별 색상 가져오기
  static Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return AppColors.pointBlue;
      case NotificationType.reservation:
        return AppColors.pointGreen;
      case NotificationType.walk:
        return AppColors.pointBrown;
      case NotificationType.feeding:
        return AppColors.pointBrown;
      case NotificationType.health:
        return AppColors.pointGreen;
      case NotificationType.medication:
        return AppColors.pointBlue;
      case NotificationType.system:
        return AppColors.pointGray;
      case NotificationType.food:
        return AppColors.pointGreen;
      case NotificationType.appointment:
        return AppColors.pointBrown;
      case NotificationType.reminder:
        return AppColors.pointBlue;
      case NotificationType.medical:
        return AppColors.pointPink;
      case NotificationType.grooming:
        return AppColors.pointBrown;
      case NotificationType.emergency:
        return AppColors.pointPink;
    }
  }

  /// 알림 아이콘 위젯 생성
  static Widget buildNotificationIcon(
    NotificationType type, {
    double size = 18,
    double containerSize = 36,
  }) {
    final iconData = getNotificationIcon(type);
    final color = getNotificationColor(type);

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(containerSize / 2),
      ),
      child: Icon(iconData, color: color, size: size),
    );
  }

  /// 알림 우선순위별 색상 가져오기
  static Color getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return AppColors.pointGray;
      case NotificationPriority.normal:
        return AppColors.pointBlue;
      case NotificationPriority.high:
        return AppColors.pointBrown;
      case NotificationPriority.urgent:
        return AppColors.pointPink;
    }
  }

  /// 알림 상태별 스타일 가져오기
  static TextStyle getTitleStyle(bool isUnread) {
    return TextStyle(
      fontSize: 15,
      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
      color: AppColors.pointDark,
    );
  }

  /// 알림 본문 스타일
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: AppColors.pointGray,
    height: 1.3,
  );

  /// 알림 시간 스타일
  static const TextStyle timeStyle = TextStyle(
    fontSize: 12,
    color: AppColors.pointGray,
  );

  /// 읽지 않은 알림 표시 점 생성
  static Widget buildUnreadIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}
