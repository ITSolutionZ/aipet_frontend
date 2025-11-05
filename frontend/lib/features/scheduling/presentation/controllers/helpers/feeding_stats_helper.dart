import '../../../../../shared/shared.dart';

import 'feeding_filter_helper.dart';


/// 급여 통계 계산 헬퍼
class FeedingStatsHelper {
  /// 주간 급여 통계 계산
  static Map<String, dynamic> calculateWeeklyStatistics(List<dynamic> records) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weeklyRecords = FeedingFilterHelper.filterRecordsByDate(
      records,
      weekStart,
      weekEnd,
    );

    final totalFeedings = weeklyRecords.length;
    final totalAmount = weeklyRecords.fold<double>(
      0.0,
      (sum, record) => sum + record.amount,
    );

    final averageAmount = totalFeedings > 0 ? totalAmount / totalFeedings : 0.0;
    final completedFeedings = weeklyRecords
        .where((r) => r.status == 'completed')
        .length;
    final completionRate = totalFeedings > 0
        ? completedFeedings / totalFeedings
        : 0.0;

    return {
      'totalFeedings': totalFeedings,
      'totalAmount': totalAmount,
      'averageAmount': averageAmount,
      'completionRate': completionRate,
    };
  }

  /// 시간 포맷팅
  static String formatTime(DateTime time) {
    // ✅ DateTimeUtils 사용
    return DateTimeUtils.formatTime(time);
  }
}
