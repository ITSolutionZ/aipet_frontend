import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';
import 'package:aipet_frontend/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  const GetNotificationsUseCase(this._repository);

  /// 모든 알림 가져오기
  Future<List<NotificationModel>> call(String userId) async {
    final result = await _repository.getAllNotifications(userId: userId);
    if (result.isSuccess) {
      return result.dataOrNull ?? [];
    }
    throw Exception('알림 조회 실패: ${result.errorOrNull}');
  }
}
