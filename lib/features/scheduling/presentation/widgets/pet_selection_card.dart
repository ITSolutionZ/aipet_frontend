import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 펫 선택 카드 위젯
class PetSelectionCard extends StatelessWidget {
  final String petId;
  final Map<String, dynamic> petInfo;
  final bool isSelected;
  final List<String> selectedStatuses;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PetSelectionCard({
    super.key,
    required this.petId,
    required this.petInfo,
    required this.isSelected,
    required this.selectedStatuses,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : AppColors.pointGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(petInfo['imagePath']),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              petInfo['name'],
              style: AppFonts.bodySmall.copyWith(
                color: isSelected
                    ? AppColors.pointBrown
                    : AppColors.pointDark,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            Text(
              petInfo['size'],
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
                fontSize: AppFonts.xs,
              ),
            ),
            // 상태 표시
            if (selectedStatuses.isNotEmpty && isSelected)
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pointGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  '${selectedStatuses.length}/2',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGreen,
                    fontSize: AppFonts.xs,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}