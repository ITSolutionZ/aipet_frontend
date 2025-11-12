import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../../domain/entities/entities.dart';
import '../utils/notification_ui_utils.dart';

/// 通知リストアイテムウィジェット
///
/// 個別の通知を表示するDismissible付きアイテム
class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;
  final Future<bool?> Function(BuildContext, NotificationModel) onDeleteConfirm;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
    required this.onDeleteConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) async {
        return onDeleteConfirm(context, notification);
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: _buildNotificationCard(context),
    );
  }

  /// Dismissible背景
  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.md),
      color: Colors.red,
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  /// 通知カード
  Widget _buildNotificationCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                NotificationUIUtils.buildNotificationIcon(notification.type),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildNotificationContent()),
                const SizedBox(width: AppSpacing.sm),
                _buildNotificationMetadata(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 通知コンテンツ
  Widget _buildNotificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          style: NotificationUIUtils.getTitleStyle(notification.isUnread),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          notification.body,
          style: NotificationUIUtils.bodyStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 通知メタデータ（時間とバッジ）
  Widget _buildNotificationMetadata() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormatService.formatRelativeTime(notification.createdAt),
          style: NotificationUIUtils.timeStyle,
        ),
        if (notification.isUnread) ...[
          const SizedBox(height: 4),
          NotificationUIUtils.buildUnreadIndicator(),
        ],
      ],
    );
  }

  /// タップ処理
  void _handleTap(BuildContext context) {
    if (notification.isUnread) {
      onMarkAsRead();
    }
    // 通知詳細画面へ移動
    context.push(
      '${RouteConstants.notificationDetailRoute}?id=${notification.id}',
    );
  }
}
