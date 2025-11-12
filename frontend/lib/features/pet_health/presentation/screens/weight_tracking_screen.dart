import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../../../../features/pet_health/presentation/widgets/current_weight_summary_card.dart';
import '../../../../../features/pet_health/presentation/widgets/weight_chart_card.dart';
import '../../../../../features/pet_health/presentation/widgets/weight_records_card.dart';

/// 체중 추적 화면
class WeightTrackingScreen extends ConsumerWidget {
  const WeightTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonScreenPatterns.buildStandardScreen(
      title: '体重管理',
      backgroundColor: AppColors.pureWhite,
      appBar: const SoftGradientBackAppBar(title: '体重管理'),
      body: CommonScreenPatterns.buildScrollableContent(
        children: [
          // 현재 체중 요약 카드
          const CurrentWeightSummaryCard(),
          const SizedBox(height: AppSpacing.xl),

          // 체중 변화 차트 카드
          const WeightChartCard(),
          const SizedBox(height: AppSpacing.xl),

          // 체중 기록 목록
          const WeightRecordsCard(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
      floatingActionButtonLabel: '体重記録',
      onFloatingActionButtonPressed: () {
        // 체중 기록 추가 다이얼로그 표시
        _showAddWeightDialog(context);
      },
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
