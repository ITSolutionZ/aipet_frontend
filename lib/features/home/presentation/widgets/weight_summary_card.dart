import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ⚖️ 체중 요약 카드
///
/// 현재 체중과 주간 변화량을 표시
class WeightSummaryCard extends HomeSummaryCardBase {
  const WeightSummaryCard({super.key});

  @override
  String get cardTitle => '体重';

  @override
  IconData get cardIcon => Icons.monitor_weight;

  @override
  Color get cardIconColor => AppColors.pointBrown;

  @override
  String get routePath => RouteConstants.weightTrackingRoute;

  @override
  String? getValue(BuildContext context, WidgetRef ref) {
    final weightRecords = PetHealthMockService.getMockWeightRecords();
    final currentWeight = weightRecords.isNotEmpty
        ? SummaryCardUtils.safeDouble(weightRecords.first['weight'], 5.0)
        : 5.0;
    return SummaryCardUtils.formatWeight(currentWeight);
  }

  @override
  String? getUnit(BuildContext context, WidgetRef ref) => null; // getValue에서 이미 단위 포함

  @override
  String? getSubtitle(BuildContext context, WidgetRef ref) {
    final weightRecords = PetHealthMockService.getMockWeightRecords();
    final currentWeight = weightRecords.isNotEmpty
        ? SummaryCardUtils.safeDouble(weightRecords.first['weight'], 5.0)
        : 5.0;
    final previousWeight = weightRecords.length > 1
        ? SummaryCardUtils.safeDouble(weightRecords[1]['weight'], currentWeight)
        : currentWeight;
    final weeklyChange = currentWeight - previousWeight;

    final changeText = SummaryCardUtils.formatChange(weeklyChange);
    return '週間変化: ${changeText}kg';
  }

  @override
  String? getSemanticLabel(BuildContext context, WidgetRef ref) {
    final weightRecords = PetHealthMockService.getMockWeightRecords();
    final currentWeight = weightRecords.isNotEmpty
        ? SummaryCardUtils.safeDouble(weightRecords.first['weight'], 5.0)
        : 5.0;
    return '現在の体重: ${currentWeight}kg';
  }
}
