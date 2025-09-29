import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class CustomCalendarWidget extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomCalendarWidget({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    this.selectedDate,
    required this.onDateSelected,
  });

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(selectedYear, selectedMonth);
    final firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday;

    final startOffset = weekdayOfFirstDay == 7 ? 0 : weekdayOfFirstDay;

    return Column(
      children: [
        Container(
          padding: const const const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['月', '火', '水', '木', '金', '土', '日']
                .map(
                  (day) => Text(
                    day,
                    style: AppFonts.bodySmall.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final dayIndex = index - startOffset + 1;

            if (index < startOffset || dayIndex > daysInMonth) {
              if (index < startOffset) {
                final prevMonth = selectedMonth == 1 ? 12 : selectedMonth - 1;
                final prevYear = selectedMonth == 1
                    ? selectedYear - 1
                    : selectedYear;
                final prevMonthDays = _getDaysInMonth(prevYear, prevMonth);
                final prevDay = prevMonthDays - (startOffset - index - 1);

                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    '$prevDay',
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                );
              } else {
                final nextDay = dayIndex - daysInMonth;
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    '$nextDay',
                    style: AppFonts.bodyMedium.copyWith(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                );
              }
            }

            final isSelected =
                selectedDate != null &&
                selectedDate!.year == selectedYear &&
                selectedDate!.month == selectedMonth &&
                selectedDate!.day == dayIndex;

            return GestureDetector(
              onTap: () {
                final newDate = DateTime(selectedYear, selectedMonth, dayIndex);
                onDateSelected(newDate);
              },
              child: Container(
                alignment: Alignment.center,
                margin: const const const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.pointPink.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? Border.all(color: AppColors.pointBrown, width: 2)
                      : null,
                ),
                child: Text(
                  '$dayIndex',
                  style: AppFonts.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.pointBrown
                        : AppColors.pointDark,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
