import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
import 'meal_status_widget.dart';


class TodayMealsCard extends StatelessWidget {
  final List<Map<String, dynamic>> todayMeals;

  const TodayMealsCard({super.key, required this.todayMeals});

  /// DateTime을 시간 문자열로 변환
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateTimeUtils.formatTime(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
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
