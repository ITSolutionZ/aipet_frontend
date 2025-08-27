import '../../../../shared/mock_data/mock_data_service.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    // 시뮬레이션된 네트워크 지연
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      return MockDataService.getMockNotifications();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<NotificationModel?> getNotificationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      final notifications = MockDataService.getMockNotifications();
      try {
        return notifications.firstWhere(
          (notification) => notification.id == id,
        );
      } catch (e) {
        return null;
      }
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<NotificationModel> createNotification(
    NotificationModel notification,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
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

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<NotificationModel> updateNotification(
    NotificationModel notification,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      // 유효성 검사
      if (notification.title.isEmpty || notification.body.isEmpty) {
        throw Exception('알림 제목과 메시지는 필수입니다.');
      }

      return notification;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      // 목업에서는 삭제 성공으로 처리
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (MockDataService.isEnabled) {
      // 목업에서는 읽음 처리 성공으로 처리
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (MockDataService.isEnabled) {
      final notifications = MockDataService.getMockNotifications();
      return notifications
          .where(
            (notification) => notification.status == NotificationStatus.unread,
          )
          .length;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      return MockDataService.getMockNotificationSettings();
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (MockDataService.isEnabled) {
      // 설정 유효성 검사
      if (settings.enabled &&
          !settings.typeSettings[NotificationType.feeding]!) {
        throw Exception('급여 알림 설정이 필요합니다.');
      }
      // 목업에서는 저장 성공으로 처리
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<bool> requestNotificationPermission() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (MockDataService.isEnabled) {
      // 권한 요청 시뮬레이션 (80% 확률로 성공)
      final random = DateTime.now().millisecondsSinceEpoch % 10;
      return random < 8; // 80% 확률로 성공
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }

  @override
  Future<void> sendTestNotification() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (MockDataService.isEnabled) {
      // 목업에서는 테스트 알림 전송 성공으로 처리
      return;
    }

    throw UnimplementedError('실제 API 호출이 구현되지 않았습니다.');
  }
}
