import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🍽️ 급여 요약 카드
///
/// 오늘의 급여 완료 현황과 다음 급여 시간을 표시
class FeedingSummaryCard extends HomeSummaryCardBase {
  const FeedingSummaryCard({super.key});

  @override
  String get cardTitle => '給餌';

  @override
  IconData get cardIcon => Icons.restaurant;

  @override
  Color get cardIconColor => AppColors.pointBlue;

  @override
  String get routePath =>
      '${RouteConstants.feedingMainRoute}?showBackButton=true';

  @override
  String? getValue(BuildContext context, WidgetRef ref) {
    final todayMealsSummary = HomeMockService.getMockTodayMealsSummary();
    final completedMeals = SummaryCardUtils.safeInt(
      todayMealsSummary['completedMeals'],
    );
    return completedMeals.toString();
  }

  @override
  String? getUnit(BuildContext context, WidgetRef ref) {
    final todayMealsSummary = HomeMockService.getMockTodayMealsSummary();
    final totalMeals = SummaryCardUtils.safeInt(
      todayMealsSummary['totalMeals'],
    );
    return '/$totalMeals';
  }

  @override
  String? getSubtitle(BuildContext context, WidgetRef ref) {
    final nextMealInfo = HomeMockService.getMockNextMealInfo();
    final nextMealType = SummaryCardUtils.safeString(
      nextMealInfo['type'],
      '次回の食事',
    );
    final nextMealTime = SummaryCardUtils.safeString(nextMealInfo['time'], '');

    if (nextMealTime.isNotEmpty) {
      return '$nextMealType: $nextMealTime';
    }
    return nextMealType;
  }

  @override
  String? getSemanticLabel(BuildContext context, WidgetRef ref) {
    final todayMealsSummary = HomeMockService.getMockTodayMealsSummary();
    final completedMeals = SummaryCardUtils.safeInt(
      todayMealsSummary['completedMeals'],
    );
    final totalMeals = SummaryCardUtils.safeInt(
      todayMealsSummary['totalMeals'],
    );
    return '給餌状況: $completedMeals回完了、$totalMeals回中';
  }
}
