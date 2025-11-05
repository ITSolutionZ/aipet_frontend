import '../../../../shared/shared.dart';

import '../entities/entities.dart';
import '../repositories/notification_repository.dart';


/// ID로 알림 조회 UseCase
class GetNotificationByIdUseCase {
  final NotificationRepository _repository;

  const GetNotificationByIdUseCase(this._repository);

  /// ID로 알림 가져오기
  Future<Result<NotificationModel?>> call(
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

      final result = await _repository.getNotificationById(
        userId: userId,
        notificationId: notificationId,
      );

      if (result.isSuccess) {
        return Result.success('通知を取得しました', result.dataOrNull);
      } else {
        return Result.failure('通知の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 존재 여부 확인
  Future<Result<bool>> exists(String userId, String notificationId) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (notificationId.trim().isEmpty) {
        return Result.failure('通知IDが無効です');
      }

      final result = await call(userId, notificationId);
      if (result.isSuccess) {
        return Result.success('通知の存在確認が完了しました', result.dataOrNull != null);
      } else {
        return Result.failure('通知の存在確認に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知の存在確認に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 상세 정보 조회
  Future<Result<Map<String, dynamic>>> getNotificationDetails(
    String userId,
    String notificationId,
  ) async {
    try {
      final result = await call(userId, notificationId);
      if (result.isSuccess && result.dataOrNull != null) {
        final notification = result.dataOrNull!;
        final details = {
          'id': notification.id,
          'title': notification.title,
          'body': notification.body,
          'type': notification.type.toString(),
          'isUnread': notification.isUnread,
          'createdAt': notification.createdAt.toIso8601String(),
          'expiresAt': notification.expiresAt?.toIso8601String(),
          'data': notification.data,
        };
        return Result.success('通知詳細を取得しました', details);
      } else {
        return Result.failure('通知が見つかりません');
      }
    } catch (error) {
      return Result.failure('通知詳細の取得に失敗しました: ${error.toString()}');
    }
  }
}
