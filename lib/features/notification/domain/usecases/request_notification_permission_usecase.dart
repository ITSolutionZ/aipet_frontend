import '../repositories/notification_repository.dart';

class RequestNotificationPermissionUseCase {
  final NotificationRepository _repository;

  const RequestNotificationPermissionUseCase(this._repository);

  /// 알림 권한 요청
  Future<bool> call() async {
    return _repository.requestNotificationPermission();
  }
}