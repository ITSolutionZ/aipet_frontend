import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 내원 내역 카드 위젯
class HospitalVisitHistoryCard extends StatelessWidget {
  final String petName;
  final bool hasVisitHistory;
  final VoidCallback? onManageHospital;
  final VoidCallback? onCheckReservation;

  const HospitalVisitHistoryCard({
    super.key,
    required this.petName,
    this.hasVisitHistory = false,
    this.onManageHospital,
    this.onCheckReservation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$petNameの受診履歴',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasVisitHistory ? '受診記録があります' : '登録された受診履歴がありません :(',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          if (!hasVisitHistory) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onManageHospital,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.pointBrown,
                      side: BorderSide(
                        color: AppColors.pointBrown.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                    ),
                    child: const Text('受診病院管理'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCheckReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pointBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                    ),
                    child: const Text('予約状況'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
