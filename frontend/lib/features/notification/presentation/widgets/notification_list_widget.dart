import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';


import '../../../../shared/shared.dart';
import '../../data/providers/notification_providers.dart';
import '../../domain/entities/entities.dart';
import 'notification_list_item.dart';
import 'notification_states.dart';


/// 通知リストウィジェット
///
/// 通知リストを表示して管理するウィジェット
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
  @override
  Widget build(BuildContext context) {
    // Riverpod Providerを使用して通知リスト管理
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      data: (notifications) => _buildNotificationList(notifications),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => NotificationErrorState(error: error),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    LoggerService.debug('📱 NotificationListWidget - 受信した通知数: ${notifications.length}');

    // フィルタリング適用
    final filteredNotifications = _applyFilters(notifications);

    LoggerService.debug(
      '📱 フィルタリング後の通知数: ${filteredNotifications.length}, フィルター: ${widget.filterType}',
    );

    if (filteredNotifications.isEmpty) {
      if (widget.showEmptyState) {
        return const NotificationEmptyState();
      }
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationsProvider.notifier).refresh();
      },
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount:
            filteredNotifications.length +
            (filteredNotifications.length >= widget.maxItems ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 1),
        itemBuilder: (context, index) {
          // さらに読み込みボタン表示
          if (index == filteredNotifications.length) {
            return const NotificationLoadMoreButton();
          }

          final notification = filteredNotifications[index];
          return RepaintBoundary(
            key: ValueKey('notification_${notification.id}_$index'),
            child: NotificationListItem(
              notification: notification,
              onMarkAsRead: () => _markAsRead(notification),
              onDelete: () => _deleteNotification(notification),
              onDeleteConfirm: _showDeleteConfirmDialog,
            ),
          );
        },
      ),
    );
  }

  /// フィルター適用
  List<NotificationModel> _applyFilters(List<NotificationModel> notifications) {
    return notifications.where((notification) {
      if (widget.filterStatus != null &&
          notification.status != widget.filterStatus) {
        LoggerService.debug('  ❌ フィルタリング: ${notification.title} - status不一致');
        return false;
      }
      if (widget.filterType != null && notification.type != widget.filterType) {
        LoggerService.debug('  ❌ フィルタリング: ${notification.title} - type不一致');
        return false;
      }
      if (notification.isExpired) {
        LoggerService.debug(
          '  ❌ フィルタリング: ${notification.title} - 期限切れ (expiresAt: ${notification.expiresAt})',
        );
        return false;
      }
      LoggerService.debug('  ✅ 通過: ${notification.title}');
      return true;
    }).toList();
  }

  /// 既読にする
  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isUnread) return; // すでに既読の場合は処理しない

    try {
      await ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.id);
      widget.onNotificationTap?.call();
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 削除確認ダイアログ表示
  Future<bool?> _showDeleteConfirmDialog(
    BuildContext context,
    NotificationModel notification,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知削除'),
        content: const Text('この通知を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  /// 通知削除
  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      await ref
          .read(notificationsProvider.notifier)
          .deleteNotification(notification.id);
      widget.onNotificationDelete?.call();
    } catch (e) {
      if (kDebugMode) {}
    }
  }
}
