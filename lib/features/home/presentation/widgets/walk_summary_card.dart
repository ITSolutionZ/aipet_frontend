import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';

class WalkSummaryCard extends ConsumerWidget {
  const WalkSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 선택된 펫에 따른 산책 데이터 가져오기
    final walkSummary = HomeMockService.getMockWalkSummary();

    final walkData = {
      'todayWalks': walkSummary['todayWalks'],
      'todayDistance': walkSummary['todayDistance'],
      'weeklyProgress':
          (walkSummary['weeklyProgress'] as double? ?? 0.0) /
          (walkSummary['weeklyGoal'] as double? ?? 1.0),
      'nextWalkTime': HomeMockService.getMockNextWalkTime(),
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
