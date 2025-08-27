import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../shared/design/design.dart';

class FeedingStatisticsCard extends StatelessWidget {
  final List<dynamic> feedingRecords;
  final Map<String, dynamic> statistics;

  const FeedingStatisticsCard({
    super.key,
    required this.feedingRecords,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今月の食事統計',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 200,
              child: FeedingChart(feedingRecords: feedingRecords),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildStatItem(
                  '総食事回数',
                  '${statistics['totalFeedings']}回',
                ),
                const SizedBox(width: AppSpacing.md),
                _buildStatItem(
                  '完了率',
                  '${(statistics['completionRate'] * 100).round()}%',
                ),
                const SizedBox(width: AppSpacing.md),
                _buildStatItem(
                  '平均量',
                  '${statistics['averageAmount'].round()}g',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.pointBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppFonts.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class FeedingChart extends StatelessWidget {
  final List<dynamic> feedingRecords;

  const FeedingChart({
    super.key,
    required this.feedingRecords,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final chartData = <FlSpot>[];
    final targetData = <FlSpot>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayRecords = feedingRecords.where((record) {
        final recordDate = DateTime(
          record.fedTime.year,
          record.fedTime.month,
          record.fedTime.day,
        );
        return recordDate.isAtSameMomentAs(date);
      }).toList();

      final actualAmount = dayRecords.fold<double>(
        0.0,
        (sum, record) => sum + record.amount,
      );

      const targetAmount = 300.0;

      chartData.add(FlSpot(i.toDouble(), actualAmount));
      targetData.add(FlSpot(i.toDouble(), targetAmount));
    }

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
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppColors.pointGray.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 350,
        lineBarsData: [
          LineChartBarData(
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
          ),
          LineChartBarData(
            spots: targetData,
            isCurved: false,
            color: AppColors.pointBrown.withValues(alpha: 0.6),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final isTarget = barSpot.barIndex == 1;
                return LineTooltipItem(
                  isTarget ? '目標量' : '実際 급여량',
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
        ),
      ),
    );
  }
}