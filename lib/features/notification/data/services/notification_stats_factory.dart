import 'package:aipet_frontend/features/notification/data/services/notification_local_storage_service.dart';
import 'package:aipet_frontend/features/notification/domain/entities/entities.dart';

/// 통계 팩토리 (데이터 레이어에서 로컬 저장소 데이터 생성)
class NotificationStatsFactory {
  /// 통계 데이터 생성
  static Future<List<NotificationStats>> generateMockStats({
    int days = 30,
    int notificationsPerDay = 5,
  }) async {
    try {
      final statsData = await NotificationLocalStorageService.getStats(
        days: days,
      );

      return statsData
          .map(
            (data) => NotificationStats(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Notification',
              type: NotificationType.general,
              date: DateTime.parse(data['date'] as String),
              sentCount: data['total'] as int,
              openedCount: data['read'] as int,
              clickedCount: (data['read'] as int) ~/ 2,
              dismissedCount: (data['total'] as int) - (data['read'] as int),
              failedCount: 0,
              openRate: (data['read'] as int) / (data['total'] as int),
              clickRate: ((data['read'] as int) / 2) / (data['total'] as int),
              dismissRate:
                  ((data['total'] as int) - (data['read'] as int)) /
                  (data['total'] as int),
              failureRate: 0.0,
              metadata: {},
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 사용자 참여도 데이터 생성
  static Future<List<UserEngagement>> generateMockUserEngagement({
    int days = 30,
    int users = 5,
  }) async {
    try {
      final engagementData =
          await NotificationLocalStorageService.getUserEngagement(days: days);

      return engagementData
          .map(
            (data) => UserEngagement(
              userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
              date: DateTime.parse(data['date'] as String),
              totalNotifications: data['notificationsReceived'] as int,
              openedNotifications: data['notificationsRead'] as int,
              clickedNotifications: data['actionsCompleted'] as int,
              dismissedNotifications:
                  (data['notificationsReceived'] as int) -
                  (data['notificationsRead'] as int),
              engagementByType: {
                NotificationType.feeding: 2,
                NotificationType.health: 1,
                NotificationType.general: 1,
              },
              preferredTimeSlots: ['09:00', '12:00', '18:00'],
              overallEngagementRate:
                  (data['notificationsRead'] as int) /
                  (data['notificationsReceived'] as int),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 통계 요약 생성
  static Map<String, dynamic> generateSummary(List<NotificationStats> stats) {
    if (stats.isEmpty) {
      return {
        'totalSent': 0,
        'totalOpened': 0,
        'totalClicked': 0,
        'totalDismissed': 0,
        'totalFailed': 0,
        'averageOpenRate': 0.0,
        'averageClickRate': 0.0,
        'averageDismissRate': 0.0,
        'averageFailureRate': 0.0,
      };
    }

    final totalSent = stats.fold(0, (sum, stat) => sum + stat.sentCount);
    final totalOpened = stats.fold(0, (sum, stat) => sum + stat.openedCount);
    final totalClicked = stats.fold(0, (sum, stat) => sum + stat.clickedCount);
    final totalDismissed = stats.fold(
      0,
      (sum, stat) => sum + stat.dismissedCount,
    );
    final totalFailed = stats.fold(0, (sum, stat) => sum + stat.failedCount);

    final averageOpenRate =
        stats.fold(0.0, (sum, stat) => sum + stat.openRate) / stats.length;
    final averageClickRate =
        stats.fold(0.0, (sum, stat) => sum + stat.clickRate) / stats.length;
    final averageDismissRate =
        stats.fold(0.0, (sum, stat) => sum + stat.dismissRate) / stats.length;
    final averageFailureRate =
        stats.fold(0.0, (sum, stat) => sum + stat.failureRate) / stats.length;

    return {
      'totalSent': totalSent,
      'totalOpened': totalOpened,
      'totalClicked': totalClicked,
      'totalDismissed': totalDismissed,
      'totalFailed': totalFailed,
      'averageOpenRate': averageOpenRate,
      'averageClickRate': averageClickRate,
      'averageDismissRate': averageDismissRate,
      'averageFailureRate': averageFailureRate,
    };
  }
}
