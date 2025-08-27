import '../entities/entities.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  const GetNotificationsUseCase(this._repository);

  /// 모든 알림 가져오기
  Future<List<NotificationModel>> call() async {
    return _repository.getAllNotifications();
  }
}
