import '../../../../../features/notification/notification.dart';
import '../../core/base_mock_service.dart';

/// Notification Feature 전용 Mock 데이터 서비스
class NotificationMockService extends BaseMockService {
  // ==================== 알림 데이터 ====================

  /// Mock 알림 목록
  static List<NotificationModel> getMockNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: '건강검진 예약 완료',
        body: 'MAX의 건강검진이 내일 오후 2시에 예약되었습니다.',
        type: NotificationType.appointment,
        status: NotificationStatus.unread,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        data: {
          'petId': '1',
          'appointmentType': '건강검진',
          'facilityName': '우리동물병원',
        },
      ),
      NotificationModel(
        id: '2',
        title: '식사 시간 알림',
        body: 'LUNA의 저녁 식사 시간입니다.',
        type: NotificationType.feeding,
        status: NotificationStatus.read,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        readAt: DateTime.now().subtract(const Duration(minutes: 30)),
        data: {'petId': '2', 'mealType': '저녁식사', 'scheduledTime': '18:00'},
      ),
      NotificationModel(
        id: '3',
        title: '예방접종 일정 알림',
        body: 'MOMO의 연간 예방접종 일정이 일주일 후입니다.',
        type: NotificationType.health,
        status: NotificationStatus.unread,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        data: {'petId': '3', 'vaccineType': '종합백신', 'facilityName': '우리동물병원'},
      ),
      NotificationModel(
        id: '4',
        title: '트릭 훈련 완료',
        body: 'MAX가 "오스와리" 트릭을 완전히 마스터했습니다!',
        type: NotificationType.general,
        status: NotificationStatus.read,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        readAt: DateTime.now().subtract(const Duration(hours: 4)),
        data: {'petId': '1', 'trickName': '오스와리', 'progress': 100},
      ),
    ];
  }

  /// ID로 알림 조회
  static NotificationModel? getMockNotificationById(String id) {
    final notifications = getMockNotifications();
    try {
      return notifications.firstWhere((notification) => notification.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 읽지 않은 알림 개수
  static int getMockUnreadNotificationCount() {
    final notifications = getMockNotifications();
    return notifications.where((n) => n.isUnread).length;
  }

  /// 펫별 알림 조회
  static List<NotificationModel> getMockNotificationsByPet(String petId) {
    final notifications = getMockNotifications();
    return notifications.where((n) => n.data?['petId'] == petId).toList();
  }

  /// 타입별 알림 조회
  static List<NotificationModel> getMockNotificationsByType(String type) {
    final notifications = getMockNotifications();
    return notifications.where((n) => n.type.name == type).toList();
  }

  // ==================== 알림 설정 ====================

  /// Mock 알림 설정
  static NotificationSettings getMockNotificationSettings() {
    return const NotificationSettings(
      soundEnabled: true,
      vibrationEnabled: true,
    );
  }

  /// 알림 설정 조회 (단일 메소드)
  static NotificationSettings getNotificationSettings() {
    return getMockNotificationSettings();
  }

  /// 알림 설정 업데이트
  static NotificationSettings updateNotificationSettings({
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      soundEnabled: soundEnabled ?? true,
      vibrationEnabled: vibrationEnabled ?? true,
    );
  }

  // ==================== 통계 데이터 ====================

  /// 알림 통계 데이터
  static List<Map<String, dynamic>> getMockNotificationStats({
    int days = 7,
    String? petId,
  }) {
    final stats = <Map<String, dynamic>>[];

    for (int i = days; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayStats = {
        'date': date,
        'total': 3 + (i % 2), // 일별 알림 개수 변화
        'read': 2 + (i % 3),
        'types': {
          'feeding': 1,
          'health': (i % 2 == 0) ? 1 : 0,
          'appointment': (i % 3 == 0) ? 1 : 0,
          'activity': 1,
        },
      };

      if (petId != null) {
        // 특정 펫의 통계로 필터링
        dayStats['total'] = (dayStats['total'] as int) ~/ 2;
        dayStats['read'] = (dayStats['read'] as int) ~/ 2;
      }

      stats.add(dayStats);
    }

    return stats;
  }

  /// 사용자 참여도 데이터
  static List<Map<String, dynamic>> getMockUserEngagement({
    int days = 30,
    String? petId,
  }) {
    final engagement = <Map<String, dynamic>>[];

    for (int i = days; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dayEngagement = {
        'date': date,
        'notificationsReceived': 2 + (i % 4),
        'notificationsRead': 1 + (i % 3),
        'actionsCompleted': (i % 2 == 0) ? 1 : 2,
        'responseTime': Duration(minutes: 15 + (i % 30)), // 평균 응답 시간
      };

      if (petId != null) {
        // 특정 펫의 참여도로 필터링
        dayEngagement['notificationsReceived'] =
            (dayEngagement['notificationsReceived'] as int) ~/ 2;
        dayEngagement['notificationsRead'] =
            (dayEngagement['notificationsRead'] as int) ~/ 2;
        dayEngagement['actionsCompleted'] =
            (dayEngagement['actionsCompleted'] as int) ~/ 2;
      }

      engagement.add(dayEngagement);
    }

    return engagement;
  }
}
