import 'package:aipet_frontend/app/controllers/base_controller.dart';
import 'package:flutter/material.dart';

import '../../domain/domain.dart';

/// 🎯 통합된 알림 컨트롤러
///
/// 기존 NotificationController와 NotificationUIController를 통합
/// UI 피드백과 비즈니스 로직을 모두 처리
class NotificationBaseController extends BaseController {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final GetNotificationSettingsUseCase _getSettingsUseCase;
  final SaveNotificationSettingsUseCase _saveSettingsUseCase;
  final RequestNotificationPermissionUseCase _requestPermissionUseCase;
  final TestNotificationUseCase _testNotificationUseCase;

  NotificationBaseController(
    super.ref,
    this._getNotificationsUseCase,
    this._markAsReadUseCase,
    this._deleteNotificationUseCase,
    this._getSettingsUseCase,
    this._saveSettingsUseCase,
    this._requestPermissionUseCase,
    this._testNotificationUseCase,
  );

  /// 알림 목록 가져오기 (UI 피드백 포함)
  Future<List<NotificationModel>> getNotificationsWithFeedback(
    BuildContext context,
    String userId,
  ) async {
    try {
      final notifications = await _getNotificationsUseCase.call(userId);
      return notifications.dataOrNull ?? [];
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, '通知の読み込みに失敗しました: $error');
      }
      return [];
    }
  }

  /// 알림 새로고침 (UI 피드백 포함)
  Future<void> refreshNotificationsWithFeedback(
    BuildContext context,
    String userId,
  ) async {
    try {
      await _getNotificationsUseCase.call(userId);
      if (context.mounted) {
        showSuccessSnackBar(context, '通知が更新されました。');
      }
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, '通知の更新に失敗しました: $error');
      }
    }
  }

  /// 알림 읽음 처리 (UI 피드백 포함)
  Future<void> markAsReadWithFeedback(
    BuildContext context,
    String userId,
    String id,
  ) async {
    try {
      await _markAsReadUseCase.call(userId, id);
      if (context.mounted) {
        showSuccessSnackBar(context, '通知を既読にしました。');
      }
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, '通知の既読処理に失敗しました: $error');
      }
    }
  }

  /// 알림 삭제 (UI 피드백 포함)
  Future<void> deleteNotificationWithFeedback(
    BuildContext context,
    String userId,
    String id,
  ) async {
    try {
      await _deleteNotificationUseCase.call(userId, id);
      if (context.mounted) {
        showSuccessSnackBar(context, '通知が削除されました。');
      }
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, '通知の削除に失敗しました: $error');
      }
    }
  }

  /// 알림 설정 저장 (UI 피드백 포함)
  Future<void> saveNotificationSettingsWithFeedback(
    BuildContext context,
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _saveSettingsUseCase.call(userId, settings);
      if (context.mounted) {
        showSuccessSnackBar(context, '通知設定が保存されました。');
      }
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, '通知設定の保存に失敗しました: $error');
      }
    }
  }

  /// 테스트 알림 전송 (UI 피드백 포함)
  Future<void> sendTestNotificationWithFeedback(BuildContext context) async {
    try {
      await _testNotificationUseCase.call();
      if (context.mounted) {
        showSuccessSnackBar(context, 'テスト通知が送信されました。');
      }
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, 'テスト通知の送信に失敗しました: $error');
      }
    }
  }

  /// 알림 권한 요청 (UI 피드백 포함)
  Future<bool> requestNotificationPermissionWithFeedback(
    BuildContext context,
  ) async {
    try {
      final result = await _requestPermissionUseCase.call();
      if (context.mounted) {
        if (result.dataOrNull ?? false) {
          showSuccessSnackBar(context, '通知の許可が許可されました。');
        } else {
          showWarningSnackBar(context, '通知の許可が拒否されました。');
        }
      }
      return result.dataOrNull ?? false;
    } catch (error) {
      if (context.mounted) {
        showErrorSnackBar(context, '通知の許可の要求に失敗しました: $error');
      }
      return false;
    }
  }

  /// 읽지 않은 알림 개수 가져오기
  Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await _getNotificationsUseCase.call(userId);
      return notifications.dataOrNull
              ?.where((n) => n.status == NotificationStatus.unread)
              .length ??
          0;
    } catch (error) {
      handleError(error);
      return 0;
    }
  }

  /// 알림 설정 가져오기
  Future<Map<String, dynamic>> getNotificationSettings(String userId) async {
    try {
      final result = await _getSettingsUseCase.call(userId);
      return result.dataOrNull ?? {};
    } catch (error) {
      handleError(error);
      return {};
    }
  }

  /// 알림 삭제 확인 다이얼로그 표시
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('通知の削除'),
            content: const Text('この通知を削除しますか？'),
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
            title: const Text('通知の許可'),
            content: const Text('通知を受け取るには許可が必要です。許可しますか？'),
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
}
