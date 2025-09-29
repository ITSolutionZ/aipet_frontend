import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class YearMonthSelectorWidget extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onMonthChanged;

  const YearMonthSelectorWidget({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.onYearChanged,
    required this.onMonthChanged,
  });

  List<int> _getYearList() {
    final currentYear = DateTime.now().year;
    return List.generate(30, (index) => currentYear - index);
  }

  List<int> _getMonthList() {
    return List.generate(12, (index) => index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 45,
          padding: const const const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _getYearList()
                  .map(
                    (year) => GestureDetector(
                      onTap: () => onYearChanged(year),
                      child: Container(
                        margin: const const const EdgeInsets.only(right: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: selectedYear == year ? 14 : 10,
                          vertical: selectedYear == year ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: selectedYear == year
                              ? AppColors.pointBrown
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            selectedYear == year ? 18 : 14,
                          ),
                        ),
                        child: Text(
                          '$year',
                          style:
                              (selectedYear == year
                                      ? AppFonts.bodyLarge
                                      : AppFonts.bodyMedium)
                                  .copyWith(
                                    color: selectedYear == year
                                        ? Colors.white
                                        : AppColors.pointGray,
                                    fontWeight: selectedYear == year
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const const const SizedBox(height: AppSpacing.sm),
        Container(
          height: 45,
          padding: const const const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _getMonthList()
                  .map(
                    (month) => GestureDetector(
                      onTap: () => onMonthChanged(month),
                      child: Container(
                        margin: const const const EdgeInsets.only(right: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: selectedMonth == month ? 14 : 10,
                          vertical: selectedMonth == month ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: selectedMonth == month
                              ? AppColors.pointBrown
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            selectedMonth == month ? 18 : 14,
                          ),
                        ),
                        child: Text(
                          '$month月',
                          style:
                              (selectedMonth == month
                                      ? AppFonts.bodyLarge
                                      : AppFonts.bodyMedium)
                                  .copyWith(
                                    color: selectedMonth == month
                                        ? Colors.white
                                        : AppColors.pointGray,
                                    fontWeight: selectedMonth == month
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
