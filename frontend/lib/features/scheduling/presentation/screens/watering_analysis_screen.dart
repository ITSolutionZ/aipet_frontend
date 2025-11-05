import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';


import '../../../../shared/shared.dart';
part 'watering_analysis_screen.g.dart';

/// 급수 분석 화면 컨트롤러
@riverpod
class WateringAnalysisController extends _$WateringAnalysisController {
  @override
  WateringAnalysisState build() {
    return const WateringAnalysisState();
  }

  void changePeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
  }
}

class WateringAnalysisState {
  final String selectedPeriod;
  final List<String> periods;

  const WateringAnalysisState({
    this.selectedPeriod = '週間',
    this.periods = const ['日間', '週間', '月間'],
  });

  WateringAnalysisState copyWith({
    String? selectedPeriod,
    List<String>? periods,
  }) {
    return WateringAnalysisState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      periods: periods ?? this.periods,
    );
  }
}

/// 급수 분석 화면
class WateringAnalysisScreen extends ConsumerWidget {
  const WateringAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wateringAnalysisControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientAppBar(title: '給水分析'),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기간 선택
            _buildPeriodSelector(state, ref),
            const SizedBox(height: AppSpacing.lg),

            // 분석 차트
            _buildAnalysisChart(),
            const SizedBox(height: AppSpacing.lg),

            // 통계 요약
            _buildStatsSummary(),
            const SizedBox(height: AppSpacing.lg),

            // 상세 분석
            _buildDetailedAnalysis(),
          ],
        ),
      ),
    );
  }

  /// 기간 선택 위젯
  Widget _buildPeriodSelector(WateringAnalysisState state, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '分析期間',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: state.periods.map((period) {
                final isSelected = state.selectedPeriod == period;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      label: Text(period),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(wateringAnalysisControllerProvider.notifier)
                              .changePeriod(period);
                        }
                      },
                      selectedColor: AppColors.pointBlue.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.pointBlue,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.pointBlue
                            : AppColors.pointGray,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 분석 차트 위젯
  Widget _buildAnalysisChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '水分摂取量推移',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.pointOffWhite,
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: AppColors.pointGray.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: AppColors.pointGray),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'チャート表示エリア',
                      style: TextStyle(
                        color: AppColors.pointGray,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '(Coming Soon)',
                      style: TextStyle(
                        color: AppColors.pointGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 요약 위젯
  Widget _buildStatsSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '統計サマリー',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '平均摂取量',
                    '180ml',
                    Icons.water_drop,
                    AppColors.pointBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '最高摂取量',
                    '250ml',
                    Icons.trending_up,
                    AppColors.pointGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '最低摂取量',
                    '120ml',
                    Icons.trending_down,
                    AppColors.pointBrown,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '給水回数',
                    '21回',
                    Icons.repeat,
                    AppColors.tonePeach,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          Text(
            label,
            style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 상세 분석 위젯
  Widget _buildDetailedAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '詳細分析',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildAnalysisItem(
              '給水パターン',
              '定期的な給水が習慣化されています。',
              Icons.schedule,
              AppColors.pointGreen,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildAnalysisItem(
              '推奨事項',
              '夜間の給水量を少し増やすことをお勧めします。',
              Icons.lightbulb,
              AppColors.pointBlue,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildAnalysisItem(
              '注意点',
              '特に問題はありません。',
              Icons.info,
              AppColors.pointGray,
            ),
          ],
        ),
      ),
    );
  }

  /// 분석 아이템
  Widget _buildAnalysisItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFonts.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.pointDark,
                ),
              ),
              Text(
                description,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
