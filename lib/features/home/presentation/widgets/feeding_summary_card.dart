import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../../data/providers/home_providers.dart';
import 'common_summary_card.dart';

class FeedingSummaryCard extends ConsumerWidget {
  const FeedingSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 펫 정보 가져오기
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final currentPetId = selectedPet?.id ?? '1';

    // 선택된 펫에 따른 식사 데이터 가져오기
    final todayMeals = MockDataService.getMockTodayMeals(petId: currentPetId);
    final completedMeals = todayMeals
        .where((meal) => meal['status'] == 'completed')
        .length;
    final totalMeals = todayMeals.length;

    final nextMealInfo = MockDataService.getMockNextMealInfo(
      petId: currentPetId,
    );

    final feedingData = {
      'completedMeals': completedMeals,
      'totalMeals': totalMeals,
      'nextMeal': nextMealInfo['nextMeal'],
      'nextMealTime': nextMealInfo['nextMealTime'],
      'calories': MockDataService.getMockExpectedCalories(petId: currentPetId),
    };

    return CommonSummaryCard(
      icon: Icons.restaurant,
      iconColor: AppColors.pointBlue,
      mainValue: '${feedingData['completedMeals']}',
      unit: '/${feedingData['totalMeals']}',
      onTap: () =>
          context.go('${RouteConstants.feedingMainRoute}?showBackButton=true'),
      subtitle: '今日の食事',
    );
  }
}
