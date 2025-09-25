import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/features/home/data/providers/home_providers.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 📅 예약 요약 카드
///
/// 다가오는 예약 수와 이번 달 예약 현황을 표시
class AppointmentSummaryCard extends HomeSummaryCardBase {
  const AppointmentSummaryCard({super.key});

  @override
  String get cardTitle => '予約';

  @override
  IconData get cardIcon => Icons.calendar_today;

  @override
  Color get cardIconColor => AppColors.pointBrown;

  @override
  String get routePath => RouteConstants.todayAppointmentsRoute;

  @override
  String? getValue(BuildContext context, WidgetRef ref) {
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final upcomingCount = AppointmentMockData.getUpcomingCountByPetType(
      selectedPet?.type,
    );
    return upcomingCount.toString();
  }

  @override
  String? getUnit(BuildContext context, WidgetRef ref) => '件';

  @override
  String? getSubtitle(BuildContext context, WidgetRef ref) {
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final totalThisMonth = AppointmentMockData.getMonthlyCountByPetType(
      selectedPet?.type,
    );
    return '今月: $totalThisMonth件';
  }

  @override
  String? getSemanticLabel(BuildContext context, WidgetRef ref) {
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final upcomingCount = AppointmentMockData.getUpcomingCountByPetType(
      selectedPet?.type,
    );
    return '予約状況: 今後の予約$upcomingCount件';
  }
}
