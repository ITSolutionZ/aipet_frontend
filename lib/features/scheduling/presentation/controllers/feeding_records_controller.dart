import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/design/design.dart';
import '../../../../shared/mock_data/mock_data_service.dart';

class FeedingRecordsResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const FeedingRecordsResult._(this.isSuccess, this.message, this.data);

  factory FeedingRecordsResult.success(String message, [dynamic data]) =>
      FeedingRecordsResult._(true, message, data);
  factory FeedingRecordsResult.failure(String message) =>
      FeedingRecordsResult._(false, message, null);
}

class FeedingRecordsController {
  FeedingRecordsController();

  /// 급여 기록 데이터 로드
  Future<FeedingRecordsResult> loadFeedingRecords() async {
    try {
      final feedingRecords = MockDataService.getMockFeedingRecords();
      return FeedingRecordsResult.success('급여 기록이 로드되었습니다', feedingRecords);
    } catch (error) {
      return FeedingRecordsResult.failure('급여 기록 로드 실패: $error');
    }
  }

  /// 급여 통계 데이터 로드
  Future<FeedingRecordsResult> loadFeedingStatistics() async {
    try {
      final statistics = MockDataService.getMockFeedingStatistics();
      return FeedingRecordsResult.success('급여 통계가 로드되었습니다', statistics);
    } catch (error) {
      return FeedingRecordsResult.failure('급여 통계 로드 실패: $error');
    }
  }

  /// 차트 데이터 생성
  FeedingRecordsResult generateChartData(List<dynamic> feedingRecords) {
    try {
      final now = DateTime.now();
      final chartData = <FlSpot>[];
      final targetData = <FlSpot>[];

      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);

        final dayRecords = feedingRecords.where((record) {
          final recordDate = DateTime(
            record.fedTime.year,
            record.fedTime.month,
            record.fedTime.day,
          );
          return recordDate.year == date.year &&
              recordDate.month == date.month &&
              recordDate.day == date.day;
        }).toList();

        final actualAmount = dayRecords.fold<double>(
          0.0,
          (sum, record) => sum + record.amount,
        );

        const targetAmount = 300.0; // 목표량

        chartData.add(FlSpot((6 - i).toDouble(), actualAmount));
        targetData.add(FlSpot((6 - i).toDouble(), targetAmount));
      }

      final data = {'chartData': chartData, 'targetData': targetData};

      return FeedingRecordsResult.success('차트 데이터가 생성되었습니다', data);
    } catch (error) {
      return FeedingRecordsResult.failure('차트 데이터 생성 실패: $error');
    }
  }

  /// 차트 위젯 생성
  Widget buildChart(List<FlSpot> chartData, List<FlSpot> targetData) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 50,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.pointGray.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.pointGray.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: _buildTitlesData(),
        borderData: _buildBorderData(),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 350,
        lineBarsData: [
          _buildActualDataLine(chartData),
          _buildTargetDataLine(targetData),
        ],
        lineTouchData: _buildTouchData(),
      ),
    );
  }

  /// 제목 데이터 생성
  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (double value, TitleMeta meta) {
            const days = ['6日前', '5日前', '4日前', '3日前', '2日前', '昨日', '今日'];
            return SideTitleWidget(
              axisSide: meta.axisSide,
              child: Text(
                days[value.toInt()],
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointGray,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 50,
          getTitlesWidget: (double value, TitleMeta meta) {
            return Text(
              '${value.toInt()}g',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
                fontSize: 10,
              ),
            );
          },
          reservedSize: 42,
        ),
      ),
    );
  }

  /// 테두리 데이터 생성
  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: AppColors.pointGray.withValues(alpha: 0.2),
        width: 1,
      ),
    );
  }

  /// 실제 급여량 라인 생성
  LineChartBarData _buildActualDataLine(List<FlSpot> chartData) {
    return LineChartBarData(
      spots: chartData,
      isCurved: true,
      gradient: LinearGradient(
        colors: [
          AppColors.pointGreen.withValues(alpha: 0.8),
          AppColors.pointGreen,
        ],
      ),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: AppColors.pointGreen,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            AppColors.pointGreen.withValues(alpha: 0.3),
            AppColors.pointGreen.withValues(alpha: 0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  /// 목표 급여량 라인 생성
  LineChartBarData _buildTargetDataLine(List<FlSpot> targetData) {
    return LineChartBarData(
      spots: targetData,
      isCurved: false,
      color: AppColors.pointBrown.withValues(alpha: 0.6),
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      dashArray: [5, 5],
    );
  }

  /// 터치 데이터 생성
  LineTouchData _buildTouchData() {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            final isTarget = barSpot.barIndex == 1;
            return LineTooltipItem(
              isTarget ? '목표량' : '실제 급여량',
              AppFonts.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: '\n${barSpot.y.toInt()}g',
                  style: AppFonts.bodySmall.copyWith(color: Colors.white),
                ),
              ],
            );
          }).toList();
        },
      ),
    );
  }

  /// 시간 포맷팅
  String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 급여 기록 필터링
  List<dynamic> filterRecordsByDate(
    List<dynamic> records,
    DateTime startDate,
    DateTime endDate,
  ) {
    return records.where((record) {
      final recordDate = record.fedTime;
      return recordDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          recordDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// 급여 기록 검색
  List<dynamic> searchRecords(List<dynamic> records, String query) {
    if (query.isEmpty) return records;

    final lowerQuery = query.toLowerCase();
    return records.where((record) {
      return record.petName.toLowerCase().contains(lowerQuery) ||
          record.foodType.toLowerCase().contains(lowerQuery) ||
          record.foodBrand.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 새 급여 기록 추가
  Future<FeedingRecordsResult> addFeedingRecord({
    required String petName,
    required String foodType,
    required String foodBrand,
    required double amount,
    required DateTime fedTime,
  }) async {
    try {
      // Mock add logic - 실제로는 repository를 통해 저장
      await Future.delayed(const Duration(milliseconds: 500));

      final record = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'petName': petName,
        'foodType': foodType,
        'foodBrand': foodBrand,
        'amount': amount,
        'fedTime': fedTime,
        'status': 'completed',
      };

      return FeedingRecordsResult.success('급여 기록이 추가되었습니다', record);
    } catch (error) {
      return FeedingRecordsResult.failure('급여 기록 추가 실패: $error');
    }
  }

  /// 급여 기록 삭제
  Future<FeedingRecordsResult> deleteFeedingRecord(String recordId) async {
    try {
      // Mock delete logic
      await Future.delayed(const Duration(milliseconds: 300));
      return FeedingRecordsResult.success('급여 기록이 삭제되었습니다');
    } catch (error) {
      return FeedingRecordsResult.failure('급여 기록 삭제 실패: $error');
    }
  }

  /// 급여 기록 수정
  Future<FeedingRecordsResult> updateFeedingRecord({
    required String recordId,
    required String petName,
    required String foodType,
    required String foodBrand,
    required double amount,
    required DateTime fedTime,
  }) async {
    try {
      // Mock update logic
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedRecord = {
        'id': recordId,
        'petName': petName,
        'foodType': foodType,
        'foodBrand': foodBrand,
        'amount': amount,
        'fedTime': fedTime,
        'status': 'completed',
      };

      return FeedingRecordsResult.success('급여 기록이 수정되었습니다', updatedRecord);
    } catch (error) {
      return FeedingRecordsResult.failure('급여 기록 수정 실패: $error');
    }
  }

  /// 주간 급여 통계 계산
  Map<String, dynamic> calculateWeeklyStatistics(List<dynamic> records) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weeklyRecords = filterRecordsByDate(records, weekStart, weekEnd);

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
}
