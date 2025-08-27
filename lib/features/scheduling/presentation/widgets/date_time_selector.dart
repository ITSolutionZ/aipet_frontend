import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 날짜/시간 선택 위젯
class DateTimeSelector extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const DateTimeSelector({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateTap,
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
              '日時設定',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 날짜 선택
            InkWell(
              onTap: onDateTap,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.pointGray),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.pointBrown,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
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

            const SizedBox(height: AppSpacing.md),

            // 시간 선택
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
                    const Icon(
                      Icons.access_time,
                      color: AppColors.pointBrown,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      selectedTime.format(context),
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.pointDark,
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