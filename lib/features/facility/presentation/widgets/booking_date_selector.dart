import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/ui/components/cards/info_card.dart';
import 'package:flutter/material.dart';

/// 📅 예약 날짜 선택 위젯
///
/// 달력을 이용한 날짜 선택 기능을 제공
class BookingDateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? minimumDate;
  final DateTime? maximumDate;

  const BookingDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.minimumDate,
    this.maximumDate,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard.basic(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '日付を選択してください',
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedDate != null) ...[
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
                      '${selectedDate!.year}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 달력 위젯
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: CalendarDatePicker(
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: minimumDate ?? DateTime.now(),
              lastDate:
                  maximumDate ?? DateTime.now().add(const Duration(days: 90)),
              onDateChanged: onDateSelected,
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

/// 🗓️ 간소화된 날짜 선택기 (수평 스크롤)
///
/// 공간 절약을 위한 컴팩트한 날짜 선택기
class CompactDateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final int daysToShow;

  const CompactDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysToShow = 7,
  });

  List<DateTime> _generateDates() {
    final now = DateTime.now();
    return List.generate(daysToShow, (index) => now.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final dates = _generateDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            '날짜 선택',
            style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // 날짜 선택 칩들
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected =
                  selectedDate?.day == date.day &&
                  selectedDate?.month == date.month &&
                  selectedDate?.year == date.year;
              final isToday = _isToday(date);

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => onDateSelected(date),
                  child: Container(
                    width: 60,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBackgroundGray,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      border: isToday
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ['月', '火', '水', '木', '金', '土', '日'][date.weekday - 1],
                          style: AppFonts.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          date.day.toString(),
                          style: AppFonts.headlineSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
