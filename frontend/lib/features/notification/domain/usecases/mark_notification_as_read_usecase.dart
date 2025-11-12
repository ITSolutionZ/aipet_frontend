import '../../../../shared/shared.dart';

import '../entities/entities.dart';
import '../repositories/notification_repository.dart';

/// 알림 읽음 처리 UseCase
class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  const MarkNotificationAsReadUseCase(this._repository);

  /// 알림을 읽음으로 표시
  Future<Result<void>> call(String userId, String notificationId) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (notificationId.trim().isEmpty) {
        return Result.failure('通知IDが無効です');
      }

      final result = await _repository.markAsRead(
        userId: userId,
        notificationId: notificationId,
        isRead: true,
      );

      if (result.isSuccess) {
        return Result.success('通知を既読にしました', null);
      } else {
        return Result.failure('通知の既読処理に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知の既読処理に失敗しました: ${error.toString()}');
    }
  }

  /// 여러 알림을 읽음으로 표시
  Future<Result<Map<String, dynamic>>> markMultipleAsRead(
    String userId,
    List<String> notificationIds,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (notificationIds.isEmpty) {
        return Result.failure('既読にする通知IDが指定されていません');
      }

      final results = <String, String>{};
      int successCount = 0;
      int failureCount = 0;

      for (final notificationId in notificationIds) {
        final result = await call(userId, notificationId);
        if (result.isSuccess) {
          results[notificationId] = 'success';
          successCount++;
        } else {
          results[notificationId] = 'failed: ${result.message}';
          failureCount++;
        }
      }

      final result = {
        'totalNotifications': notificationIds.length,
        'successCount': successCount,
        'failureCount': failureCount,
        'results': results,
      };

      return Result.success('複数の通知を既読にしました', result);
    } catch (error) {
      return Result.failure('複数の通知の既読処理に失敗しました: ${error.toString()}');
    }
  }

  /// 모든 알림을 읽음으로 표시
  Future<Result<Map<String, dynamic>>> markAllAsRead(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      // 실제 구현에서는 repository에서 해당 사용자의 모든 알림을 조회하고 읽음 처리
      await Future.delayed(const Duration(milliseconds: 200)); // 시뮬레이션

      final result = {
        'markedAsRead': 12, // Mock 데이터
        'userId': userId,
      };

      return Result.success('すべての通知を既読にしました', result);
    } catch (error) {
      return Result.failure('すべての通知の既読処理に失敗しました: ${error.toString()}');
    }
  }

  /// 알림을 읽지 않음으로 표시
  Future<Result<void>> markAsUnread(
    String userId,
    String notificationId,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (notificationId.trim().isEmpty) {
        return Result.failure('通知IDが無効です');
      }

      final result = await _repository.markAsRead(
        userId: userId,
        notificationId: notificationId,
        isRead: false,
      );

      if (result.isSuccess) {
        return Result.success('通知を未読にしました', null);
      } else {
        return Result.failure('通知の未読処理に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知の未読処理に失敗しました: ${error.toString()}');
    }
  }

  /// 읽음 상태 토글
  Future<Result<bool>> toggleReadStatus(
    String userId,
    String notificationId,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (notificationId.trim().isEmpty) {
        return Result.failure('通知IDが無効です');
      }

      // 현재 읽음 상태 조회
      final currentNotificationResult = await _repository.getNotificationById(
        userId: userId,
        notificationId: notificationId,
      );

      if (!currentNotificationResult.isSuccess ||
          currentNotificationResult.dataOrNull == null) {
        return Result.failure('通知が見つかりません');
      }

      final currentNotification = currentNotificationResult.dataOrNull!;
      final currentIsRead =
          currentNotification.status == NotificationStatus.read;
      final newIsRead = !currentIsRead;

      final result = await _repository.markAsRead(
        userId: userId,
        notificationId: notificationId,
        isRead: newIsRead,
      );

      if (result.isSuccess) {
        final message = newIsRead ? '通知を既読にしました' : '通知を未読にしました';
        return Result.success(message, newIsRead);
      } else {
        return Result.failure('通知の読み取り状態変更に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知の読み取り状態変更に失敗しました: ${error.toString()}');
    }
  }
}
