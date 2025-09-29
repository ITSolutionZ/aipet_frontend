import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';
import 'package:aipet_frontend/shared/core/domain/result.dart';

/// 알림 설정 초기화 UseCase
class ResetNotificationSettingsUseCase {
  final NotificationRepository _repository;

  ResetNotificationSettingsUseCase(this._repository);

  /// 알림 설정을 기본값으로 초기화
  Future<Result<void>> call(String userId) async {
    try {
      await _repository.resetNotificationSettings(userId);
      return Result.success('通知設定をリセットしました', null);
    } catch (error) {
      return Result.failure('通知設定のリセットに失敗しました: ${error.toString()}');
    }
  }
}
