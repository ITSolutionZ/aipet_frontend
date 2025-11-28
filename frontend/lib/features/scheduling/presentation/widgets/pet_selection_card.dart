import 'package:aipet_frontend/features/pet_profile/presentation/widgets/tabs/helpers/pet_info_image_helper.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

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
            _buildPetAvatar(petInfo['imagePath']),
            const SizedBox(height: AppSpacing.xs),
            Text(
              petInfo['name'],
              style: AppFonts.bodySmall.copyWith(
                color: isSelected ? AppColors.pointBrown : AppColors.pointDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  /// 펫 아바타 위젯 - PetInfoImageHelper 사용 (백업 복원 지원)
  Widget _buildPetAvatar(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.pointGray.withValues(alpha: 0.2),
        child: Icon(
          Icons.pets,
          color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
          size: 25,
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: PetInfoImageHelper.buildImageWidget(imagePath),
    );
  }
}
