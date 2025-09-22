import '../../../../shared/testing/mock_data/features/notification/notification_mock_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    // 시뮬레이션된 네트워크 지연
    await Future.delayed(const Duration(milliseconds: 300));
    return NotificationMockService.getMockNotifications();
  }

  @override
  Future<NotificationModel?> getNotificationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final notifications = NotificationMockService.getMockNotifications();
    
    try {
      return notifications.firstWhere(
        (notification) => notification.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 유효성 검사
    if (notification.title.isEmpty || notification.body.isEmpty) {
      throw Exception('알림 제목과 메시지는 필수입니다.');
    }

    final newNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title,
      body: notification.body,
      type: notification.type,
      priority: notification.priority,
      status: notification.status,
      createdAt: DateTime.now(),
      data: notification.data,
      actions: notification.actions,
      imageUrl: notification.imageUrl,
      icon: notification.icon,
    );

    return newNotification;
  }

  @override
  Future<NotificationModel> updateNotification(
    NotificationModel notification,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // 유효성 검사
    if (notification.title.isEmpty || notification.body.isEmpty) {
      throw Exception('알림 제목과 메시지는 필수입니다.');
    }

    return notification;
  }

  @override
  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // 목업에서는 삭제 성공으로 처리
    return;
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // 목업에서는 읽음 처리 성공으로 처리
    return;
  }

  @override
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final notifications = NotificationMockService.getMockNotifications();
    
    return notifications
        .where(
          (notification) => notification.status == NotificationStatus.unread,
        )
        .length;
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return NotificationMockService.getMockNotificationSettings();
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // 설정 유효성 검사
    if (settings.enabled &&
        !settings.typeSettings[NotificationType.feeding]!) {
      throw Exception('급여 알림 설정이 필요합니다.');
    }
    // 목업에서는 저장 성공으로 처리
    return;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // 권한 요청 시뮬레이션 (80% 확률로 성공)
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    return random < 8; // 80% 확률로 성공
  }

  @override
  Future<void> sendTestNotification() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // 목업에서는 테스트 알림 전송 성공으로 처리
    return;
  }
}