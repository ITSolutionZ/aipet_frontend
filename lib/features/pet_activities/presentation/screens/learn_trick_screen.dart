import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../widgets/all_tricks_categories_section.dart';
import '../widgets/recommended_tricks_section.dart';

/// 새로운 트릭 학습 화면
class LearnTrickScreen extends ConsumerStatefulWidget {
  const LearnTrickScreen({super.key});

  @override
  ConsumerState<LearnTrickScreen> createState() => _LearnTrickScreenState();
}

class _LearnTrickScreenState extends ConsumerState<LearnTrickScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: const SoftGradientBackAppBar(title: '新しいトリックを学ぶ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 추천 트릭 섹션
            RecommendedTricksSection(
              onTrickTap: _openTrickDetail,
            ),
            const SizedBox(height: AppSpacing.xl),

            // 모든 트릭 카테고리
            AllTricksCategoriesSection(
              onCategoryTap: _openCategoryDetail,
            ),
          ],
        ),
      ),
    );
  }





  void _openTrickDetail(String trickName) {
    // 트릭 상세 화면으로 이동 (구현 예정)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$trickName の詳細画面は実装予定です'),
        backgroundColor: AppColors.pointGreen,
      ),
    );
  }

  void _openCategoryDetail(String categoryName) {
    // 카테고리 상세 화면으로 이동 (구현 예정)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$categoryName カテゴリは実装予定です'),
        backgroundColor: AppColors.pointBlue,
      ),
    );
  }
}
