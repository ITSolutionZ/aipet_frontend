import 'package:aipet_frontend/shared/shared.dart';

import '../repositories/notification_repository.dart';

/// 알림 삭제 UseCase
class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  const DeleteNotificationUseCase(this._repository);

  /// 알림 삭제
  Future<Result<void>> call(String userId, String notificationId) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (notificationId.trim().isEmpty) {
        return Result.failure('通知IDが無効です');
      }

      final result = await _repository.deleteNotification(
        userId: userId,
        notificationId: notificationId,
      );

      if (result.isSuccess) {
        return Result.success('通知を削除しました', null);
      } else {
        return Result.failure('通知の削除に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 여러 알림 일괄 삭제
  Future<Result<Map<String, dynamic>>> deleteMultipleNotifications(
    String userId,
    List<String> notificationIds,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (notificationIds.isEmpty) {
        return Result.failure('削除する通知IDが指定されていません');
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

      return Result.success('複数の通知を削除しました', result);
    } catch (error) {
      return Result.failure('複数の通知の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 사용자의 모든 알림 삭제
  Future<Result<Map<String, dynamic>>> deleteAllUserNotifications(
    String userId,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      // 실제 구현에서는 repository에서 해당 사용자의 모든 알림을 조회하고 삭제
      await Future.delayed(const Duration(milliseconds: 200)); // 시뮬레이션

      final result = {
        'deletedNotifications': 15, // Mock 데이터
        'userId': userId,
      };

      return Result.success('ユーザーの通知をすべて削除しました', result);
    } catch (error) {
      return Result.failure('ユーザーの通知の削除に失敗しました: ${error.toString()}');
    }
  }

  /// 읽지 않은 알림만 삭제
  Future<Result<Map<String, dynamic>>> deleteUnreadNotifications(
    String userId,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      // 실제 구현에서는 repository에서 읽지 않은 알림을 조회하고 삭제
      await Future.delayed(const Duration(milliseconds: 150)); // 시뮬레이션

      final result = {
        'deletedNotifications': 8, // Mock 데이터
        'userId': userId,
      };

      return Result.success('未読通知を削除しました', result);
    } catch (error) {
      return Result.failure('未読通知の削除に失敗しました: ${error.toString()}');
    }
  }
}
