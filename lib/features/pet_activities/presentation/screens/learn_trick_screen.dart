import 'package:aipet_frontend/shared/shared.dart';
import 'package:aipet_frontend/shared/widgets/all_tricks_categories_section.dart';
import 'package:aipet_frontend/shared/widgets/recommended_tricks_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 새로운 트릭 학습 화면
class LearnTrickScreen extends ConsumerWidget {
  const LearnTrickScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: SoftGradientBackAppBar(title: '新しいトリックを学ぶ'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 추천 트릭 섹션
            Center(child: Text('추천 트릭 섹션')),
            SizedBox(height: AppSpacing.xl),

            // 모든 트릭 카테고리
            Center(child: Text('모든 트릭 카테고리')),
          ],
        ),
      ),
    );
  }

  void _openTrickDetail(BuildContext context, String trickName) {
    // 트릭 상세 화면으로 이동 (구현 예정)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$trickName の詳細画面は実装予定です'),
        backgroundColor: AppColors.pointGreen,
      ),
    );
  }

  void _openCategoryDetail(BuildContext context, String categoryName) {
    // 카테고리 상세 화면으로 이동 (구현 예정)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$categoryName カテゴリは実装予定です'),
        backgroundColor: AppColors.pointBlue,
      ),
    );
  }
}
