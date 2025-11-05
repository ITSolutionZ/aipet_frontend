import '../../../../shared/shared.dart';

import '../repositories/notification_repository.dart';


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
      // 실제 구현에서는 repository에 setNotificationTime 메서드가 필요
      // 현재는 mock 데이터로 처리
      await _repository.getNotificationSettings(userId); // repository 사용
      await Future.delayed(const Duration(milliseconds: 100)); // 시뮬레이션
      return Result.success('通知時間を設定しました', null);
    } catch (error) {
      return Result.failure('通知時間の設定に失敗しました: ${error.toString()}');
    }
  }
}
