import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/core/services/date_format_service.dart';
import '../../../../shared/shared.dart';
import '../../data/services/notification_service.dart' as local;
import '../../domain/entities/entities.dart';

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

  @override
  void didUpdateWidget(NotificationListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 필터가 변경된 경우 알림 목록 새로고침
    if (oldWidget.filterType != widget.filterType ||
        oldWidget.filterStatus != widget.filterStatus) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = local.NotificationService();
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
        print('通知リスト読み込みエラー: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isUnread) return; // 이미 읽음인 경우 처리하지 않음

    try {
      // UI를 즉시 업데이트 (빨간 점 제거)
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyAsRead();
        }
      });

      final notificationService = local.NotificationService();
      await notificationService.markNotificationAsRead(notification.id);

      // 읽음 처리 콜백 호출
      widget.onNotificationTap?.call();
    } catch (e) {
      if (kDebugMode) {
        print('通知既読処理エラー: $e');
      }
      // 오류 발생 시 원래 상태로 복구
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification; // 원래 상태로 복구
        }
      });
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
    // 삭제할 알림을 임시로 저장 (복구용)
    final deletedNotification = notification;
    final originalIndex = _notifications.indexOf(notification);

    try {
      // UI에서 즉시 제거
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });

      final notificationService = local.NotificationService();
      await notificationService.deleteNotification(notification.id);

      // 삭제 완료 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('通知を削除しました'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // 삭제 콜백 호출
      widget.onNotificationDelete?.call();
    } catch (e) {
      if (kDebugMode) {
        print('通知削除エラー: $e');
      }

      // 오류 발생 시 원래 위치에 알림 복구
      setState(() {
        if (originalIndex >= 0 && originalIndex <= _notifications.length) {
          _notifications.insert(originalIndex, deletedNotification);
        } else {
          _notifications.add(deletedNotification);
        }
      });

      // 오류 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('通知の削除に失敗しました'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount:
            _notifications.length +
            (_notifications.length >= widget.maxItems ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 1),
        itemBuilder: (context, index) {
          // 더보기 버튼 표시
          if (index == _notifications.length) {
            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: InkWell(
                onTap: () {
                  // 더보기 기능 구현 시 추가
                },
                borderRadius: BorderRadius.circular(AppRadius.medium),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
            '通知がありません',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.sm),
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
        padding: const EdgeInsets.only(right: AppSpacing.md),
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  _buildSimpleNotificationIcon(notification),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: AppColors.pointDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.pointGray,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormatService.formatRelativeTime(
                          notification.createdAt,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.pointGray,
                        ),
                      ),
                      if (notification.isUnread) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
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

  Widget _buildSimpleNotificationIcon(NotificationModel notification) {
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(iconData, color: iconColor, size: 18),
    );
  }
}
