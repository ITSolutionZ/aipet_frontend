import 'package:flutter/material.dart';


import '../../../../../../shared/shared.dart';
/// 日時選択セクション
class DateTimeSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final VoidCallback onTap;

  const DateTimeSelector({
    super.key,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.pointGreen),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '予約日時',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDateTime(),
                    style: AppFonts.bodyMedium.copyWith(
                      color: selectedDate != null
                          ? Colors.black87
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _formatDateTime() {
    if (selectedDate != null && selectedTimeSlot != null) {
      return '${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日 $selectedTimeSlot';
    } else if (selectedDate != null) {
      return '${selectedDate!.year}年${selectedDate!.month}月${selectedDate!.day}日';
    } else {
      return '日時を選択してください';
    }
  }
}
