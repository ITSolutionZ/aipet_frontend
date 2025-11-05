import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
/// 알레르기 제품 탭 (empty state)
class AllergyProductsEmptyTab extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const AllergyProductsEmptyTab({
    super.key,
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }
}

/// 메인 탭 버튼
class AllergyMainTabButton extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const AllergyMainTabButton({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.3))
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : AppColors.pointGray,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                '$label ($count)',
                style: AppFonts.bodyMedium.copyWith(
                  color: isSelected ? color : AppColors.pointGray,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
