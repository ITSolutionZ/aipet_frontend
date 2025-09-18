import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

class AnniversarySelectionCard extends StatelessWidget {
  final String type;
  final String title;
  final IconData icon;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final Widget? badge;

  const AnniversarySelectionCard({
    super.key,
    required this.type,
    required this.title,
    required this.icon,
    required this.selectedDate,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: AppColors.pointGray.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.pointDark.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: AppColors.pointBrown, size: 20),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.titleMedium.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日'
                        : '日付を選択してください',
                    style: AppFonts.bodyMedium.copyWith(
                      color: selectedDate != null
                          ? AppColors.pointDark
                          : AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null) badge!,
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.pointGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
