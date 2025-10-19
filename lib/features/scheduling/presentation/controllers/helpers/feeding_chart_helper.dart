import 'package:aipet_frontend/shared/design/design.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 급여 차트 생성 헬퍼
class FeedingChartHelper {
  /// 차트 데이터 생성
  static Map<String, List<FlSpot>> generateChartData(
    List<dynamic> feedingRecords,
  ) {
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

      const targetAmount = 300.0;

      chartData.add(FlSpot((6 - i).toDouble(), actualAmount));
      targetData.add(FlSpot((6 - i).toDouble(), targetAmount));
    }

    return {'chartData': chartData, 'targetData': targetData};
  }

  /// 제목 데이터 생성
  static FlTitlesData buildTitlesData() {
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
              axisSide: AxisSide.bottom,
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
  static FlBorderData buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: AppColors.pointGray.withValues(alpha: 0.2),
        width: 1,
      ),
    );
  }

  /// 실제 급여량 라인 생성
  static LineChartBarData buildActualDataLine(List<FlSpot> chartData) {
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
  static LineChartBarData buildTargetDataLine(List<FlSpot> targetData) {
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
  static LineTouchData buildTouchData() {
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
}
