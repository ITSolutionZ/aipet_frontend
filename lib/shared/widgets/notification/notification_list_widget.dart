import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes/route_constants.dart';
import '../../../features/notification/domain/entities/entities.dart';
import '../../shared.dart';

/// 알림 목록 위젯
///
/// 알림 목록을 표시하고 관리하는 위젯입니다.
class NotificationListWidget extends ConsumerStatefulWidget {
  final NotificationType? filterType;
  final NotificationStatus? filterStatus;
  final int maxItems;
  final bool showEmptyState;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onNotificationDelete;

  const NotificationListWidget({
    super.key,
    this.filterType,
    this.filterStatus,
    this.maxItems = 50,
    this.showEmptyState = true,
    this.onNotificationTap,
    this.onNotificationDelete,
  });

  @override
  ConsumerState<NotificationListWidget> createState() =>
      _NotificationListWidgetState();
}

class _NotificationListWidgetState
    extends ConsumerState<NotificationListWidget> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = NotificationService();
      final notifications = await notificationService.getNotifications(
        status: widget.filterStatus,
        type: widget.filterType,
        limit: widget.maxItems,
      );

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('알림 목록 로드 오류: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      final notificationService = NotificationService();
      await notificationService.createNotification(
        title: notification.title,
        body: notification.body,
        type: notification.type,
        priority: notification.priority,
        data: notification.data,
        actions: notification.actions,
        imageUrl: notification.imageUrl,
        icon: notification.icon,
      );

      // 목록 새로고침
      await _loadNotifications();
    } catch (e) {
      if (kDebugMode) {
        print('알림 읽음 처리 오류: $e');
      }
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      final notificationService = NotificationService();
      await notificationService.deleteNotification(notification.id);

      // 목록 새로고침
      await _loadNotifications();

      // 삭제 콜백 호출
      widget.onNotificationDelete?.call();
    } catch (e) {
      if (kDebugMode) {
        print('알림 삭제 오류: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      if (widget.showEmptyState) {
        return _buildEmptyState();
      }
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.pointGray,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '알림이 없습니다',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '새로운 알림이 오면 여기에 표시됩니다',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (notification.isUnread) {
                _markAsRead(notification);
              }
              // 알림 상세 화면으로 이동
              context.push(
                '${RouteConstants.notificationDetailRoute}?id=${notification.id}',
              );
            },
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(notification),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNotificationHeader(notification),
                        const SizedBox(height: AppSpacing.xs),
                        _buildNotificationBody(notification),
                        if (notification.actions != null &&
                            notification.actions!.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _buildNotificationActions(notification),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildNotificationMeta(notification),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.general:
        iconData = Icons.notifications;
        iconColor = AppColors.pointBlue;
        break;
      case NotificationType.reservation:
        iconData = Icons.calendar_today;
        iconColor = AppColors.pointGreen;
        break;
      case NotificationType.walk:
        iconData = Icons.directions_walk;
        iconColor = AppColors.pointBrown;
        break;
      case NotificationType.feeding:
        iconData = Icons.restaurant;
        iconColor = AppColors.pointBrown;
        break;
      case NotificationType.health:
        iconData = Icons.favorite;
        iconColor = AppColors.pointGreen;
        break;
      case NotificationType.medication:
        iconData = Icons.medication;
        iconColor = AppColors.pointBlue;
        break;
      case NotificationType.system:
        iconData = Icons.settings;
        iconColor = AppColors.pointGray;
        break;
      case NotificationType.food:
        iconData = Icons.restaurant;
        iconColor = AppColors.pointGreen;
        break;
      case NotificationType.appointment:
        iconData = Icons.calendar_today;
        iconColor = AppColors.pointBrown;
        break;
      case NotificationType.reminder:
        iconData = Icons.alarm;
        iconColor = AppColors.pointBlue;
        break;
      case NotificationType.medical:
        iconData = Icons.medical_services;
        iconColor = AppColors.pointPink;
        break;
      case NotificationType.grooming:
        iconData = Icons.content_cut;
        iconColor = AppColors.pointBrown;
        break;
      case NotificationType.emergency:
        iconData = Icons.warning;
        iconColor = AppColors.pointPink;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildNotificationHeader(NotificationModel notification) {
    return Row(
      children: [
        Expanded(
          child: Text(
            notification.title,
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: notification.isUnread
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: AppColors.pointDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (notification.isUnread)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.pointBlue,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationBody(NotificationModel notification) {
    return Text(
      notification.body,
      style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNotificationActions(NotificationModel notification) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: notification.actions!.map((action) {
        return InkWell(
          onTap: () {
            // アクション処理ロジック - 通知タイプに応じた画面遷移
            if (kDebugMode) {
              print('알림 액션 실행: ${action.title}');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.pointBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.pointBlue.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              action.title,
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationMeta(NotificationModel notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatTime(notification.createdAt),
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
        ),
        if (notification.priority == NotificationPriority.urgent) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '긴급',
              style: AppFonts.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
