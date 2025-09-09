import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';
import '../../../data/services/notification_icon_service.dart';
import '../../../domain/entities/notification_model.dart';

/// 알림 상세 액션 컴포넌트
class NotificationDetailActionsComponent extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onActionPressed;
  final VoidCallback onDeletePressed;

  const NotificationDetailActionsComponent({
    super.key,
    required this.notification,
    required this.onActionPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (notification.actionUrl == null) {
      return const SizedBox.shrink();
    }

    return ActionButtonsComponent(
      primaryButtonText: NotificationIconService.getActionText(
        notification.type,
      ),
      primaryButtonIcon: NotificationIconService.getActionIcon(
        notification.type,
      ),
      onPrimaryPressed: onActionPressed,
      secondaryButtonText: '通知を削除',
      secondaryButtonIcon: Icons.delete_outline,
      onSecondaryPressed: onDeletePressed,
    );
  }
}
