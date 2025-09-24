import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';

class TestNotificationUseCase {
  final NotificationRepository _repository;

  const TestNotificationUseCase(this._repository);

  /// 테스트 알림 전송
  Future<void> call() async {
    return _repository.sendTestNotification();
  }
}
