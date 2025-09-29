import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/notification/data/providers/notification_providers.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  @override
  Widget build(BuildContext context) {
    // Riverpod Provider를 사용하여 알림 목록 관리
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    return notificationsAsync.when(
      data: (notifications) => _buildNotificationList(notifications),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    // 필터링 적용
    final filteredNotifications = _applyFilters(notifications);

    if (filteredNotifications.isEmpty) {
      if (widget.showEmptyState) {
        return _buildEmptyState();
      }
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationsNotifierProvider.notifier).refresh();
      },
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount:
            filteredNotifications.length +
            (filteredNotifications.length >= widget.maxItems ? 1 : 0),
        separatorBuilder: (context, index) => const const const SizedBox(height: 1),
        itemBuilder: (context, index) {
          // 더보기 버튼 표시
          if (index == filteredNotifications.length) {
            return _buildLoadMoreButton();
          }

          final notification = filteredNotifications[index];
          return RepaintBoundary(
            key: ValueKey('notification_${notification.id}_$index'),
            child: _buildNotificationItem(notification),
          );
        },
      ),
    );
  }

  List<NotificationModel> _applyFilters(List<NotificationModel> notifications) {
    return notifications.where((notification) {
      if (widget.filterStatus != null &&
          notification.status != widget.filterStatus) {
        return false;
      }
      if (widget.filterType != null && notification.type != widget.filterType) {
        return false;
      }
      if (notification.isExpired) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isUnread) return; // 이미 읽음인 경우 처리하지 않음

    try {
      await ref
          .read(notificationsNotifierProvider.notifier)
          .markAsRead(notification.id);
      widget.onNotificationTap?.call();
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  /// 삭제 확인 다이얼로그 표시
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

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      await ref
          .read(notificationsNotifierProvider.notifier)
          .deleteNotification(notification.id);
      widget.onNotificationDelete?.call();
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  Widget _buildLoadMoreButton() {
    return Container(
      margin: const const const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: () {
          // 더보기 기능 구현 시 추가
        },
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: const const const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
          child: const Center(
            child: Text(
              '1件以上表示',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.pointBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.pointGray),
          const const const SizedBox(height: AppSpacing.md),
          Text(
            'エラーが発生しました',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const const const SizedBox(height: AppSpacing.sm),
          Text(
            '通知の読み込みに失敗しました',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
        ],
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
          const const const SizedBox(height: AppSpacing.md),
          Text(
            '通知がありません',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const const const SizedBox(height: AppSpacing.sm),
          Text(
            '新しい通知が届くとここに表示されます',
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
        padding: const const const EdgeInsets.only(right: AppSpacing.md),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return _showDeleteConfirmDialog(context, notification);
      },
      onDismissed: (direction) {
        _deleteNotification(notification);
      },
      child: Container(
        margin: const const const EdgeInsets.symmetric(
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
              padding: const const const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  NotificationUIUtils.buildNotificationIcon(notification.type),
                  const const const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: NotificationUIUtils.getTitleStyle(
                            notification.isUnread,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const const const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: NotificationUIUtils.bodyStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const const const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormatService.formatRelativeTime(
                          notification.createdAt,
                        ),
                        style: NotificationUIUtils.timeStyle,
                      ),
                      if (notification.isUnread) ...[
                        const const const SizedBox(height: 4),
                        NotificationUIUtils.buildUnreadIndicator(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
