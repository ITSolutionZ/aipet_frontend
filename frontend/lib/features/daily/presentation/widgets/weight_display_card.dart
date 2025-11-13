import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 몸무게 표시 카드 위젯
class WeightDisplayCard extends StatelessWidget {
  final double? weight;

  const WeightDisplayCard({super.key, this.weight});

  @override
  Widget build(BuildContext context) {
    final isNormal = weight != null && weight! >= 1.0 && weight! <= 50.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
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
      child: Row(
        children: [
          const Icon(
            Icons.monitor_weight,
            color: AppColors.pointBlue,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '体重',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: weight != null
                ? Text(
                    '${weight!.toStringAsFixed(1)}kg',
                    style: AppFonts.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                : Text(
                    '未記録',
                    style: AppFonts.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          _buildHealthIcons(isNormal),
        ],
      ),
    );
  }

  Widget _buildHealthIcons(bool isNormal) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isNormal
            ? AppColors.pointGreen.withValues(alpha: 0.1)
            : AppColors.pointOrange.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isNormal ? Icons.favorite : Icons.favorite_border,
        color: isNormal ? AppColors.pointGreen : AppColors.pointOrange,
        size: 24,
      ),
    );
  }
}
