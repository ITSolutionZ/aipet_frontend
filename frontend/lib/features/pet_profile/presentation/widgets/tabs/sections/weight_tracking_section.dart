import 'package:flutter/material.dart';

import '../../../../../../shared/shared.dart';

/// 체중 추적 섹션
///
/// Pet Health Tab에서 분리된 독립적인 위젯
/// 체중 정보를 표시합니다.
class WeightTrackingSection extends StatelessWidget {
  final PetProfileEntity pet;

  const WeightTrackingSection({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '体重管理',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.monitor_weight,
          iconColor: AppColors.pointBrown,
          iconBackgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
          title: '現在の体重',
          subtitle: '${pet.weight}kg • 理想体重: ${pet.weight + 0.5}kg',
          badge: '適正',
          badgeColor: AppColors.pointGreen,
        ),
      ],
    );
  }
}
