import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../../data/providers/home_providers.dart';
import 'common_summary_card.dart';

class WalkSummaryCard extends ConsumerWidget {
  const WalkSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 펫 정보 가져오기
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final currentPetId = selectedPet?.id ?? '1';

    // 선택된 펫에 따른 산책 데이터 가져오기
    final walkSummary = HomeMockService.getMockWalkSummary(petId: currentPetId);

    final walkData = {
      'todayWalks': walkSummary['todayWalks'],
      'todayDistance': walkSummary['todayDistance'],
      'weeklyProgress': (walkSummary['weeklyProgress'] as double? ?? 0.0) / (walkSummary['weeklyGoal'] as double? ?? 1.0),
      'nextWalkTime': HomeMockService.getMockNextWalkTime(petId: currentPetId),
    };

    return CommonSummaryCard(
      icon: Icons.directions_walk,
      iconColor: AppColors.pointGreen,
      mainValue: '${walkData['todayDistance']}',
      unit: 'km',
      onTap: () => context.go(RouteConstants.walkFromHomeRoute),
    );
  }
}
