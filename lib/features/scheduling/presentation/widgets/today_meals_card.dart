import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import 'meal_status_widget.dart';

class TodayMealsCard extends CommonCard {
  final List<Map<String, dynamic>> todayMeals;

  const TodayMealsCard({super.key, required this.todayMeals});

  /// DateTime을 시간 문자열로 변환
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日の食事',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            for (int i = 0; i < todayMeals.length; i++)
              Expanded(
                child: MealStatusWidget(
                  meal: todayMeals[i]['scheduleName'] ?? 'Unknown',
                  time: _formatTime(todayMeals[i]['scheduledTime']),
                  isCompleted: todayMeals[i]['isCompleted'] ?? false,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
