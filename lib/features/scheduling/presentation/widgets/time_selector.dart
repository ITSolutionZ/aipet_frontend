import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 시간 선택 위젯
class TimeSelector extends StatelessWidget {
  final String title;
  final TimeOfDay selectedTime;
  final VoidCallback onTimeTap;

  const TimeSelector({
    super.key,
    required this.title,
    required this.selectedTime,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: onTimeTap,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.pointGray),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.pointBrown),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      selectedTime.format(context),
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.pointGray,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
