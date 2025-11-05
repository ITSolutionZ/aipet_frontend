import '../../../../shared/shared.dart';

import '../repositories/notification_repository.dart';


/// 알림 설정 초기화 UseCase
class ResetNotificationSettingsUseCase {
  final NotificationRepository _repository;

  ResetNotificationSettingsUseCase(this._repository);

  /// 알림 설정을 기본값으로 초기화
  Future<Result<void>> call(String userId) async {
    try {
      // 실제 구현에서는 repository에 resetNotificationSettings 메서드가 필요
      // 현재는 mock 데이터로 처리
      await _repository.getNotificationSettings(userId); // repository 사용
      await Future.delayed(const Duration(milliseconds: 100)); // 시뮬레이션
      return Result.success('通知設定をリセットしました', null);
    } catch (error) {
      return Result.failure('通知設定のリセットに失敗しました: ${error.toString()}');
    }
  }
}
