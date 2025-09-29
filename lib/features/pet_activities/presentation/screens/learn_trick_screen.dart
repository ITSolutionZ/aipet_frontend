import 'package:aipet_frontend/shared/shared.dart';
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
        padding: const EdgeInsets.all(AppSpacing.lg),
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
}
