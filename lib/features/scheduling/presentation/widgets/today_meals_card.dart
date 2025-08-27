import 'package:flutter/material.dart';

import '../../../../shared/design/design.dart';
import 'meal_status_widget.dart';

class TodayMealsCard extends StatelessWidget {
  final List<Map<String, dynamic>> todayMeals;

  const TodayMealsCard({
    super.key,
    required this.todayMeals,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
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
                      meal: todayMeals[i]['mealType'],
                      time: todayMeals[i]['time'],
                      isCompleted: todayMeals[i]['status'] == 'completed',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}