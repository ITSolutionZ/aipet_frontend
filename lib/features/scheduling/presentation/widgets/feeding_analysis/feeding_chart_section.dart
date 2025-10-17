import 'package:aipet_frontend/shared/shared.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 급여량 추이 차트 섹션
class FeedingChartSection extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const FeedingChartSection({super.key, required this.analysisData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '食事量の推移',
            style: AppFonts.fredoka(
              fontSize: AppFonts.xl,
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(height: 200, child: _buildFeedingChart()),
          const SizedBox(height: AppSpacing.lg),
          // 범례
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('実際の量', AppColors.pointBrown),
              const SizedBox(width: AppSpacing.lg),
              _buildLegendItem('目標量', AppColors.pointBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingChart() {
    final chartData = analysisData['chartData'] as List<Map<String, dynamic>>;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.pointGray.withValues(alpha: 0.3),
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
                const style = TextStyle(
                  color: AppColors.pointGray,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('月', style: style);
                    break;
                  case 1:
                    text = const Text('火', style: style);
                    break;
                  case 2:
                    text = const Text('水', style: style);
                    break;
                  case 3:
                    text = const Text('木', style: style);
                    break;
                  case 4:
                    text = const Text('金', style: style);
                    break;
                  case 5:
                    text = const Text('土', style: style);
                    break;
                  case 6:
                    text = const Text('日', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                // meta: TitleMeta, fitInside: SideTitleFitInsideData?
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: text,
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
                  style: const TextStyle(
                    color: AppColors.pointGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 300,
        lineBarsData: [
          // 실제 급여량 라인
          LineChartBarData(
            spots: chartData
                .asMap()
                .entries
                .map(
                  (entry) => FlSpot(
                    entry.key.toDouble(),
                    entry.value['actual'].toDouble(),
                  ),
                )
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.pointBrown.withValues(alpha: 0.8),
                AppColors.pointBrown,
              ],
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.pointBrown,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.pointBrown.withValues(alpha: 0.2),
                  AppColors.pointBrown.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // 목표 급여량 라인
          LineChartBarData(
            spots: chartData
                .asMap()
                .entries
                .map(
                  (entry) => FlSpot(
                    entry.key.toDouble(),
                    entry.value['target'].toDouble(),
                  ),
                )
                .toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppColors.pointBlue.withValues(alpha: 0.8),
                AppColors.pointBlue,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dashArray: [5, 5],
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.pointBlue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.pointDark,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final lineIndex = barSpot.barIndex;

                return LineTooltipItem(
                  lineIndex == 0
                      ? '実際: ${flSpot.y.toInt()}g'
                      : '目標: ${flSpot.y.toInt()}g',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppFonts.fredoka(
            fontSize: AppFonts.sm,
            color: AppColors.pointGray,
          ),
        ),
      ],
    );
  }
}
