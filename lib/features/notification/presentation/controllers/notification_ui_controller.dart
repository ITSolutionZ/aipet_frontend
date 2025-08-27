import 'package:flutter/material.dart';

import '../../../../app/controllers/base_controller.dart';
import 'notification_controller.dart';

/// 알림 UI 컨트롤러 - UI 로직 처리
class NotificationUIController extends BaseController {
  NotificationUIController(super.ref);

  NotificationController get _notificationController =>
      NotificationController(ref);

  /// 알림 목록 가져오기 (UI 피드백 포함)
  Future<List<dynamic>> getNotificationsWithFeedback(
    BuildContext context,
  ) async {
    try {
      final notifications = await _notificationController.getNotifications();
      return notifications;
    } catch (error) {
      showErrorSnackBar(context, 'アラーム通知の読み込みに失敗しました: $error');
      return [];
    }
  }

  /// 알림 새로고침 (UI 피드백 포함)
  Future<void> refreshNotificationsWithFeedback(BuildContext context) async {
    try {
      await _notificationController.refreshNotifications();
      showSuccessSnackBar(context, 'アラーム通知が更新されました。');
    } catch (error) {
      showErrorSnackBar(context, 'アラーム通知の更新に失敗しました: $error');
    }
  }

  /// 알림 읽음 처리 (UI 피드백 포함)
  Future<void> markAsReadWithFeedback(BuildContext context, String id) async {
    try {
      await _notificationController.markAsRead(id);
      showSuccessSnackBar(context, 'アラーム通知を既読にしました。');
    } catch (error) {
      showErrorSnackBar(context, 'アラーム通知の既読処理に失敗しました: $error');
    }
  }

  /// 알림 삭제 (UI 피드백 포함)
  Future<void> deleteNotificationWithFeedback(
    BuildContext context,
    String id,
  ) async {
    try {
      await _notificationController.deleteNotification(id);
      showSuccessSnackBar(context, 'アラーム通知が削除されました。');
    } catch (error) {
      showErrorSnackBar(context, 'アラーム通知の削除に失敗しました: $error');
    }
  }

  /// 알림 설정 저장 (UI 피드백 포함)
  Future<void> saveNotificationSettingsWithFeedback(
    BuildContext context,
    dynamic settings,
  ) async {
    try {
      await _notificationController.saveNotificationSettings(settings);
      showSuccessSnackBar(context, 'アラーム通知の設定が保存されました。');
    } catch (error) {
      showErrorSnackBar(context, 'アラーム通知の設定の保存に失敗しました: $error');
    }
  }

  /// 테스트 알림 전송 (UI 피드백 포함)
  Future<void> sendTestNotificationWithFeedback(BuildContext context) async {
    try {
      await _notificationController.sendTestNotification();
      showSuccessSnackBar(context, 'テストアラーム通知が送信されました。');
    } catch (error) {
      showErrorSnackBar(context, 'テストアラーム通知の送信に失敗しました: $error');
    }
  }

  /// 알림 권한 요청 (UI 피드백 포함)
  Future<bool> requestNotificationPermissionWithFeedback(
    BuildContext context,
  ) async {
    try {
      final result = await _notificationController
          .requestNotificationPermission();
      if (result) {
        showSuccessSnackBar(context, 'アラーム通知の許可が許可されました。');
      } else {
        showWarningSnackBar(context, 'アラーム通知の許可が拒否されました。');
      }
      return result;
    } catch (error) {
      showErrorSnackBar(context, 'アラーム通知の許可の要求に失敗しました: $error');
      return false;
    }
  }

  /// 성공 메시지 표시
  void showSuccessSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 에러 메시지 표시
  void showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 경고 메시지 표시
  void showWarningSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 알림 삭제 확인 다이얼로그 표시
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('アラーム通知の削除'),
            content: const Text('このアラーム通知を削除しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('削除'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// 알림 권한 요청 다이얼로그 표시
  Future<bool> showPermissionRequestDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('アラーム通知の許可'),
            content: const Text('アラーム通知を受け取るには許可が必要です。許可しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('拒否'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('許可'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
