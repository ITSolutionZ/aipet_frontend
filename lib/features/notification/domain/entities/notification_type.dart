/// 알림 타입
enum NotificationType {
  /// 일반 알림
  general,

  /// 예약 알림
  reservation,

  /// 산책 알림
  walk,

  /// 급여 알림
  feeding,

  /// 건강 알림
  health,

  /// 약물 알림
  medication,

  /// 시스템 알림
  system,

  /// 음식 알림 (기존 호환성)
  food,

  /// 약속 알림 (기존 호환성)
  appointment,

  /// 리마인더 알림 (기존 호환성)
  reminder,

  /// 의료 알림 (기존 호환성)
  medical,

  /// 미용 알림 (기존 호환성)
  grooming,

  /// 긴급 알림 (기존 호환성)
  emergency,
}

/// NotificationType 확장
/// NotificationType Business Logic Extension (Domain Layer - Language Independent)
extension NotificationTypeExtension on NotificationType {
  /// 알림 타입별 키 (다국어 지원용)
  String get key {
    switch (this) {
      case NotificationType.general:
        return 'notification.type.general';
      case NotificationType.reservation:
        return 'notification.type.reservation';
      case NotificationType.walk:
        return 'notification.type.walk';
      case NotificationType.feeding:
        return 'notification.type.feeding';
      case NotificationType.health:
        return 'notification.type.health';
      case NotificationType.medication:
        return 'notification.type.medication';
      case NotificationType.system:
        return 'notification.type.system';
      case NotificationType.food:
        return 'notification.type.food';
      case NotificationType.appointment:
        return 'notification.type.appointment';
      case NotificationType.reminder:
        return 'notification.type.reminder';
      case NotificationType.medical:
        return 'notification.type.medical';
      case NotificationType.grooming:
        return 'notification.type.grooming';
      case NotificationType.emergency:
        return 'notification.type.emergency';
    }
  }

  /// 알림 타입별 enum 이름 (기존 호환성 유지)
  String get name => toString().split('.').last;
}
