import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

/// アラーム繰り返しセレクター
///
/// 毎日アラームトグルと曜日選択を提供
class AlarmRepeatSelector extends StatelessWidget {
  final DateTime selectedDate;
  final bool isDailyAlarm;
  final List<int> selectedDays;
  final ValueChanged<bool> onDailyAlarmChanged;
  final ValueChanged<List<int>> onDaysChanged;

  const AlarmRepeatSelector({
    super.key,
    required this.selectedDate,
    required this.isDailyAlarm,
    required this.selectedDays,
    required this.onDailyAlarmChanged,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日付表示
          _buildDateDisplay(),
          const SizedBox(height: AppSpacing.md),
          // 毎日アラームトグル
          _buildDailyAlarmToggle(),
          const SizedBox(height: AppSpacing.md),
          // 曜日選択
          if (!isDailyAlarm) _buildDaySelection(),
        ],
      ),
    );
  }

  /// 日付表示
  Widget _buildDateDisplay() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 20, color: AppColors.pointPink),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${selectedDate.month}月${selectedDate.day}日(${_getWeekdayName(selectedDate.weekday)})',
          style: AppFonts.titleMedium,
        ),
      ],
    );
  }

  /// 毎日アラームトグル
  Widget _buildDailyAlarmToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDailyAlarm
            ? AppColors.pointPink.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isDailyAlarm
              ? AppColors.pointPink
              : AppColors.pointGray.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.today,
            size: 20,
            color: isDailyAlarm ? AppColors.pointPink : AppColors.pointGray,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '毎日繰り返す',
              style: AppFonts.bodyMedium.copyWith(
                color: isDailyAlarm ? AppColors.pointPink : AppColors.pointDark,
                fontWeight: isDailyAlarm ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: isDailyAlarm,
            onChanged: onDailyAlarmChanged,
            activeColor: AppColors.pointPink,
          ),
        ],
      ),
    );
  }

  /// 曜日選択UI
  Widget _buildDaySelection() {
    const days = ['日', '月', '火', '水', '木', '金', '土'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isSelected = selectedDays.contains(index);

        return GestureDetector(
          onTap: () {
            final newDays = List<int>.from(selectedDays);
            if (isSelected) {
              newDays.remove(index);
            } else {
              newDays.add(index);
            }
            onDaysChanged(newDays);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.pointPink
                  : AppColors.pointGray.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.pointGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 曜日名取得
  String _getWeekdayName(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[(weekday - 1) % 7];
  }
}
