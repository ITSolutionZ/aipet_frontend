import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../../data/providers/home_providers.dart';
import 'common_summary_card.dart';

class WeightSummaryCard extends ConsumerWidget {
  const WeightSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 펫 정보 가져오기
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final currentPetId = selectedPet?.id ?? '1';

    // 선택된 펫에 따른 체중 데이터 가져오기
    final weightRecords = MockDataService.getMockWeightRecords(
      petId: currentPetId,
    );

    final currentWeight = weightRecords.isNotEmpty
        ? weightRecords.first.weight
        : 5.0;
    final previousWeight = weightRecords.length > 1
        ? weightRecords[1].weight
        : currentWeight;
    final weeklyChange = currentWeight - previousWeight;

    final weightData = {
      'currentWeight': currentWeight,
      'targetWeight': currentWeight * 0.95, // 목표 체중을 현재 체중의 95%로 설정
      'weeklyChange': weeklyChange,
      'lastMeasurement': '昨日',
    };

    return CommonSummaryCard(
      icon: Icons.monitor_weight,
      iconColor: AppColors.pointBrown,
      mainValue: '${weightData['currentWeight']}',
      unit: 'kg',
      onTap: () => context.go(RouteConstants.weightTrackingRoute),
      subtitle: '現在の体重',
      secondaryValue:
          '${(weightData['weeklyChange'] as double) >= 0 ? '+' : ''}${(weightData['weeklyChange'] as double).toStringAsFixed(1)}kg',
    );
  }
}
