import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../constants/basic_info_constants.dart';

/// 외견 정보 카드 위젯
///
/// 펫의 외견 특징을 표시하는 카드
class AppearanceCard extends StatelessWidget {
  final PetProfileEntity pet;

  const AppearanceCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    // additionalInfo에서 appearance 가져오기
    String appearance = '';
    if (pet.additionalInfo != null &&
        pet.additionalInfo!['appearance'] != null) {
      appearance = pet.additionalInfo!['appearance'].toString();
    }

    final hasAppearance = appearance.isNotEmpty;

    if (!hasAppearance) {
      // 외견 정보가 없으면 표시하지 않음
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(BasicInfoConstants.cardBorderRadius),
        border: Border.all(
          color: AppColors.pointBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.pointBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.pointBlue,
                  size: BasicInfoConstants.iconSize,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  BasicInfoConstants.appearanceLabel,
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 외견 정보 표시
          Text(
            appearance,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
