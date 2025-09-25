import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 알림 아이콘 및 색상 서비스 (UI 전용 로직)
class NotificationIconService {
  /// 알림 타입별 색상 가져오기
  static Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.food:
        return AppColors.pointGreen;
      case NotificationType.walk:
        return AppColors.pointBlue;
      case NotificationType.system:
        return AppColors.pointDark;
      case NotificationType.appointment:
        return AppColors.pointBrown;
      case NotificationType.health:
        return AppColors.pointPink;
      case NotificationType.reminder:
        return AppColors.pointOlive;
      case NotificationType.general:
      case NotificationType.reservation:
      case NotificationType.feeding:
      case NotificationType.medication:
      case NotificationType.medical:
      case NotificationType.grooming:
      case NotificationType.emergency:
        return AppColors.pointBlue;
    }
  }

  /// 알림 타입별 아이콘 가져오기
  static IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.food:
        return Icons.restaurant;
      case NotificationType.walk:
        return Icons.directions_walk;
      case NotificationType.system:
        return Icons.notifications;
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.health:
        return Icons.favorite;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.reservation:
        return Icons.calendar_today;
      case NotificationType.feeding:
        return Icons.restaurant;
      case NotificationType.medication:
        return Icons.medication;
      case NotificationType.medical:
        return Icons.medical_services;
      case NotificationType.grooming:
        return Icons.content_cut;
      case NotificationType.emergency:
        return Icons.warning;
    }
  }

  /// 액션 버튼용 아이콘 가져오기
  static IconData getActionIcon(NotificationType type) {
    switch (type) {
      case NotificationType.feeding:
        return Icons.restaurant;
      case NotificationType.walk:
        return Icons.directions_walk;
      case NotificationType.medical:
        return Icons.medical_services;
      case NotificationType.grooming:
        return Icons.content_cut;
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.emergency:
        return Icons.analytics;
      default:
        return Icons.arrow_forward;
    }
  }

  /// 액션 버튼 텍스트 가져오기
  static String getActionText(NotificationType type) {
    switch (type) {
      case NotificationType.feeding:
        return 'フード管理に移動';
      case NotificationType.walk:
        return '散歩記録に移動';
      case NotificationType.medical:
        return '健康管理に移動';
      case NotificationType.grooming:
        return '予約管理に移動';
      case NotificationType.appointment:
        return '予約詳細を見る';
      case NotificationType.emergency:
        return '分析結果を見る';
      default:
        return '詳細を見る';
    }
  }

  /// 토글 위젯용 아이콘 가져오기
  static IconData getToggleIcon(String title) {
    if (title.contains('食事') || title.contains('feeding')) {
      return Icons.restaurant;
    } else if (title.contains('散歩') || title.contains('walk')) {
      return Icons.pets;
    } else if (title.contains('システム') || title.contains('system')) {
      return Icons.notifications;
    } else {
      return Icons.alarm;
    }
  }
}
