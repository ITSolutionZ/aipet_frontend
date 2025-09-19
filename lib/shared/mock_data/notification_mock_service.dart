/// 알림 Mock 서비스
///
/// 알림 관련 Mock 데이터를 제공합니다.
class NotificationMockService {
  /// Mock 알림 데이터 반환
  static List<Map<String, dynamic>> getMockNotifications() {
    return [
      {
        'id': 'notification-1',
        'title': '給餌時間です',
        'body': 'Maxiの給餌時間が近づいています',
        'type': 'feeding',
        'petId': 'pet-1',
        'scheduledTime': DateTime.now().add(const Duration(minutes: 30)),
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 5)),
      },
      {
        'id': 'notification-2',
        'title': '散歩の時間です',
        'body': 'Maxiと一緒に散歩に行きましょう',
        'type': 'walk',
        'petId': 'pet-1',
        'scheduledTime': DateTime.now().add(const Duration(hours: 1)),
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'notification-3',
        'title': '獣医師の予約',
        'body': '明日の午後2時に獣医師の予約があります',
        'type': 'appointment',
        'petId': 'pet-1',
        'scheduledTime': DateTime.now().add(const Duration(days: 1)),
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];
  }

  /// Mock 알림 생성
  static Map<String, dynamic> createMockNotification({
    required String title,
    required String body,
    required String type,
    String? petId,
    DateTime? scheduledTime,
  }) {
    return {
      'id': 'notification-${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'body': body,
      'type': type,
      'petId': petId,
      'scheduledTime': scheduledTime ?? DateTime.now(),
      'isRead': false,
      'createdAt': DateTime.now(),
    };
  }

  /// Mock 알림 설정 반환
  static Map<String, dynamic> getMockNotificationSettings() {
    return {
      'isEnabled': true,
      'feedingReminders': true,
      'walkReminders': true,
      'appointmentReminders': true,
      'healthAlerts': true,
      'morningTime': '08:00',
      'eveningTime': '18:00',
      'soundEnabled': true,
      'vibrationEnabled': true,
    };
  }
}
