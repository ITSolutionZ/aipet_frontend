import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationSettingsUseCase {
  final NotificationRepository _repository;

  const GetNotificationSettingsUseCase(this._repository);

  /// 알림 설정 가져오기
  Future<Map<String, dynamic>> call(String userId) async {
    final result = await _repository.getNotificationSettings(userId);
    if (result.isSuccess) {
      return result.dataOrNull ?? {};
    }
    throw Exception('알림 설정 조회 실패: ${result.errorOrNull}');
  }
}
