import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 펫이 없을 때 표시하는 빈 상태 위젯
class PetEmptyState extends StatelessWidget {
  const PetEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pet/register'),
      child: WhiteCard.panel(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              size: 60,
              color: AppColors.pointBrown,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'ペットを登録してください',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBrown,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'タップして最初のペットを追加',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}