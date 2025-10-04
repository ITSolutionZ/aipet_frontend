import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 사료 정보 섹션
class PetFoodSection extends StatelessWidget {
  const PetFoodSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFoodItem('食べる餌', '教えてください'),
          const SizedBox(height: AppSpacing.md),
          _buildFoodItem('食べる栄養剤', '教えてください'),
          const SizedBox(height: AppSpacing.md),
          _buildFoodItem('食べるおやつ', '教えてください'),
        ],
      ),
    );
  }

  Widget _buildFoodItem(String title, String actionText) {
    return Row(
      children: [
        Text(
          title,
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          actionText,
          style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
      ],
    );
  }
}
