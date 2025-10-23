import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../components/cards/notification_detail_header_component.dart';
import '../components/cards/notification_detail_metadata_component.dart';
import '../components/forms/notification_detail_actions_component.dart';
import '../controllers/notification_detail_controller.dart';
import '../controllers/notification_ui_controller.dart';

/// 알림 상세 화면 (리팩토링됨)
class NotificationDetailScreen extends ConsumerStatefulWidget {
  final String notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  NotificationModel? _notification;
  bool _isLoading = true;
  late final NotificationDetailController _controller;

  @override
  void initState() {
    super.initState();
    final uiController = NotificationUIController(ref);
    _controller = NotificationDetailController(
      uiController,
      ref.read(getNotificationByIdUseCaseProvider),
      ref.read(markNotificationAsReadUseCaseProvider),
      ref.read(deleteNotificationUseCaseProvider),
    );
    _loadNotification();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNotification() async {
    setState(() => _isLoading = true);

    try {
      final notification = await _controller.loadNotification(
        'default_user_id',
        widget.notificationId,
      );

      if (!mounted) return;

      setState(() {
        _notification = notification;
        _isLoading = false;
      });

      // 읽음 처리
      if (notification != null &&
          notification.status == NotificationStatus.unread) {
        await _markAsRead(notification);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (mounted) {
        SnackBarService.showError(context, '通知を読み込む際にエラーが発生しました: $error');
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    await _controller.markAsRead(context, 'default_user_id', notification);

    // 알림 상태를 읽음으로 업데이트
    setState(() {
      _notification = notification.copyAsRead();
    });
  }

  void _handleAction() {
    final notification = _notification;
    if (notification != null) {
      _controller.handleAction(context, notification);
    }
  }

  void _handleDelete() {
    final notification = _notification;
    if (notification != null) {
      _controller.deleteNotification(
        context,
        'default_user_id',
        notification.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: SoftGradientBackAppBar(title: '通知詳細'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final notification = _notification;
    if (notification == null) {
      return const Scaffold(
        backgroundColor: AppColors.pointOffWhite,
        appBar: SoftGradientBackAppBar(title: '通知詳細'),
        body: Center(child: Text('通知を見つけることができませんでした。')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: '通知詳細'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 카드
            NotificationDetailHeaderComponent(
              notification: notification,
              formatDateTime: _controller.formatDateTime,
            ),

            // 메타데이터 정보 (있는 경우)
            NotificationDetailMetadataComponent(
              notification: notification,
              formatCurrency: _controller.formatCurrency,
            ),

            const SizedBox(height: AppSpacing.lg),

            // 액션 버튼들
            NotificationDetailActionsComponent(
              notification: notification,
              onActionPressed: _handleAction,
              onDeletePressed: _handleDelete,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
