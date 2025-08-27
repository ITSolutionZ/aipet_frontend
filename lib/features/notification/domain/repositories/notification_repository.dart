import '../entities/entities.dart';

abstract class NotificationRepository {
  /// 모든 알림 가져오기
  Future<List<NotificationModel>> getAllNotifications();

  /// ID로 알림 가져오기
  Future<NotificationModel?> getNotificationById(String id);

  /// 알림 생성
  Future<NotificationModel> createNotification(NotificationModel notification);

  /// 알림 업데이트
  Future<NotificationModel> updateNotification(NotificationModel notification);

  /// 알림 삭제
  Future<void> deleteNotification(String id);

  /// 알림을 읽음으로 표시
  Future<void> markAsRead(String id);

  /// 읽지 않은 알림 개수 가져오기
  Future<int> getUnreadCount();

  /// 알림 설정 가져오기
  Future<NotificationSettings> getNotificationSettings();

  /// 알림 설정 저장
  Future<void> saveNotificationSettings(NotificationSettings settings);

  /// 알림 권한 요청
  Future<bool> requestNotificationPermission();

  /// 테스트 알림 보내기
  Future<void> sendTestNotification();
}
