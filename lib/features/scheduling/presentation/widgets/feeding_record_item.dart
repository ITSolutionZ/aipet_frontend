import 'package:flutter/material.dart';

import '../../../../shared/design/design.dart';

class FeedingRecordItem extends StatelessWidget {
  final dynamic record;

  const FeedingRecordItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.pointGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.restaurant,
            color: AppColors.pointGreen,
            size: 25,
          ),
        ),
        title: Text(
          '${record.petName}の食事',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.foodType} • ${record.foodBrand}',
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
            Text(
              '${record.amount}g • ${_formatTime(record.fedTime)}',
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: record.status == 'completed'
                ? AppColors.pointGreen.withValues(alpha: 0.1)
                : AppColors.pointGray.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Text(
            record.status == 'completed' ? '完了' : '未完了',
            style: AppFonts.bodySmall.copyWith(
              color: record.status == 'completed'
                  ? AppColors.pointGreen
                  : AppColors.pointGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
