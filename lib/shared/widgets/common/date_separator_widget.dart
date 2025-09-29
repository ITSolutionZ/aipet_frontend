import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class DateSeparatorWidget extends StatelessWidget {
  final DateTime date;
  final EdgeInsets? margin;

  const DateSeparatorWidget({super.key, required this.date, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.pointGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            child: Text(
              _formatDate(date),
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate.isAtSameMomentAs(today)) {
      return '今日';
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      return '昨日';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}
