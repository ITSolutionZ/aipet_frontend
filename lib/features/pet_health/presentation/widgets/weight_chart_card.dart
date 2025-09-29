import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/testing/mock_data/features/pet_health/pet_health_mock_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 Weight Chart State Provider
final weightChartStateProvider =
    StateNotifierProvider<WeightChartController, WeightChartState>(
      (ref) => WeightChartController(),
    );

class WeightChartController extends StateNotifier<WeightChartState> {
  WeightChartController() : super(const WeightChartState());

  void updateMonthOffset(int offset) {
    state = state.copyWith(currentMonthOffset: offset);
  }

  void setDragStart(double x) {
    state = state.copyWith(dragStartX: x);
  }
}

class WeightChartState {
  final int currentMonthOffset;
  final double dragStartX;

  const WeightChartState({this.currentMonthOffset = 0, this.dragStartX = 0});

  WeightChartState copyWith({int? currentMonthOffset, double? dragStartX}) {
    return WeightChartState(
      currentMonthOffset: currentMonthOffset ?? this.currentMonthOffset,
      dragStartX: dragStartX ?? this.dragStartX,
    );
  }
}

class WeightChartCard extends ConsumerWidget {
  const WeightChartCard({super.key});

  static const int _monthsPerPage = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartState = ref.watch(weightChartStateProvider);
    final weightRecords = PetHealthMockService.getMockWeightRecords();

