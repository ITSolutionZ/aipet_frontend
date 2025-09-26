import 'package:aipet_frontend/features/notification/data/services/notification_service.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';

class TestNotificationUseCase {
  final NotificationService _notificationService;

  const TestNotificationUseCase(this._notificationService);

  /// 테스트 알림 전송
  Future<void> call() async {
    // 프론트엔드 중심 구조에서는 NotificationService에서 직접 테스트 알림 생성
    await _notificationService.createNotification(
      title: '테스트 알림',
      body: '알림 기능이 정상적으로 작동합니다.',
      type: NotificationType.system,
      priority: NotificationPriority.normal,
    );
  }
}
