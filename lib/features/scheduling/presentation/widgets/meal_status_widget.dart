import 'package:flutter/material.dart';

import '../../../../shared/design/design.dart';

class MealStatusWidget extends StatelessWidget {
  final String meal;
  final String time;
  final bool isCompleted;

  const MealStatusWidget({
    super.key,
    required this.meal,
    required this.time,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.pointGreen.withValues(alpha: 0.1)
            : AppColors.pointGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isCompleted ? AppColors.pointGreen : AppColors.pointGray,
        ),
      ),
      child: Column(
        children: [
          Text(
            meal,
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isCompleted ? AppColors.pointGreen : AppColors.pointGray,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            time,
            style: AppFonts.bodySmall.copyWith(
              color: isCompleted ? AppColors.pointGreen : AppColors.pointGray,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Icon(
            isCompleted ? Icons.check_circle : Icons.schedule,
            color: isCompleted ? AppColors.pointGreen : AppColors.pointGray,
            size: 20,
          ),
        ],
      ),
    );
  }
}