import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';


/// ⏰ 예약 시간 선택 위젯
///
/// 이용 가능한 시간대를 그리드로 표시하여 선택할 수 있는 위젯
class BookingTimeSelector extends StatelessWidget {
  final List<String> timeSlots;
  final String? selectedTime;
  final ValueChanged<String> onTimeSelected;
  final List<String> unavailableSlots;

  const BookingTimeSelector({
    super.key,
    required this.timeSlots,
    required this.selectedTime,
    required this.onTimeSelected,
    this.unavailableSlots = const [],
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard.basic(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '時間選択',
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedTime != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Text(
                      selectedTime!,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 시간대 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.5,
              ),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = timeSlots[index];
                final isSelected = selectedTime == timeSlot;
                final isUnavailable = unavailableSlots.contains(timeSlot);

                return BookingTimeChip(
                  time: timeSlot,
                  isSelected: isSelected,
                  isUnavailable: isUnavailable,
                  onTap: isUnavailable ? null : () => onTimeSelected(timeSlot),
                );
              },
            ),

            // 범례
            const SizedBox(height: AppSpacing.md),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        const _LegendItem(color: AppColors.primary, label: '選択済み'),
        const SizedBox(width: AppSpacing.md),
        const _LegendItem(color: AppColors.cardBackgroundGray, label: '利用可能'),
        const SizedBox(width: AppSpacing.md),
        _LegendItem(
          color: AppColors.error.withValues(alpha: 0.2),
          label: '予約不可',
        ),
      ],
    );
  }
}

/// 📋 시간대 선택 칩
class BookingTimeChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool isUnavailable;
  final VoidCallback? onTap;

  const BookingTimeChip({
    super.key,
    required this.time,
    required this.isSelected,
    required this.isUnavailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isUnavailable) {
      backgroundColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
      borderColor = AppColors.error.withValues(alpha: 0.3);
    } else if (isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else {
      backgroundColor = AppColors.cardBackgroundGray;
      textColor = AppColors.textPrimary;
      borderColor = AppColors.borderGray;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                time,
                style: AppFonts.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isUnavailable)
              const Positioned(
                top: 2,
                right: 2,
                child: Icon(Icons.block, size: 12, color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }
}

/// 🏷️ 범례 아이템
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
