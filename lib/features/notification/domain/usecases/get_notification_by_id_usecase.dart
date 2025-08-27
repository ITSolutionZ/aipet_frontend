import '../entities/entities.dart';
import '../repositories/notification_repository.dart';

class GetNotificationByIdUseCase {
  final NotificationRepository _repository;

  const GetNotificationByIdUseCase(this._repository);

  /// ID로 알림 가져오기
  Future<NotificationModel?> call(String id) async {
    return _repository.getNotificationById(id);
  }
}
