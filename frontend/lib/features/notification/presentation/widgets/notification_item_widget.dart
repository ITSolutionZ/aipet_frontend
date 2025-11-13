import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../components/cards/notification_card_component.dart';

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
