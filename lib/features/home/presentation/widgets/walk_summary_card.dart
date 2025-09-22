import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';

/// 🚶 산책 요약 카드
///
/// 오늘의 산책 거리와 주간 목표 진행률을 표시
class WalkSummaryCard extends HomeSummaryCardBase {
  const WalkSummaryCard({super.key});

  @override
  String get cardTitle => '散歩';

  @override
  IconData get cardIcon => Icons.directions_walk;

  @override
  Color get cardIconColor => AppColors.pointGreen;

  @override
  String get routePath => RouteConstants.walkFromHomeRoute;

  @override
  String? getValue(BuildContext context, WidgetRef ref) {
    final walkSummary = HomeMockService.getMockWalkSummary();
    final todayDistance = SummaryCardUtils.safeDouble(
      walkSummary['todayDistance'],
    );
    return SummaryCardUtils.formatDistance(todayDistance);
  }

  @override
  String? getUnit(BuildContext context, WidgetRef ref) => null; // getValue에서 이미 단위 포함

  @override
  String? getSubtitle(BuildContext context, WidgetRef ref) {
    final walkSummary = HomeMockService.getMockWalkSummary();
    final weeklyProgress = SummaryCardUtils.safeDouble(
      walkSummary['weeklyProgress'],
    );
    final weeklyGoal = SummaryCardUtils.safeDouble(walkSummary['weeklyGoal']);

    if (weeklyGoal > 0) {
      final progressPercentage = (weeklyProgress / weeklyGoal * 100).round();
      return '週間目標: $progressPercentage%';
    }
    return '週間目標進行中';
  }

  @override
  String? getSemanticLabel(BuildContext context, WidgetRef ref) {
    final walkSummary = HomeMockService.getMockWalkSummary();
    final todayDistance = SummaryCardUtils.safeDouble(
      walkSummary['todayDistance'],
    );
    final todayWalks = SummaryCardUtils.safeInt(walkSummary['todayWalks']);
    return '散歩状況: 今日$todayWalks回、${todayDistance}km';
  }
}
