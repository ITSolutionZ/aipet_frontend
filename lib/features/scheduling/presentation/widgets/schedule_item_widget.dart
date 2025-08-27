import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/design/design.dart';

class ScheduleItemWidget extends StatelessWidget {
  final String meal;
  final String time;
  final String amount;

  const ScheduleItemWidget({
    super.key,
    required this.meal,
    required this.time,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.pointBrown.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.restaurant,
            color: AppColors.pointBrown,
            size: 20,
          ),
        ),
        title: Text(
          meal,
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.pointDark,
          ),
        ),
        subtitle: Text(
          '$time • $amount',
          style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
        ),
        trailing: IconButton(
          onPressed: () {
            context.go(
              '${AppRouter.feedingScheduleEditRoute}?mealType=${Uri.encodeComponent(meal)}&time=${Uri.encodeComponent(time)}&amount=${Uri.encodeComponent(amount)}&petId=${Uri.encodeComponent('1')}',
            );
          },
          icon: const Icon(Icons.edit, color: AppColors.pointGray),
        ),
      ),
    );
  }
}