    return Container(
      width: double.infinity,
      padding: const const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xl,
      ), // 좌우 패딩 줄여서 차트 너비 확대
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
                padding: const const EdgeInsets.all(AppSpacing.sm),
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
              const const SizedBox(width: AppSpacing.md),
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
              const const SizedBox(width: AppSpacing.lg),
              _buildLegendItem('去年', AppColors.pointBrown),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 320, // 높이 더욱 증가 (280 → 320)
            padding: const const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 20.0,
            ), // 좌우 패딩 줄이고 상하 패딩 유지
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Padding(
                padding: const const EdgeInsets.all(
                  2.0,
                ), // 차트 주변 여백 더 감소하여 그래프 영역 최대화
                child: _buildWeightChart(
                  weightRecords,
                  chartState.currentMonthOffset,
                  ref,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
        const const SizedBox(width: AppSpacing.xs),
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

  Widget _buildWeightChart(
    List<dynamic> weightRecords,
    int monthOffset,
    WidgetRef ref,
  ) {
    // Mock 데이터에서 차트 데이터 가져오기
    final chartData = PetHealthMockService.getMockWeightChartData();
    final currentYearData = <FlSpot>[];
    final lastYearBarData = <BarChartGroupData>[];

    final now = DateTime.now();

    // 현재 연도 데이터 (꺾은선 그래프용) - 슬라이드된 중앙월 기준으로 6개월
    final currentData = chartData['currentYearData'] as Map<String, double>;
    for (int i = 0; i < _monthsPerPage; i++) {
      // 중앙월을 기준으로 앞뒤로 배치
      final targetMonthOffset = monthOffset + (i - 2); // -2, -1, 0, 1, 2, 3
      final targetDate = DateTime(now.year, now.month - targetMonthOffset, 1);
      final monthKey = targetDate.month.toString();
      final weight = currentData[monthKey] ?? 5.0;
      currentYearData.add(FlSpot((i + 1).toDouble(), weight));
    }

    // 작년 데이터 (막대 그래프용) - 슬라이드된 중앙월 기준으로 6개월
    final lastYearData = chartData['lastYearData'] as Map<String, double>;
    for (int i = 0; i < _monthsPerPage; i++) {
      final targetMonthOffset = monthOffset + (i - 2);
      final targetDate = DateTime(now.year, now.month - targetMonthOffset, 1);
      final monthKey = targetDate.month.toString();
      final weight = lastYearData[monthKey] ?? 4.5;
      lastYearBarData.add(
        BarChartGroupData(
          x: i + 1,
          barRods: [
            BarChartRodData(
              toY: weight,
              color: AppColors.pointBrown.withValues(alpha: 0.6),
              width: 30,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    // 동적으로 Y축 범위 계산하여 차트가 범례를 넘지 않도록 조정
    final allWeights = [
      ...currentYearData.map((spot) => spot.y),
      ...lastYearBarData.map((bar) => bar.barRods.first.toY),
    ];
    final minDataWeight = allWeights.reduce((a, b) => a < b ? a : b);
    final maxDataWeight = allWeights.reduce((a, b) => a > b ? a : b);

    // 더 보수적인 범위 설정으로 오버플로우 완전 방지
    final dataRange = maxDataWeight - minDataWeight;
    final bottomPadding = dataRange * 0.15; // 하단 15% 패딩
    final topPadding = dataRange * 0.20; // 상단 20% 패딩 (더 보수적)

    final minWeight = (minDataWeight - bottomPadding).clamp(0, double.infinity);
    final maxWeight = maxDataWeight + topPadding;

    return Listener(
      onPointerDown: (event) {
        ref
            .read(weightChartStateProvider.notifier)
            .setDragStart(event.localPosition.dx);
      },
      onPointerUp: (event) {
        final chartState = ref.read(weightChartStateProvider);
        final swipeDistance = event.localPosition.dx - chartState.dragStartX;
        const swipeThreshold = 30.0; // 낮은 임계값

        if (swipeDistance > swipeThreshold) {
          // 오른쪽으로 스와이프 (이전 월)
          ref
              .read(weightChartStateProvider.notifier)
              .updateMonthOffset(chartState.currentMonthOffset - 1);
        } else if (swipeDistance < -swipeThreshold) {
          // 왼쪽으로 스와이프 (다음 월)
          ref
              .read(weightChartStateProvider.notifier)
              .updateMonthOffset(chartState.currentMonthOffset + 1);
        }
      },
      child: Stack(
        children: [
          // 막대 차트 (작년 데이터)
          BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              maxY: maxWeight.toDouble(),
              minY: minWeight.toDouble(),
              groupsSpace: 20, // 막대 간격 더욱 증가하여 차트 전체 너비 활용
              barTouchData: BarTouchData(
                enabled: false, // 터치 비활성화하여 스와이프 감지 허용
                touchTooltipData: BarTouchTooltipData(
                  tooltipBorder: BorderSide.none,
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const const EdgeInsets.all(8),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '去年\n${rod.toY.toStringAsFixed(1)}kg',
                      AppFonts.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 0.5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.pointGray.withValues(alpha: 0.15),
                    strokeWidth: 0.8,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: AppColors.pointGray.withValues(alpha: 0.15),
                    strokeWidth: 0.8,
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
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value >= 1 && value <= _monthsPerPage) {
                        final now = DateTime.now();
                        final targetMonthOffset =
                            monthOffset + ((value.toInt() - 1) - 2);
                        final targetDate = DateTime(
                          now.year,
                          now.month - targetMonthOffset,
                          1,
                        );
                        final monthName = '${targetDate.month}月';
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            monthName,
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointGray,
                              fontSize: 12, // 폰트 크기 증가
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const Text('');
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
                    reservedSize: 50, // Y축 라벨 공간 최적화
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
              barGroups: lastYearBarData,
            ),
          ),
          // 라인 차트 (현재 연도 데이터)
          Padding(
            padding: const const EdgeInsets.only(
              left: 50,
              bottom: 32,
              right: 2,
            ), // Y축과 X축 라벨 영역 최적화
            child: LineChart(
              LineChartData(
                clipData: const FlClipData.all(), // 모든 방향으로 클리핑 적용
                gridData: const FlGridData(show: false), // 격자는 막대차트에서 처리
                titlesData: const FlTitlesData(show: false), // 타이틀도 막대차트에서 처리
                borderData: FlBorderData(show: false), // 테두리도 막대차트에서 처리
                minX: 1,
                maxX: _monthsPerPage.toDouble(),
                minY: minWeight.toDouble(),
                maxY: maxWeight.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: currentYearData,
                    isCurved: true,
                    color: AppColors.pointGreen,
                    barWidth: 5, // 라인 굵기 더 증가 (4 → 5)
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 7, // 점 크기 더 증가 (6 → 7)
                          color: AppColors.pointGreen,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false), // 배경 그라데이션 제거
                    shadow: Shadow(
                      color: AppColors.pointGreen.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: false, // 터치 비활성화하여 스와이프 감지 허용
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBorder: BorderSide.none,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const const EdgeInsets.all(8),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          '今年\n${barSpot.y.toStringAsFixed(1)}kg',
                          AppFonts.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
