import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design/design.dart';
import '../../../../shared/mock_data/mock_data_service.dart';

/// 체중 추적 화면
class WeightTrackingScreen extends ConsumerStatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  ConsumerState<WeightTrackingScreen> createState() =>
      _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends ConsumerState<WeightTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final weightRecords = MockDataService.getMockWeightRecords();

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '体重管理',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 체중 요약 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.pointGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: const Icon(
                          Icons.monitor_weight_outlined,
                          color: AppColors.pointGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '現在の体重',
                        style: AppFonts.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      _buildWeightInfo(
                        '現在',
                        '${weightRecords.first.weight}kg',
                        AppColors.pointGreen,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildWeightInfo('変化', '+0.2kg', AppColors.pointBlue),
                      const SizedBox(width: AppSpacing.md),
                      _buildWeightInfo('目標', '5.0kg', AppColors.pointBrown),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 체중 변화 차트 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.pointBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: const Icon(
                          Icons.show_chart,
                          color: AppColors.pointBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '体重推移',
                        style: AppFonts.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // 범례
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('今年', AppColors.pointGreen),
                      const SizedBox(width: AppSpacing.lg),
                      _buildLegendItem('去年', AppColors.pointBrown),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    height: 200,
                    child: _buildWeightChart(weightRecords),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 체중 기록 목록
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.pointBrown.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: AppColors.pointBrown,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        '体重記録',
                        style: AppFonts.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.pointDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: weightRecords.length,
                    itemBuilder: (context, index) {
                      final record = weightRecords[index];
                      return _buildWeightRecordItem(record, index);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 체중 기록 추가 다이얼로그 표시
          _showAddWeightDialog(context);
        },
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWeightInfo(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppFonts.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightRecordItem(dynamic record, int index) {
    final weightRecords = MockDataService.getMockWeightRecords();
    final isLatest = index == 0;
    final change = index < weightRecords.length - 1
        ? record.weight - weightRecords[index + 1].weight
        : 0.0;
    final changeText = change > 0
        ? '+${change.toStringAsFixed(1)}kg'
        : '${change.toStringAsFixed(1)}kg';
    final changeColor = change > 0
        ? AppColors.pointGreen
        : change < 0
        ? AppColors.pointPink
        : AppColors.pointGray;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isLatest
                ? AppColors.pointGreen.withValues(alpha: 0.1)
                : AppColors.pointGray.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.monitor_weight,
            color: isLatest ? AppColors.pointGreen : AppColors.pointGray,
            size: 25,
          ),
        ),
        title: Text(
          '${record.weight}kg',
          style: AppFonts.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(record.recordedDate),
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
            if (record.notes != null && record.notes!.isNotEmpty)
              Text(
                record.notes!,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
              ),
          ],
        ),
        trailing: index < weightRecords.length - 1
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  changeText,
                  style: AppFonts.bodySmall.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppFonts.bodySmall.copyWith(
            color: AppColors.pointGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart(List<dynamic> weightRecords) {
    // 최근 1년간의 데이터 준비 (월별 평균)
    final now = DateTime.now();
    final currentYearData = <FlSpot>[];
    final lastYearData = <FlSpot>[];

    // 현재 연도 데이터 (실제 데이터 사용)
    for (int month = 1; month <= 12; month++) {
      final monthRecords = weightRecords.where((record) {
        return record.recordedDate.year == now.year &&
            record.recordedDate.month == month;
      }).toList();

      if (monthRecords.isNotEmpty) {
        final averageWeight =
            monthRecords.fold<double>(
              0.0,
              (sum, record) => sum + record.weight,
            ) /
            monthRecords.length;
        currentYearData.add(FlSpot(month.toDouble(), averageWeight));
      } else {
        // 데이터가 없는 경우 이전 값 사용 또는 기본값
        final prevWeight = currentYearData.isNotEmpty
            ? currentYearData.last.y
            : weightRecords.isNotEmpty
            ? weightRecords.first.weight
            : 5.0;
        currentYearData.add(FlSpot(month.toDouble(), prevWeight));
      }
    }

    // 작년 데이터 (시뮬레이션 - 실제로는 작년 데이터가 필요)
    final baseWeight = weightRecords.isNotEmpty
        ? weightRecords.first.weight
        : 5.0;
    for (int month = 1; month <= 12; month++) {
      // 작년에는 현재보다 10% 적은 체중으로 시뮬레이션
      final lastYearWeight = baseWeight * 0.9 + (month * 0.05);
      lastYearData.add(FlSpot(month.toDouble(), lastYearWeight));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 0.5,
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
                final months = MockDataService.getMockMonthNames();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    months[value.toInt() - 1],
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
              interval: 0.5,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toStringAsFixed(1)}kg',
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
        minX: 1,
        maxX: 12,
        minY: 4.0,
        maxY: 7.0,
        lineBarsData: [
          // 현재 연도 체중 라인
          LineChartBarData(
            spots: currentYearData,
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
          // 작년 체중 라인
          LineChartBarData(
            spots: lastYearData,
            isCurved: true,
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
                final isCurrentYear = barSpot.barIndex == 0;
                return LineTooltipItem(
                  isCurrentYear ? '今年' : '去年',
                  AppFonts.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '\n${barSpot.y.toStringAsFixed(1)}kg',
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

  void _showAddWeightDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('体重を記録'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('体重記録機能は実装予定です。')],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('記録'),
          ),
        ],
      ),
    );
  }
}
