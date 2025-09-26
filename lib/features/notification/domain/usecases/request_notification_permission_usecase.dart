import 'package:aipet_frontend/features/notification/data/services/notification_service.dart';

class RequestNotificationPermissionUseCase {
  final NotificationService _notificationService;

  const RequestNotificationPermissionUseCase(this._notificationService);

  /// 알림 권한 요청
  Future<bool> call() async {
    // 프론트엔드 중심 구조에서는 NotificationService에서 직접 권한 요청
    // 현재는 간단히 true 반환 (실제 구현은 NotificationService에서 처리)
    await _notificationService.initialize();
    return true; // Flutter local notifications는 기본적으로 권한이 있다고 가정
  }
}
