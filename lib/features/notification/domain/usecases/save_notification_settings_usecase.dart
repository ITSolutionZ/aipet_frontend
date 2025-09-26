import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';

class SaveNotificationSettingsUseCase {
  final NotificationRepository _repository;

  const SaveNotificationSettingsUseCase(this._repository);

  /// 알림 설정 저장
  Future<void> call(String userId, Map<String, dynamic> settings) async {
    final result = await _repository.updateNotificationSettings(
      userId: userId,
      settings: settings,
    );
    if (!result.isSuccess) {
      throw Exception('알림 설정 저장 실패: ${result.errorOrNull}');
    }
  }
}
