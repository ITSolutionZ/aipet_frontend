import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';

class FeedingSummaryCard extends ConsumerWidget {
  const FeedingSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 선택된 펫에 따른 식사 데이터 가져오기
    final todayMeals = HomeMockService.getMockTodayMeals();
    final completedMeals = todayMeals['completedMeals'] as int;
    final totalMeals = todayMeals['totalMeals'] as int;

    final nextMealInfo = HomeMockService.getMockNextMealInfo();

    final feedingData = {
      'completedMeals': completedMeals,
      'totalMeals': totalMeals,
      'nextMeal': nextMealInfo['type'],
      'nextMealTime': nextMealInfo['time'],
      'calories': HomeMockService.getMockExpectedCalories(),
    };

    return CommonSummaryCard(
      icon: Icons.restaurant,
      iconColor: AppColors.pointBlue,
      mainValue: '${feedingData['completedMeals']}',
      unit: '/${feedingData['totalMeals']}',
      onTap: () =>
          context.go('${RouteConstants.feedingMainRoute}?showBackButton=true'),
    );
  }
}
