import 'feeding_storage_helper.dart';

/// 급여 분석 계산 헬퍼
class FeedingAnalysisHelper {
  /// 급여 분석 데이터 계산
  static Future<Map<String, dynamic>> getFeedingAnalysisData() async {
    final records = await FeedingStorageHelper.getFeedingRecords();

    if (records.isEmpty) {
      return {
        'currentAmount': 0.0,
        'changeAmount': 0.0,
        'targetAmount': 300.0,
        'chartData': [],
        'recentRecords': [],
      };
    }

    // 최근 7일간의 데이터로 차트 생성
    final now = DateTime.now();
    final chartData = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayRecords = records.where((r) {
        final recordDate = DateTime.parse(r['fedTime'] as String);
        return recordDate.year == date.year &&
            recordDate.month == date.month &&
            recordDate.day == date.day;
      }).toList();

      final actualAmount = dayRecords.fold<double>(
        0.0,
        (sum, r) => sum + (r['amount'] as double),
      );

      chartData.add({'actual': actualAmount, 'target': 300.0});
    }

    // 최근 기록 (최대 5개)
    final recentRecords = records
        .take(5)
        .map(
          (r) => {
            'amount': '${r['amount']}g',
            'date': DateTime.parse(
              r['fedTime'] as String,
            ).toString().substring(0, 10).replaceAll('-', '/'),
            'change': '+0g',
          },
        )
        .toList();

    return {
      'currentAmount': 280.0,
      'changeAmount': 10.0,
      'targetAmount': 300.0,
      'chartData': chartData,
      'recentRecords': recentRecords,
    };
  }
}
