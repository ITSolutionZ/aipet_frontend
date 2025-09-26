import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository _repository;

  const MarkNotificationAsReadUseCase(this._repository);

  /// 알림을 읽음으로 표시
  Future<void> call(String userId, String notificationId) async {
    final result = await _repository.markAsRead(
      userId: userId,
      notificationId: notificationId,
      isRead: true,
    );
    if (!result.isSuccess) {
      throw Exception('알림 읽음 처리 실패: ${result.errorOrNull}');
    }
  }
}
