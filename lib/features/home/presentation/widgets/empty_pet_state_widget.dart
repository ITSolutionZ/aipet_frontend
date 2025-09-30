import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 펫이 없는 상태 위젯
class EmptyPetStateWidget extends StatelessWidget {
  const EmptyPetStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'まだペットが登録されていません',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '最初のペットを登録して、\nAIPetを始めましょう！',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => context.push('/pet-type-selection'),
              child: const Text('ペット登録'),
            ),
          ],
        ),
      ),
    );
  }
}
