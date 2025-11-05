import '../../../domain/domain.dart';
import 'notification_analytics_calculator_helper.dart';


/// 알림 분석 트렌드 헬퍼
class NotificationAnalyticsTrendHelper {
  /// 변화율 계산
  static double calculateChange(double current, double previous) {
    if (previous == 0.0) return current > 0.0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100.0;
  }

  /// 트렌드 분석 생성
  static Map<String, dynamic> createTrendAnalysis(
    List<NotificationStats> stats,
  ) {
    if (stats.isEmpty) return {};

    final now = DateTime.now();

    // 최근 7일 vs 이전 7일 비교
    final recentStats = stats
        .where((s) => s.date.isAfter(now.subtract(const Duration(days: 7))))
        .toList();

    final previousStats = stats
        .where(
          (s) =>
              s.date.isAfter(now.subtract(const Duration(days: 14))) &&
              s.date.isBefore(now.subtract(const Duration(days: 7))),
        )
        .toList();

    final recentSummary = NotificationAnalyticsCalculatorHelper.generateSummary(
      recentStats,
    );
    final previousSummary =
        NotificationAnalyticsCalculatorHelper.generateSummary(previousStats);

    return {
      'recent': recentSummary,
      'previous': previousSummary,
      'trend': {
        'openRateChange': calculateChange(
          recentSummary['averageOpenRate'] ?? 0.0,
          previousSummary['averageOpenRate'] ?? 0.0,
        ),
        'clickRateChange': calculateChange(
          recentSummary['averageClickRate'] ?? 0.0,
          previousSummary['averageClickRate'] ?? 0.0,
        ),
        'engagementRateChange': calculateChange(
          recentSummary['totalEngagementRate'] ?? 0.0,
          previousSummary['totalEngagementRate'] ?? 0.0,
        ),
      },
    };
  }

  /// 기간별 통계 비교
  static Map<String, dynamic> comparePeriods(
    List<NotificationStats> period1Stats,
    List<NotificationStats> period2Stats,
  ) {
    final period1Summary =
        NotificationAnalyticsCalculatorHelper.generateSummary(period1Stats);
    final period2Summary =
        NotificationAnalyticsCalculatorHelper.generateSummary(period2Stats);

    return {
      'period1': period1Summary,
      'period2': period2Summary,
      'changes': {
        'sentChange': calculateChange(
          period1Summary['totalSent'] ?? 0.0,
          period2Summary['totalSent'] ?? 0.0,
        ),
        'openRateChange': calculateChange(
          period1Summary['averageOpenRate'] ?? 0.0,
          period2Summary['averageOpenRate'] ?? 0.0,
        ),
        'clickRateChange': calculateChange(
          period1Summary['averageClickRate'] ?? 0.0,
          period2Summary['averageClickRate'] ?? 0.0,
        ),
      },
    };
  }
}
