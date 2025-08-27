import '../repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  const DeleteNotificationUseCase(this._repository);

  /// 알림 삭제
  Future<void> call(String id) async {
    await _repository.deleteNotification(id);
  }
}
