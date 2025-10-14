import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 선택된 펫 정보 표시
class AllergySelectedPetInfo extends StatelessWidget {
  final PetProfileEntity selectedPet;

  const AllergySelectedPetInfo({super.key, required this.selectedPet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.pointBrown.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // 펫 이미지
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.pureWhite,
            backgroundImage: selectedPet.imagePath != null
                ? AssetImage(selectedPet.imagePath!)
                : const AssetImage('assets/icons/aipet_logo.png'),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${selectedPet.name}のアレルギー情報を検索中',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.pointBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
