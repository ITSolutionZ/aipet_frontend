import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 알림 시간 설정 UseCase
class SetNotificationTimeUseCase {
  final NotificationRepository _repository;

  SetNotificationTimeUseCase(this._repository);

  /// 알림 시간을 설정
  Future<Result<void>> call({
    required String userId,
    required String notificationType,
    required int hour,
    required int minute,
  }) async {
    try {
      await _repository.setNotificationTime(
        userId: userId,
        notificationType: notificationType,
        hour: hour,
        minute: minute,
      );
      return Result.success('通知時間を設定しました', null);
    } catch (error) {
      return Result.failure('通知時間の設定に失敗しました: ${error.toString()}');
    }
  }
}
