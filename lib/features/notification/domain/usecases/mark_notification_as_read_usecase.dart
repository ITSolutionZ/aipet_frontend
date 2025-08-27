import '../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  const MarkNotificationAsReadUseCase(this._repository);

  /// 알림을 읽음으로 표시
  Future<void> call(String id) async {
    await _repository.markAsRead(id);
  }
}
