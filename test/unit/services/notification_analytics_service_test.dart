import 'package:aipet_frontend/features/notification/domain/entities/notification_model.dart';
import 'package:aipet_frontend/features/notification/domain/entities/notification_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationStats Tests', () {
    test('should create notification stats', () {
      // Arrange
      const id = 'test_stats_id';
      const title = '테스트 통계';
      const type = NotificationType.general;
      final date = DateTime.now();
      const sentCount = 100;
      const openedCount = 60;
      const clickedCount = 20;
      const dismissedCount = 15;
      const failedCount = 5;

      // Act
      final stats = NotificationStats(
        id: id,
        title: title,
        type: type,
        date: date,
        sentCount: sentCount,
        openedCount: openedCount,
        clickedCount: clickedCount,
        dismissedCount: dismissedCount,
        failedCount: failedCount,
        openRate: 0.6,
        clickRate: 0.2,
        dismissRate: 0.15,
        failureRate: 0.05,
      );

      // Assert
      expect(stats.id, equals(id));
      expect(stats.title, equals(title));
      expect(stats.type, equals(type));
      expect(stats.date, equals(date));
      expect(stats.sentCount, equals(sentCount));
      expect(stats.openedCount, equals(openedCount));
      expect(stats.clickedCount, equals(clickedCount));
      expect(stats.dismissedCount, equals(dismissedCount));
      expect(stats.failedCount, equals(failedCount));
      expect(stats.openRate, equals(0.6));
      expect(stats.clickRate, equals(0.2));
      expect(stats.dismissRate, equals(0.15));
      expect(stats.failureRate, equals(0.05));
    });

    test('should calculate total sent correctly', () {
      // Arrange
      final stats = NotificationStats(
        id: 'test',
        title: '테스트',
        type: NotificationType.general,
        date: DateTime.now(),
        sentCount: 100,
        openedCount: 60,
        clickedCount: 20,
        dismissedCount: 15,
        failedCount: 5,
        openRate: 0.6,
        clickRate: 0.2,
        dismissRate: 0.15,
        failureRate: 0.05,
      );

      // Act & Assert
      expect(stats.totalSent, equals(105)); // 100 + 5
    });

    test('should calculate engagement rate correctly', () {
      // Arrange
      final stats = NotificationStats(
        id: 'test',
        title: '테스트',
        type: NotificationType.general,
        date: DateTime.now(),
        sentCount: 100,
        openedCount: 60,
        clickedCount: 20,
        dismissedCount: 15,
        failedCount: 5,
        openRate: 0.6,
        clickRate: 0.2,
        dismissRate: 0.15,
        failureRate: 0.05,
      );

      // Act & Assert
      expect(stats.engagementRate, equals(0.8)); // (60 + 20) / 100
    });

    test('should calculate success rate correctly', () {
      // Arrange
      final stats = NotificationStats(
        id: 'test',
        title: '테스트',
        type: NotificationType.general,
        date: DateTime.now(),
        sentCount: 100,
        openedCount: 60,
        clickedCount: 20,
        dismissedCount: 15,
        failedCount: 5,
        openRate: 0.6,
        clickRate: 0.2,
        dismissRate: 0.15,
        failureRate: 0.05,
      );

      // Act & Assert
      expect(stats.successRate, equals(100 / 105)); // 100 / (100 + 5)
    });

    test('should handle zero sent count', () {
      // Arrange
      final stats = NotificationStats(
        id: 'test',
        title: '테스트',
        type: NotificationType.general,
        date: DateTime.now(),
        sentCount: 0,
        openedCount: 0,
        clickedCount: 0,
        dismissedCount: 0,
        failedCount: 0,
        openRate: 0.0,
        clickRate: 0.0,
        dismissRate: 0.0,
        failureRate: 0.0,
      );

      // Act & Assert
      expect(stats.engagementRate, equals(0.0));
      expect(stats.successRate, equals(0.0));
      expect(stats.totalSent, equals(0));
    });

    test('should convert to and from JSON', () {
      // Arrange
      final originalStats = NotificationStats(
        id: 'test_id',
        title: '테스트 통계',
        type: NotificationType.general,
        date: DateTime(2023, 1, 1, 12, 0, 0),
        sentCount: 100,
        openedCount: 60,
        clickedCount: 20,
        dismissedCount: 15,
        failedCount: 5,
        openRate: 0.6,
        clickRate: 0.2,
        dismissRate: 0.15,
        failureRate: 0.05,
        metadata: {'hour': 12, 'dayOfWeek': 1},
      );

      // Act
      final json = originalStats.toJson();
      final fromJson = NotificationStats.fromJson(json);

      // Assert
      expect(fromJson.id, equals(originalStats.id));
      expect(fromJson.title, equals(originalStats.title));
      expect(fromJson.type, equals(originalStats.type));
      expect(fromJson.date, equals(originalStats.date));
      expect(fromJson.sentCount, equals(originalStats.sentCount));
      expect(fromJson.openedCount, equals(originalStats.openedCount));
      expect(fromJson.clickedCount, equals(originalStats.clickedCount));
      expect(fromJson.dismissedCount, equals(originalStats.dismissedCount));
      expect(fromJson.failedCount, equals(originalStats.failedCount));
      expect(fromJson.openRate, equals(originalStats.openRate));
      expect(fromJson.clickRate, equals(originalStats.clickRate));
      expect(fromJson.dismissRate, equals(originalStats.dismissRate));
      expect(fromJson.failureRate, equals(originalStats.failureRate));
      expect(fromJson.metadata, equals(originalStats.metadata));
    });
  });

  group('NotificationAnalytics Tests', () {
    test('should create notification analytics', () {
      // Arrange
      const id = 'test_analytics_id';
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();
      final stats = <NotificationStats>[];
      final statsByType = <NotificationType, List<NotificationStats>>{};
      final summary = <String, double>{};

      // Act
      final analytics = NotificationAnalytics(
        id: id,
        startDate: startDate,
        endDate: endDate,
        stats: stats,
        statsByType: statsByType,
        summary: summary,
      );

      // Assert
      expect(analytics.id, equals(id));
      expect(analytics.startDate, equals(startDate));
      expect(analytics.endDate, equals(endDate));
      expect(analytics.stats, equals(stats));
      expect(analytics.statsByType, equals(statsByType));
      expect(analytics.summary, equals(summary));
    });

    test('should calculate total metrics correctly', () {
      // Arrange
      final stats = [
        NotificationStats(
          id: '1',
          title: '테스트 1',
          type: NotificationType.general,
          date: DateTime.now(),
          sentCount: 100,
          openedCount: 60,
          clickedCount: 20,
          dismissedCount: 15,
          failedCount: 5,
          openRate: 0.6,
          clickRate: 0.2,
          dismissRate: 0.15,
          failureRate: 0.05,
        ),
        NotificationStats(
          id: '2',
          title: '테스트 2',
          type: NotificationType.feeding,
          date: DateTime.now(),
          sentCount: 50,
          openedCount: 30,
          clickedCount: 10,
          dismissedCount: 8,
          failedCount: 2,
          openRate: 0.6,
          clickRate: 0.2,
          dismissRate: 0.16,
          failureRate: 0.04,
        ),
      ];

      final analytics = NotificationAnalytics(
        id: 'test',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        stats: stats,
        statsByType: {},
        summary: {},
      );

      // Act & Assert
      expect(analytics.totalSent, equals(157)); // (100+5) + (50+2)
      expect(analytics.totalOpened, equals(90)); // 60 + 30
      expect(analytics.totalClicked, equals(30)); // 20 + 10
    });

    test('should calculate average rates correctly', () {
      // Arrange
      final stats = [
        NotificationStats(
          id: '1',
          title: '테스트 1',
          type: NotificationType.general,
          date: DateTime.now(),
          sentCount: 100,
          openedCount: 60,
          clickedCount: 20,
          dismissedCount: 15,
          failedCount: 5,
          openRate: 0.6,
          clickRate: 0.2,
          dismissRate: 0.15,
          failureRate: 0.05,
        ),
        NotificationStats(
          id: '2',
          title: '테스트 2',
          type: NotificationType.feeding,
          date: DateTime.now(),
          sentCount: 50,
          openedCount: 30,
          clickedCount: 10,
          dismissedCount: 8,
          failedCount: 2,
          openRate: 0.6,
          clickRate: 0.2,
          dismissRate: 0.16,
          failureRate: 0.04,
        ),
      ];

      final analytics = NotificationAnalytics(
        id: 'test',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        stats: stats,
        statsByType: {},
        summary: {},
      );

      // Act & Assert
      expect(analytics.averageOpenRate, equals(0.6)); // (0.6 + 0.6) / 2
      expect(analytics.averageClickRate, equals(0.2)); // (0.2 + 0.2) / 2
      expect(analytics.averageEngagementRate, equals(0.8)); // (0.8 + 0.8) / 2
    });

    test('should find best performing type', () {
      // Arrange
      final statsByType = <NotificationType, List<NotificationStats>>{
        NotificationType.general: [
          NotificationStats(
            id: '1',
            title: '일반 알림',
            type: NotificationType.general,
            date: DateTime.now(),
            sentCount: 100,
            openedCount: 60,
            clickedCount: 20,
            dismissedCount: 15,
            failedCount: 5,
            openRate: 0.6,
            clickRate: 0.2,
            dismissRate: 0.15,
            failureRate: 0.05,
          ),
        ],
        NotificationType.feeding: [
          NotificationStats(
            id: '2',
            title: '급여 알림',
            type: NotificationType.feeding,
            date: DateTime.now(),
            sentCount: 50,
            openedCount: 40,
            clickedCount: 15,
            dismissedCount: 5,
            failedCount: 2,
            openRate: 0.8,
            clickRate: 0.3,
            dismissRate: 0.1,
            failureRate: 0.04,
          ),
        ],
      };

      final analytics = NotificationAnalytics(
        id: 'test',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        stats: [],
        statsByType: statsByType,
        summary: {},
      );

      // Act & Assert
      expect(analytics.bestPerformingType, equals(NotificationType.feeding));
    });

    test('should convert to and from JSON', () {
      // Arrange
      final stats = [
        NotificationStats(
          id: '1',
          title: '테스트',
          type: NotificationType.general,
          date: DateTime.now(),
          sentCount: 100,
          openedCount: 60,
          clickedCount: 20,
          dismissedCount: 15,
          failedCount: 5,
          openRate: 0.6,
          clickRate: 0.2,
          dismissRate: 0.15,
          failureRate: 0.05,
        ),
      ];

      final originalAnalytics = NotificationAnalytics(
        id: 'test_id',
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 1, 31),
        stats: stats,
        statsByType: {NotificationType.general: stats},
        summary: {'totalSent': 105.0, 'totalOpened': 60.0},
      );

      // Act
      final json = originalAnalytics.toJson();
      final fromJson = NotificationAnalytics.fromJson(json);

      // Assert
      expect(fromJson.id, equals(originalAnalytics.id));
      expect(fromJson.startDate, equals(originalAnalytics.startDate));
      expect(fromJson.endDate, equals(originalAnalytics.endDate));
      expect(fromJson.stats.length, equals(originalAnalytics.stats.length));
      expect(
        fromJson.statsByType.length,
        equals(originalAnalytics.statsByType.length),
      );
      expect(fromJson.summary, equals(originalAnalytics.summary));
    });
  });

  group('UserEngagement Tests', () {
    test('should create user engagement', () {
      // Arrange
      const userId = 'test_user';
      final date = DateTime.now();
      const totalNotifications = 50;
      const openedNotifications = 30;
      const clickedNotifications = 10;
      const dismissedNotifications = 8;
      final engagementByType = <NotificationType, int>{
        NotificationType.general: 15,
        NotificationType.feeding: 15,
      };
      final preferredTimeSlots = ['09:00', '12:00', '18:00'];
      const overallEngagementRate = 0.6;

      // Act
      final engagement = UserEngagement(
        userId: userId,
        date: date,
        totalNotifications: totalNotifications,
        openedNotifications: openedNotifications,
        clickedNotifications: clickedNotifications,
        dismissedNotifications: dismissedNotifications,
        engagementByType: engagementByType,
        preferredTimeSlots: preferredTimeSlots,
        overallEngagementRate: overallEngagementRate,
      );

      // Assert
      expect(engagement.userId, equals(userId));
      expect(engagement.date, equals(date));
      expect(engagement.totalNotifications, equals(totalNotifications));
      expect(engagement.openedNotifications, equals(openedNotifications));
      expect(engagement.clickedNotifications, equals(clickedNotifications));
      expect(engagement.dismissedNotifications, equals(dismissedNotifications));
      expect(engagement.engagementByType, equals(engagementByType));
      expect(engagement.preferredTimeSlots, equals(preferredTimeSlots));
      expect(engagement.overallEngagementRate, equals(overallEngagementRate));
    });

    test('should calculate rates correctly', () {
      // Arrange
      final engagement = UserEngagement(
        userId: 'test',
        date: DateTime.now(),
        totalNotifications: 50,
        openedNotifications: 30,
        clickedNotifications: 10,
        dismissedNotifications: 8,
        engagementByType: {},
        preferredTimeSlots: [],
        overallEngagementRate: 0.6,
      );

      // Act & Assert
      expect(engagement.openRate, equals(0.6)); // 30 / 50
      expect(engagement.clickRate, equals(0.2)); // 10 / 50
      expect(engagement.dismissRate, equals(0.16)); // 8 / 50
    });

    test('should find preferred type', () {
      // Arrange
      final engagementByType = <NotificationType, int>{
        NotificationType.general: 15,
        NotificationType.feeding: 25,
        NotificationType.walk: 10,
      };

      final engagement = UserEngagement(
        userId: 'test',
        date: DateTime.now(),
        totalNotifications: 50,
        openedNotifications: 30,
        clickedNotifications: 10,
        dismissedNotifications: 8,
        engagementByType: engagementByType,
        preferredTimeSlots: [],
        overallEngagementRate: 0.6,
      );

      // Act & Assert
      expect(engagement.preferredType, equals(NotificationType.feeding));
    });

    test('should convert to and from JSON', () {
      // Arrange
      final engagementByType = <NotificationType, int>{
        NotificationType.general: 15,
        NotificationType.feeding: 25,
      };

      final originalEngagement = UserEngagement(
        userId: 'test_user',
        date: DateTime(2023, 1, 1, 12, 0, 0),
        totalNotifications: 50,
        openedNotifications: 30,
        clickedNotifications: 10,
        dismissedNotifications: 8,
        engagementByType: engagementByType,
        preferredTimeSlots: ['09:00', '12:00', '18:00'],
        overallEngagementRate: 0.6,
      );

      // Act
      final json = originalEngagement.toJson();
      final fromJson = UserEngagement.fromJson(json);

      // Assert
      expect(fromJson.userId, equals(originalEngagement.userId));
      expect(fromJson.date, equals(originalEngagement.date));
      expect(
        fromJson.totalNotifications,
        equals(originalEngagement.totalNotifications),
      );
      expect(
        fromJson.openedNotifications,
        equals(originalEngagement.openedNotifications),
      );
      expect(
        fromJson.clickedNotifications,
        equals(originalEngagement.clickedNotifications),
      );
      expect(
        fromJson.dismissedNotifications,
        equals(originalEngagement.dismissedNotifications),
      );
      expect(
        fromJson.engagementByType,
        equals(originalEngagement.engagementByType),
      );
      expect(
        fromJson.preferredTimeSlots,
        equals(originalEngagement.preferredTimeSlots),
      );
      expect(
        fromJson.overallEngagementRate,
        equals(originalEngagement.overallEngagementRate),
      );
    });
  });

  group('NotificationStatsFactory Tests', () {
    test('should generate mock stats', () {
      // Act
      final mockStats = NotificationStatsFactory.generateMockStats(
        days: 7,
        notificationsPerDay: 3,
      );

      // Assert
      expect(mockStats.length, equals(21)); // 7 * 3
      expect(mockStats.first.type, isA<NotificationType>());
      expect(mockStats.first.sentCount, greaterThan(0));
      expect(mockStats.first.openedCount, greaterThan(0));
    });

    test('should generate mock user engagement', () {
      // Act
      final mockEngagement =
          NotificationStatsFactory.generateMockUserEngagement(
            days: 7,
            users: 3,
          );

      // Assert
      expect(mockEngagement.length, equals(21)); // 7 * 3
      expect(mockEngagement.first.userId, startsWith('user_'));
      expect(mockEngagement.first.totalNotifications, greaterThan(0));
      expect(mockEngagement.first.engagementByType, isNotEmpty);
    });

    test('should generate summary', () {
      // Arrange
      final stats = [
        NotificationStats(
          id: '1',
          title: '테스트 1',
          type: NotificationType.general,
          date: DateTime.now(),
          sentCount: 100,
          openedCount: 60,
          clickedCount: 20,
          dismissedCount: 15,
          failedCount: 5,
          openRate: 0.6,
          clickRate: 0.2,
          dismissRate: 0.15,
          failureRate: 0.05,
        ),
        NotificationStats(
          id: '2',
          title: '테스트 2',
          type: NotificationType.feeding,
          date: DateTime.now(),
          sentCount: 50,
          openedCount: 30,
          clickedCount: 10,
          dismissedCount: 8,
          failedCount: 2,
          openRate: 0.6,
          clickRate: 0.2,
          dismissRate: 0.16,
          failureRate: 0.04,
        ),
      ];

      // Act
      final summary = NotificationStatsFactory.generateSummary(stats);

      // Assert
      expect(summary['totalSent'], equals(157.0)); // (100+5) + (50+2)
      expect(summary['totalOpened'], equals(90.0)); // 60 + 30
      expect(summary['totalClicked'], equals(30.0)); // 20 + 10
      expect(summary['averageOpenRate'], greaterThan(0.0));
      expect(summary['averageClickRate'], greaterThan(0.0));
    });

    test('should handle empty stats for summary', () {
      // Act
      final summary = NotificationStatsFactory.generateSummary([]);

      // Assert
      expect(summary, isEmpty);
    });
  });

  group('StatsType Tests', () {
    test('should have correct stats type values', () {
      // Assert
      expect(StatsType.sent, isNotNull);
      expect(StatsType.opened, isNotNull);
      expect(StatsType.clicked, isNotNull);
      expect(StatsType.dismissed, isNotNull);
      expect(StatsType.failed, isNotNull);
    });
  });
}
