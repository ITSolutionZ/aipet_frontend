import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class DateCard extends StatelessWidget {
  final String title;
  final DateTime? date;
  final IconData icon;
  final Color color;
  final String? age;

  const DateCard({
    super.key,
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
    this.age,
  });

  @override
  Widget build(BuildContext context) {
    final dateString = date != null
        ? '${date!.year}年${date!.month}月${date!.day}日'
        : '未設定';

    return Container(
      padding: const const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  dateString,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (age != null)
            Text(
              age!,
              style: AppFonts.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
