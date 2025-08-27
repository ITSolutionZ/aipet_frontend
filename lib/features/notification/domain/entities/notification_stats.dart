import '../../../../shared/mock_data/mock_data_service.dart';
import 'notification_model.dart';

/// 알림 통계 타입
enum StatsType {
  sent, // 발송
  opened, // 개봉
  clicked, // 클릭
  dismissed, // 무시
  failed, // 실패
}

/// 알림 통계 모델
class NotificationStats {
  final String id;
  final String title;
  final NotificationType type;
  final DateTime date;
  final int sentCount;
  final int openedCount;
  final int clickedCount;
  final int dismissedCount;
  final int failedCount;
  final double openRate;
  final double clickRate;
  final double dismissRate;
  final double failureRate;
  final Map<String, dynamic>? metadata;

  const NotificationStats({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.sentCount,
    required this.openedCount,
    required this.clickedCount,
    required this.dismissedCount,
    required this.failedCount,
    required this.openRate,
    required this.clickRate,
    required this.dismissRate,
    required this.failureRate,
    this.metadata,
  });

  /// 총 발송 수
  int get totalSent => sentCount + failedCount;

  /// 총 반응 수
  int get totalEngagement => openedCount + clickedCount;

  /// 참여율 (개봉 + 클릭 / 발송)
  double get engagementRate {
    if (sentCount == 0) return 0.0;
    return (openedCount + clickedCount) / sentCount;
  }

  /// 성공률 (성공 발송 / 총 발송)
  double get successRate {
    if (totalSent == 0) return 0.0;
    return sentCount / totalSent;
  }

