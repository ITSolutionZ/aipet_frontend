import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationByIdUseCase {
  final NotificationRepository _repository;

  const GetNotificationByIdUseCase(this._repository);

  /// ID로 알림 가져오기
  Future<NotificationModel?> call(String userId, String notificationId) async {
    final result = await _repository.getNotificationById(
      userId: userId,
      notificationId: notificationId,
    );
    if (result.isSuccess) {
      return result.dataOrNull;
    }
    return null; // 에러 발생 시 null 반환
  }
}
