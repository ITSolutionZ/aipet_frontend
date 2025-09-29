import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class PetSizeSelectionCard extends StatelessWidget {
  final String size;
  final String label;
  final String weightRange;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const PetSizeSelectionCard({
    super.key,
    required this.size,
    required this.label,
    required this.weightRange,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 100 : 80,
        height: isSelected ? 140 : 120,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointPink.withValues(alpha: 0.1)
              : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : AppColors.pointGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pointBrown.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.pointBrown
                    : AppColors.pointGray.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.pets,
                color: isSelected ? AppColors.pureWhite : AppColors.pointGray,
                size: 24,
              ),
            ),
            const const const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.pointBrown : AppColors.pointDark,
              ),
            ),
            const const const SizedBox(height: 4),
            Text(
              weightRange,
              style: AppFonts.bodySmall.copyWith(
                color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
