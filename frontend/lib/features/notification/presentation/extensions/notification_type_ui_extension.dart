import 'package:flutter/material.dart';

import '../../domain/domain.dart';


/// NotificationType UI Extensions (Presentation Layer)
extension NotificationTypeUIExtension on NotificationType {
  /// 알림 타입별 색상
  Color get color {
    switch (this) {
      case NotificationType.general:
        return Colors.blue;
      case NotificationType.reservation:
        return Colors.orange;
      case NotificationType.walk:
        return Colors.green;
      case NotificationType.feeding:
        return Colors.amber;
      case NotificationType.health:
        return Colors.red;
      case NotificationType.medication:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.food:
        return Colors.amber;
      case NotificationType.appointment:
        return Colors.orange;
      case NotificationType.reminder:
        return Colors.blue;
      case NotificationType.medical:
        return Colors.red;
      case NotificationType.grooming:
        return Colors.purple;
      case NotificationType.emergency:
        return Colors.red;
    }
  }

  /// 알림 타입별 아이콘
  IconData get icon {
    switch (this) {
      case NotificationType.general:
        return Icons.notifications;
      case NotificationType.reservation:
        return Icons.calendar_today;
      case NotificationType.walk:
        return Icons.directions_walk;
      case NotificationType.feeding:
        return Icons.restaurant;
      case NotificationType.health:
        return Icons.medical_services;
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
}