  /// 통계 복사본 생성
  NotificationStats copyWith({
    String? id,
    String? title,
    NotificationType? type,
    DateTime? date,
    int? sentCount,
    int? openedCount,
    int? clickedCount,
    int? dismissedCount,
    int? failedCount,
    double? openRate,
    double? clickRate,
    double? dismissRate,
    double? failureRate,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationStats(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      date: date ?? this.date,
      sentCount: sentCount ?? this.sentCount,
      openedCount: openedCount ?? this.openedCount,
      clickedCount: clickedCount ?? this.clickedCount,
      dismissedCount: dismissedCount ?? this.dismissedCount,
      failedCount: failedCount ?? this.failedCount,
      openRate: openRate ?? this.openRate,
      clickRate: clickRate ?? this.clickRate,
      dismissRate: dismissRate ?? this.dismissRate,
      failureRate: failureRate ?? this.failureRate,
      metadata: metadata ?? this.metadata,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'date': date.toIso8601String(),
      'sentCount': sentCount,
      'openedCount': openedCount,
      'clickedCount': clickedCount,
      'dismissedCount': dismissedCount,
      'failedCount': failedCount,
      'openRate': openRate,
      'clickRate': clickRate,
      'dismissRate': dismissRate,
      'failureRate': failureRate,
      'metadata': metadata,
    };
  }

  /// JSON에서 생성
  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      id: json['id'],
      title: json['title'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      date: DateTime.parse(json['date']),
      sentCount: json['sentCount'] ?? 0,
      openedCount: json['openedCount'] ?? 0,
      clickedCount: json['clickedCount'] ?? 0,
      dismissedCount: json['dismissedCount'] ?? 0,
      failedCount: json['failedCount'] ?? 0,
      openRate: (json['openRate'] ?? 0.0).toDouble(),
      clickRate: (json['clickRate'] ?? 0.0).toDouble(),
      dismissRate: (json['dismissRate'] ?? 0.0).toDouble(),
      failureRate: (json['failureRate'] ?? 0.0).toDouble(),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  @override
  String toString() {
    return 'NotificationStats(id: $id, title: $title, type: $type, date: $date, sentCount: $sentCount, openRate: ${(openRate * 100).toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationStats && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 알림 분석 모델
class NotificationAnalytics {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final List<NotificationStats> stats;
  final Map<NotificationType, List<NotificationStats>> statsByType;
  final Map<String, double> summary;

  const NotificationAnalytics({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.stats,
    required this.statsByType,
    required this.summary,
  });

  /// 총 발송 수
  int get totalSent => stats.fold(0, (sum, stat) => sum + stat.totalSent);

  /// 총 개봉 수
  int get totalOpened => stats.fold(0, (sum, stat) => sum + stat.openedCount);

  /// 총 클릭 수
  int get totalClicked => stats.fold(0, (sum, stat) => sum + stat.clickedCount);

  /// 평균 개봉률
  double get averageOpenRate {
    if (stats.isEmpty) return 0.0;
    final totalRate = stats.fold(0.0, (sum, stat) => sum + stat.openRate);
    return totalRate / stats.length;
  }

  /// 평균 클릭률
  double get averageClickRate {
    if (stats.isEmpty) return 0.0;
    final totalRate = stats.fold(0.0, (sum, stat) => sum + stat.clickRate);
    return totalRate / stats.length;
  }

  /// 평균 참여율
  double get averageEngagementRate {
    if (stats.isEmpty) return 0.0;
    final totalRate = stats.fold(0.0, (sum, stat) => sum + stat.engagementRate);
    return totalRate / stats.length;
  }

  /// 가장 성공적인 알림 타입
  NotificationType? get bestPerformingType {
    if (statsByType.isEmpty) return null;

    NotificationType? bestType;
    double bestRate = 0.0;

    for (final entry in statsByType.entries) {
      final typeStats = entry.value;
      if (typeStats.isEmpty) continue;

      final avgRate =
          typeStats.fold(0.0, (sum, stat) => sum + stat.engagementRate) /
          typeStats.length;
      if (avgRate > bestRate) {
        bestRate = avgRate;
        bestType = entry.key;
      }
    }

    return bestType;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'stats': stats.map((s) => s.toJson()).toList(),
      'statsByType': statsByType.map(
        (key, value) =>
            MapEntry(key.name, value.map((s) => s.toJson()).toList()),
      ),
      'summary': summary,
    };
  }

  /// JSON에서 생성
  factory NotificationAnalytics.fromJson(Map<String, dynamic> json) {
    final statsList = (json['stats'] as List)
        .map((item) => NotificationStats.fromJson(item))
        .toList();

    final statsByTypeMap = <NotificationType, List<NotificationStats>>{};
    final statsByTypeJson = json['statsByType'] as Map<String, dynamic>;

    for (final entry in statsByTypeJson.entries) {
      final type = NotificationType.values.firstWhere(
        (e) => e.name == entry.key,
      );
      final typeStats = (entry.value as List)
          .map((item) => NotificationStats.fromJson(item))
          .toList();
      statsByTypeMap[type] = typeStats;
    }

    return NotificationAnalytics(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      stats: statsList,
      statsByType: statsByTypeMap,
      summary: Map<String, double>.from(json['summary']),
    );
  }
}

/// 사용자 참여도 모델
class UserEngagement {
  final String userId;
  final DateTime date;
  final int totalNotifications;
  final int openedNotifications;
  final int clickedNotifications;
  final int dismissedNotifications;
  final Map<NotificationType, int> engagementByType;
  final List<String> preferredTimeSlots;
  final double overallEngagementRate;

  const UserEngagement({
    required this.userId,
    required this.date,
    required this.totalNotifications,
    required this.openedNotifications,
    required this.clickedNotifications,
    required this.dismissedNotifications,
    required this.engagementByType,
    required this.preferredTimeSlots,
    required this.overallEngagementRate,
  });

  /// 개봉률
  double get openRate {
    if (totalNotifications == 0) return 0.0;
    return openedNotifications / totalNotifications;
  }

  /// 클릭률
  double get clickRate {
    if (totalNotifications == 0) return 0.0;
    return clickedNotifications / totalNotifications;
  }

  /// 무시율
  double get dismissRate {
    if (totalNotifications == 0) return 0.0;
    return dismissedNotifications / totalNotifications;
  }

  /// 가장 선호하는 알림 타입
  NotificationType? get preferredType {
    if (engagementByType.isEmpty) return null;

    NotificationType? preferred;
    int maxEngagement = 0;

    for (final entry in engagementByType.entries) {
      if (entry.value > maxEngagement) {
        maxEngagement = entry.value;
        preferred = entry.key;
      }
    }

    return preferred;
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'totalNotifications': totalNotifications,
      'openedNotifications': openedNotifications,
      'clickedNotifications': clickedNotifications,
      'dismissedNotifications': dismissedNotifications,
      'engagementByType': engagementByType.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'preferredTimeSlots': preferredTimeSlots,
      'overallEngagementRate': overallEngagementRate,
    };
  }

  /// JSON에서 생성
  factory UserEngagement.fromJson(Map<String, dynamic> json) {
    final engagementByTypeMap = <NotificationType, int>{};
    final engagementByTypeJson =
        json['engagementByType'] as Map<String, dynamic>;

    for (final entry in engagementByTypeJson.entries) {
      final type = NotificationType.values.firstWhere(
        (e) => e.name == entry.key,
      );
      engagementByTypeMap[type] = entry.value as int;
    }

    return UserEngagement(
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      totalNotifications: json['totalNotifications'] ?? 0,
      openedNotifications: json['openedNotifications'] ?? 0,
      clickedNotifications: json['clickedNotifications'] ?? 0,
      dismissedNotifications: json['dismissedNotifications'] ?? 0,
      engagementByType: engagementByTypeMap,
      preferredTimeSlots: List<String>.from(json['preferredTimeSlots'] ?? []),
      overallEngagementRate: (json['overallEngagementRate'] ?? 0.0).toDouble(),
    );
  }
}

/// 통계 팩토리
class NotificationStatsFactory {
  /// 모의 통계 데이터 생성
  static List<NotificationStats> generateMockStats({
    int days = 30,
    int notificationsPerDay = 5,
  }) {
    if (MockDataService.isEnabled) {
      final mockData = MockDataService.getMockNotificationStats(
        days: days,
        notificationsPerDay: notificationsPerDay,
      );

      return mockData
          .map(
            (data) => NotificationStats(
              id: data['id'] as String,
              title: data['title'] as String,
              type: NotificationType.reminder, // 기본값
              date: DateTime.parse(data['date'] as String),
              sentCount: data['sentCount'] as int,
              openedCount: data['openedCount'] as int,
              clickedCount: data['clickedCount'] as int,
              dismissedCount: 0,
              failedCount: 0,
              openRate: data['openRate'] as double,
              clickRate: data['clickRate'] as double,
              dismissRate: 0.0,
              failureRate: 0.0,
              metadata: {},
            ),
          )
          .toList();
    }

    return [];
  }

  /// 모의 사용자 참여도 데이터 생성
  static List<UserEngagement> generateMockUserEngagement({
    int days = 30,
    int users = 5,
  }) {
    if (MockDataService.isEnabled) {
      final mockData = MockDataService.getMockUserEngagement(
        days: days,
        users: users,
      );

      return mockData
          .map(
            (data) => UserEngagement(
              userId: data['userId'] as String,
              date: DateTime.parse(data['date'] as String),
              totalNotifications: data['totalNotifications'] as int,
              openedNotifications: data['openedNotifications'] as int,
              clickedNotifications: 0,
              dismissedNotifications: 0,
              engagementByType: {},
              preferredTimeSlots: ['09:00', '12:00', '18:00'],
              overallEngagementRate: data['engagementRate'] as double,
            ),
          )
          .toList();
    }

    return [];
  }

  /// 통계 요약 생성
  static Map<String, double> generateSummary(List<NotificationStats> stats) {
    if (stats.isEmpty) return {};

    final totalSent = stats.fold(0, (sum, stat) => sum + stat.totalSent);
    final totalOpened = stats.fold(0, (sum, stat) => sum + stat.openedCount);
    final totalClicked = stats.fold(0, (sum, stat) => sum + stat.clickedCount);
    final totalFailed = stats.fold(0, (sum, stat) => sum + stat.failedCount);

    return {
      'totalSent': totalSent.toDouble(),
      'totalOpened': totalOpened.toDouble(),
      'totalClicked': totalClicked.toDouble(),
      'totalFailed': totalFailed.toDouble(),
      'averageOpenRate': totalSent > 0 ? totalOpened / totalSent : 0.0,
      'averageClickRate': totalSent > 0 ? totalClicked / totalSent : 0.0,
      'averageFailureRate': totalSent > 0 ? totalFailed / totalSent : 0.0,
      'totalEngagementRate': totalSent > 0
          ? (totalOpened + totalClicked) / totalSent
          : 0.0,
    };
  }
}
