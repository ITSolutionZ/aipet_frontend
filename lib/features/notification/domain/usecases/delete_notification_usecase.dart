import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationRepository _repository;

  const DeleteNotificationUseCase(this._repository);

  /// 알림 삭제
  Future<void> call(String userId, String notificationId) async {
    final result = await _repository.deleteNotification(
      userId: userId,
      notificationId: notificationId,
    );
    if (!result.isSuccess) {
      throw Exception('알림 삭제 실패: ${result.errorOrNull}');
    }
  }
}
