import 'package:aipet_frontend/features/notification/data/services/notification_icon_service.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/features/notification/presentation/components/cards/notification_card_component.dart';
import 'package:aipet_frontend/shared/core/services/date_format_service.dart';
import 'package:flutter/material.dart';

/// 알림 아이템 위젯 (UI와 로직 분리된 깨끗한 버전)
class NotificationItemWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationCardComponent(
      title: notification.title,
      body: notification.body,
      formattedTime: DateFormatService.formatRelativeTime(
        notification.createdAt,
      ),
      icon: NotificationIconService.getNotificationIcon(notification.type),
      iconColor: NotificationIconService.getNotificationColor(
        notification.type,
      ),
      isUnread: notification.isUnread,
      onTap: onTap,
      onDismiss: onDismiss,
    );
  }
}
