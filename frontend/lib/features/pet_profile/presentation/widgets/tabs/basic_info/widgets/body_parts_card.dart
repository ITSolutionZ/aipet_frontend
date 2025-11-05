import 'package:flutter/material.dart';


import '../../../../../../../shared/shared.dart';
import '../constants/basic_info_constants.dart';


/// 신경쓰이는 신체 부위 카드 위젯
///
/// 펫의 관리가 필요한 신체 부위를 표시하는 카드
class BodyPartsCard extends StatelessWidget {
  final PetProfileEntity pet;

  const BodyPartsCard({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    // additionalInfo에서 bodyPartsToManage 가져오기
    String bodyParts = '';
    if (pet.additionalInfo != null &&
        pet.additionalInfo!['bodyPartsToManage'] != null) {
      bodyParts = pet.additionalInfo!['bodyPartsToManage'].toString();
    }

    final hasBodyParts = bodyParts.isNotEmpty;
    final bodyPartsList = bodyParts
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // 사용자가 작성한 신체부위가 없으면 표시하지 않음
    if (!hasBodyParts) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(BasicInfoConstants.cardBorderRadius),
        border: Border.all(
          color: AppColors.pointGreen.withValues(alpha: 0.3),
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
                  color: AppColors.pointGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColors.pointGreen,
                  size: BasicInfoConstants.iconSize,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  BasicInfoConstants.bodyPartsLabel,
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 사용자가 작성한 신체부위 칩 표시
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: bodyPartsList.map((part) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                  border: Border.all(
                    color: AppColors.pointGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  part,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
