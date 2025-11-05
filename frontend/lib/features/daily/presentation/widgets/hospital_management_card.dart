import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 내원 병원 관리 카드 위젯
class HospitalManagementCard extends StatelessWidget {
  final VoidCallback? onTap;

  const HospitalManagementCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.pointBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: AppColors.pointBlue,
                size: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '受診病院管理',
              style: AppFonts.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
