import '../../../domain/domain.dart';

/// 알림 분석 계산 헬퍼
class NotificationAnalyticsCalculatorHelper {
  /// 통계 요약 생성
  static Map<String, double> generateSummary(List<NotificationStats> stats) {
    if (stats.isEmpty) return {};

    final totalSent = stats.fold<int>(0, (sum, stat) => sum + stat.sentCount);
    final totalOpened = stats.fold<int>(
      0,
      (sum, stat) => sum + stat.openedCount,
    );
    final totalClicked = stats.fold<int>(
      0,
      (sum, stat) => sum + stat.clickedCount,
    );
    final totalDismissed = stats.fold<int>(
      0,
      (sum, stat) => sum + stat.dismissedCount,
    );

    final openRate = totalSent > 0 ? (totalOpened / totalSent) * 100 : 0.0;
    final clickRate = totalOpened > 0
        ? (totalClicked / totalOpened) * 100
        : 0.0;
    final engagementRate = totalSent > 0
        ? ((totalOpened + totalClicked) / totalSent) * 100
        : 0.0;

    return {
      'totalSent': totalSent.toDouble(),
      'totalOpened': totalOpened.toDouble(),
      'totalClicked': totalClicked.toDouble(),
      'totalDismissed': totalDismissed.toDouble(),
      'averageOpenRate': openRate,
      'averageClickRate': clickRate,
      'totalEngagementRate': engagementRate,
    };
  }

  /// 분석 데이터 생성
  static NotificationAnalytics createAnalytics(List<NotificationStats> stats) {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    final endDate = now;

    // 타입별 통계 그룹화
    final statsByType = <NotificationType, List<NotificationStats>>{};
    for (final stat in stats) {
      if (!statsByType.containsKey(stat.type)) {
        statsByType[stat.type] = [];
      }
      statsByType[stat.type]!.add(stat);
    }

    // 요약 생성
    final summary = generateSummary(stats);

    return NotificationAnalytics(
      id: 'analytics_${now.millisecondsSinceEpoch}',
      startDate: startDate,
      endDate: endDate,
      stats: stats,
      statsByType: statsByType,
      summary: summary,
    );
  }

  /// 성과 지표 생성
  static Map<String, dynamic> createPerformanceMetrics(
    NotificationAnalytics analytics,
  ) {
    return {
      'totalSent': analytics.totalSent,
      'totalOpened': analytics.totalOpened,
      'totalClicked': analytics.totalClicked,
      'averageOpenRate': analytics.averageOpenRate,
      'averageClickRate': analytics.averageClickRate,
      'averageEngagementRate': analytics.averageEngagementRate,
      'bestPerformingType': analytics.bestPerformingType?.name,
      'period':
          '${analytics.startDate.toString().substring(0, 10)} ~ ${analytics.endDate.toString().substring(0, 10)}',
    };
  }

  /// 특정 기간의 통계 필터링
  static List<NotificationStats> filterByDateRange(
    List<NotificationStats> stats,
    DateTime startDate,
    DateTime endDate,
  ) {
    return stats.where((stat) {
      return stat.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          stat.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// 특정 타입의 통계 필터링
  static List<NotificationStats> filterByType(
    List<NotificationStats> stats,
    NotificationType type,
  ) {
    return stats.where((stat) => stat.type == type).toList();
  }
}
