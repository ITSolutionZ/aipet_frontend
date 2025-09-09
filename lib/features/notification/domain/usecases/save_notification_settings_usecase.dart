import '../entities/entities.dart';
import '../repositories/notification_repository.dart';

class SaveNotificationSettingsUseCase {
  final NotificationRepository _repository;

  const SaveNotificationSettingsUseCase(this._repository);

  /// 알림 설정 저장
  Future<void> call(NotificationSettings settings) async {
    return _repository.saveNotificationSettings(settings);
  }
}