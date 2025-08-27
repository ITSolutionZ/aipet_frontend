import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/entities.dart';

/// 알림 아이템 위젯 (기존 호환성)
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
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: AppColors.pointPink,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 알림 타입별 아이콘
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.type,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 알림 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppFonts.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.pointDark,
                            ),
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.pointBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.body,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // 더보기 버튼
              Icon(
                Icons.chevron_right,
                color: AppColors.pointDark.withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
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

  IconData _getNotificationIcon(NotificationType type) {
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}
