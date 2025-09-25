import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationSettingsUseCase {
  final NotificationRepository _repository;

  const GetNotificationSettingsUseCase(this._repository);

  /// 알림 설정 가져오기
  Future<NotificationSettings> call() async {
    return _repository.getNotificationSettings();
  }
}
