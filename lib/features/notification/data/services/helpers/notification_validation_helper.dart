import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';

/// 알림 유효성 검사 헬퍼
class NotificationValidationHelper {
  /// 알림 타입이 설정에서 활성화되어 있는지 확인
  static bool isNotificationTypeEnabled(
    NotificationSettings settings,
    NotificationType type,
  ) {
    return settings.isTypeEnabled(type);
  }

  /// 현재 조용한 시간인지 확인
  static bool isQuietTime(NotificationSettings settings) {
    return settings.isQuietTime;
  }

  /// 알림을 보낼 수 있는지 전체 유효성 검사
  static bool canSendNotification(
    NotificationSettings settings,
    NotificationType type,
  ) {
    // 타입 비활성화 체크
    if (!isNotificationTypeEnabled(settings, type)) {
      return false;
    }

    // 조용한 시간 체크
    if (isQuietTime(settings)) {
      return false;
    }

    return true;
  }
}
