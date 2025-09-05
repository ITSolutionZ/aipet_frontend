import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes/route_constants.dart';
import '../../../../shared/shared.dart';
import '../../data/providers/home_providers.dart';
import 'common_summary_card.dart';

class AppointmentSummaryCard extends ConsumerWidget {
  const AppointmentSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 펫 정보 가져오기
    final selectedPet = ref.watch(homeSelectedPetNotifierProvider);
    final now = DateTime.now();

    // 펫 타입에 따라 다른 예약 수
    final upcomingCount = AppointmentMockData.getUpcomingCountByPetType(selectedPet?.type);
    final totalThisMonth = AppointmentMockData.getMonthlyCountByPetType(selectedPet?.type);

    final appointmentData = {
      'upcomingCount': upcomingCount,
      'nextAppointment': AppointmentMockData.getNextAppointmentTime(now),
      'nextType': HomeMockService.getMockNextAppointmentType(petId: selectedPet?.id),
      'totalThisMonth': totalThisMonth,
    };

    return CommonSummaryCard(
      icon: Icons.calendar_today,
      iconColor: AppColors.pointBrown,
      mainValue: '${appointmentData['upcomingCount']}',
      unit: '件',
      onTap: () => context.go(RouteConstants.todayAppointmentsRoute),
      secondaryValue: '今月: ${appointmentData['totalThisMonth']}件',
    );
  }

}
