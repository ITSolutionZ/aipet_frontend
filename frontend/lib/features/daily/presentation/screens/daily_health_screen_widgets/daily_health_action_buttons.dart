import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/daily/presentation/logic/daily_health_logic.dart';

/// Daily Health 화면 액션 버튼들
class DailyHealthActionButtons extends StatelessWidget {
  final DailyHealthLogic logic;

  const DailyHealthActionButtons({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => logic.navigateToHealthInput(context, null),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              '記録を追加',
              style: AppFonts.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => logic.navigateToHospitalSearch(context),
            icon: const Icon(Icons.local_hospital, color: AppColors.primary),
            label: Text(
              '病院を探す',
              style: AppFonts.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
