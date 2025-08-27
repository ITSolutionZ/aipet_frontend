import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 급여 가이드 카드 위젯
class FeedingGuideCard extends StatelessWidget {
  final Map<String, dynamic> petInfo;
  final Map<String, dynamic> sizeGuide;

  const FeedingGuideCard({
    super.key,
    required this.petInfo,
    required this.sizeGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(petInfo['imagePath']),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${petInfo['name']} (${petInfo['size']})',
                        style: AppFonts.titleSmall.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '推奨量: ${petInfo['recommendedAmount']}g',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.tonePeach.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: AppColors.tonePeach.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sizeGuide['description'],
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '適正範囲: ${sizeGuide['recommendedRange']}',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointBrown,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    sizeGuide['tips'],
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}