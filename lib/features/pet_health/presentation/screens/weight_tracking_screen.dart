import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design/design.dart';
import '../../../../shared/widgets/soft_gradient_app_bar.dart';
import '../widgets/current_weight_summary_card.dart';
import '../widgets/weight_chart_card.dart';
import '../widgets/weight_records_card.dart';

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
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: const SoftGradientBackAppBar(title: '体重管理'),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 체중 요약 카드
            CurrentWeightSummaryCard(),
            SizedBox(height: AppSpacing.xl),

            // 체중 변화 차트 카드
            WeightChartCard(),
            SizedBox(height: AppSpacing.xl),

            // 체중 기록 목록
            WeightRecordsCard(),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 체중 기록 추가 다이얼로그 표시
          _showAddWeightDialog(context);
        },
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          '体重記録',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
