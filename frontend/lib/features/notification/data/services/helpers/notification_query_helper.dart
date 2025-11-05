import '../../../domain/domain.dart';

/// 알림 조회/필터링 헬퍼
class NotificationQueryHelper {
  /// 알림 필터링
  static List<NotificationModel> filterNotifications(
    List<NotificationModel> notifications, {
    NotificationStatus? status,
    NotificationType? type,
  }) {
    return notifications.where((notification) {
      if (status != null && notification.status != status) return false;
      if (type != null && notification.type != type) return false;
      if (notification.isExpired) return false;
      return true;
    }).toList();
  }

  /// 알림 정렬 (최신순)
  static List<NotificationModel> sortNotificationsByDate(
    List<NotificationModel> notifications,
  ) {
    final sortedList = List<NotificationModel>.from(notifications);
    sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedList;
  }

  /// 알림 제한
  static List<NotificationModel> limitNotifications(
    List<NotificationModel> notifications,
    int limit,
  ) {
    return notifications.take(limit).toList();
  }

  /// 전체 프로세스: 필터링 + 정렬 + 제한
  static List<NotificationModel> processNotifications(
    List<NotificationModel> notifications, {
    NotificationStatus? status,
    NotificationType? type,
    int limit = 50,
  }) {
    final filtered = filterNotifications(
      notifications,
      status: status,
      type: type,
    );
    final sorted = sortNotificationsByDate(filtered);
    return limitNotifications(sorted, limit);
  }
}
