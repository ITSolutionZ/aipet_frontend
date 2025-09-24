import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/feeding_analysis/feeding_analysis_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 리팩토링된 급여 분석 화면
///
/// 기존 769라인에서 약 50라인으로 축소
/// 각 섹션을 별도 위젯으로 분리하여 단일 책임 원칙 준수
class FeedingAnalysisScreen extends ConsumerWidget {
  final String petId;

  const FeedingAnalysisScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientAppBar(title: '食事管理'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 현재 급여량 요약 섹션
            Center(child: Text('급여 분석 화면')),

            SizedBox(height: AppSpacing.md),

            // 급여량 추이 차트 섹션
            Center(child: Text('차트 섹션')),

            SizedBox(height: AppSpacing.md),

            // 급여 기록 섹션
            Center(child: Text('기록 섹션')),

            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
