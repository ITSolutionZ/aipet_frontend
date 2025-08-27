import '../../../../app/controllers/base_controller.dart';
import '../../data/providers/notification_providers.dart';
import '../../domain/entities/entities.dart';

/// 알림 컨트롤러 - 비즈니스 로직 처리
class NotificationController extends BaseController {
  NotificationController(super.ref);

  /// 알림 목록 가져오기
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final notifier = ref.read(notificationsNotifierProvider.notifier);
      return await notifier.build();
    } catch (error) {
      handleError(error);
      return [];
    }
  }

  /// 알림 새로고침
  Future<void> refreshNotifications() async {
    try {
      final notifier = ref.read(notificationsNotifierProvider.notifier);
      await notifier.refresh();
    } catch (error) {
      handleError(error);
    }
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String id) async {
    try {
      final notifier = ref.read(notificationsNotifierProvider.notifier);
      await notifier.markAsRead(id);
    } catch (error) {
      handleError(error);
    }
  }

  /// 알림 삭제
  Future<void> deleteNotification(String id) async {
    try {
      final notifier = ref.read(notificationsNotifierProvider.notifier);
      await notifier.deleteNotification(id);
    } catch (error) {
      handleError(error);
    }
  }

  /// 개별 알림 가져오기
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      return await ref.read(notificationByIdProvider(id).future);
    } catch (error) {
      handleError(error);
      return null;
    }
  }

  /// 읽지 않은 알림 개수 가져오기
  Future<int> getUnreadCount() async {
    try {
      return await ref.read(unreadNotificationCountProvider.future);
    } catch (error) {
      handleError(error);
      return 0;
    }
  }

  /// 알림 설정 가져오기
  Future<NotificationSettings?> getNotificationSettings() async {
    try {
      final notifier = ref.read(notificationSettingsNotifierProvider.notifier);
      return await notifier.build();
    } catch (error) {
      handleError(error);
      return null;
    }
  }

  /// 알림 설정 저장
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      final notifier = ref.read(notificationSettingsNotifierProvider.notifier);
      await notifier.saveSettings(settings);
    } catch (error) {
      handleError(error);
    }
  }

  /// 알림 권한 요청
  Future<bool> requestNotificationPermission() async {
    try {
      final notifier = ref.read(notificationSettingsNotifierProvider.notifier);
      return await notifier.requestPermission();
    } catch (error) {
      handleError(error);
      return false;
    }
  }

  /// 테스트 알림 전송
  Future<void> sendTestNotification() async {
    try {
      final notifier = ref.read(notificationSettingsNotifierProvider.notifier);
      await notifier.sendTestNotification();
    } catch (error) {
      handleError(error);
    }
  }
}
