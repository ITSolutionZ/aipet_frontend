import '../../../../shared/shared.dart';

import '../entities/entities.dart';
import '../repositories/notification_repository.dart';

/// 알림 목록 조회 UseCase
class GetNotificationsUseCase {
  final NotificationRepository _repository;

  const GetNotificationsUseCase(this._repository);

  /// 모든 알림 가져오기
  Future<Result<List<NotificationModel>>> call(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      final result = await _repository.getAllNotifications(userId: userId);
      if (result.isSuccess) {
        return Result.success('通知一覧を取得しました', result.dataOrNull);
      } else {
        return Result.failure('通知一覧の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知一覧の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 읽지 않은 알림만 가져오기
  Future<Result<List<NotificationModel>>> getUnreadNotifications(
    String userId,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      final result = await call(userId);
      if (result.isSuccess) {
        final allNotifications = result.dataOrNull!;
        final unreadNotifications = allNotifications
            .where((notification) => notification.isUnread)
            .toList();
        return Result.success('未読通知を取得しました', unreadNotifications);
      } else {
        return Result.failure('未読通知の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('未読通知の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 특정 타입의 알림 가져오기
  Future<Result<List<NotificationModel>>> getNotificationsByType(
    String userId,
    NotificationType type,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      final result = await call(userId);
      if (result.isSuccess) {
        final allNotifications = result.dataOrNull!;
        final filteredNotifications = allNotifications
            .where((notification) => notification.type == type)
            .toList();
        return Result.success(
          '${type.toString()}通知を取得しました',
          filteredNotifications,
        );
      } else {
        return Result.failure('${type.toString()}通知の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure(
        '${type.toString()}通知の取得に失敗しました: ${error.toString()}',
      );
    }
  }

  /// 최근 알림 가져오기 (지정된 개수만큼)
  Future<Result<List<NotificationModel>>> getRecentNotifications(
    String userId,
    int limit,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (limit <= 0) {
        return Result.failure('制限数は0より大きい値である必要があります');
      }

      final result = await call(userId);
      if (result.isSuccess) {
        final allNotifications = result.dataOrNull!;
        // 생성일 기준으로 정렬하고 최근 것만 가져오기
        allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final recentNotifications = allNotifications.take(limit).toList();
        return Result.success('最近の通知を取得しました', recentNotifications);
      } else {
        return Result.failure('最近の通知の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('最近の通知の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 통계 조회
  Future<Result<Map<String, int>>> getNotificationStatistics(
    String userId,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      final result = await call(userId);
      if (result.isSuccess) {
        final allNotifications = result.dataOrNull!;

        final statistics = {
          'total': allNotifications.length,
          'unread': allNotifications.where((n) => n.isUnread).length,
          'read': allNotifications.where((n) => !n.isUnread).length,
          'health': allNotifications
              .where((n) => n.type == NotificationType.health)
              .length,
          'walk': allNotifications
              .where((n) => n.type == NotificationType.walk)
              .length,
          'feeding': allNotifications
              .where((n) => n.type == NotificationType.feeding)
              .length,
          'reminder': allNotifications
              .where((n) => n.type == NotificationType.reminder)
              .length,
          'system': allNotifications
              .where((n) => n.type == NotificationType.system)
              .length,
        };

        return Result.success('通知統計を取得しました', statistics);
      } else {
        return Result.failure('通知統計の取得に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知統計の取得に失敗しました: ${error.toString()}');
    }
  }

  /// 알림 검색
  Future<Result<List<NotificationModel>>> searchNotifications(
    String userId,
    String query,
  ) async {
    try {
      if (userId.trim().isEmpty) {
        return Result.failure('ユーザーIDが無効です');
      }

      if (query.trim().isEmpty) {
        return Result.failure('検索クエリが空です');
      }

      final result = await call(userId);
      if (result.isSuccess) {
        final allNotifications = result.dataOrNull!;
        final searchQuery = query.toLowerCase();

        final filteredNotifications = allNotifications
            .where(
              (notification) =>
                  notification.title.toLowerCase().contains(searchQuery) ||
                  notification.body.toLowerCase().contains(searchQuery),
            )
            .toList();

        return Result.success('通知を検索しました', filteredNotifications);
      } else {
        return Result.failure('通知の検索に失敗しました');
      }
    } catch (error) {
      return Result.failure('通知の検索に失敗しました: ${error.toString()}');
    }
  }
}
