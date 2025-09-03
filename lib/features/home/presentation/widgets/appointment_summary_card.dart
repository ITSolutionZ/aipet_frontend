import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
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
    final upcomingCount = selectedPet?.type == 'dog'
        ? 3
        : selectedPet?.type == 'cat'
        ? 1
        : 2;
    final totalThisMonth = selectedPet?.type == 'dog'
        ? 6
        : selectedPet?.type == 'cat'
        ? 3
        : 5;

    final appointmentData = {
      'upcomingCount': upcomingCount,
      'nextAppointment': _getNextAppointmentTime(now),
      'nextType': MockDataService.getMockNextAppointmentType(petId: selectedPet?.id),
      'totalThisMonth': totalThisMonth,
    };

    return CommonSummaryCard(
      icon: Icons.calendar_today,
      iconColor: AppColors.pointBrown,
      mainValue: '${appointmentData['upcomingCount']}',
      unit: '件',
      onTap: () => context.go(RouteConstants.todayAppointmentsRoute),
      subtitle: '予定の予約',
      secondaryValue: '今月: ${appointmentData['totalThisMonth']}件',
    );
  }

  /// 다음 예약 시간을 계산하여 표시 형식으로 반환
  String _getNextAppointmentTime(DateTime now) {
    // Mock 데이터 - 실제로는 API에서 가져온 예약 데이터를 사용
    final mockAppointments = [
      DateTime(now.year, now.month, now.day, 14, 0), // 오늘 14:00
      DateTime(now.year, now.month, now.day, 16, 30), // 오늘 16:30
      DateTime(now.year, now.month, now.day + 1, 10, 0), // 내일 10:00
      DateTime(now.year, now.month, now.day + 2, 15, 0), // 모레 15:00
    ];

    // 현재 시간 이후의 가장 빠른 예약 찾기
    DateTime? nextAppointment;
    for (final appointment in mockAppointments) {
      if (appointment.isAfter(now)) {
        if (nextAppointment == null || appointment.isBefore(nextAppointment)) {
          nextAppointment = appointment;
        }
      }
    }

    if (nextAppointment == null) {
      return '予約なし';
    }

    // 오늘인지 내일인지 확인
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(
      nextAppointment.year,
      nextAppointment.month,
      nextAppointment.day,
    );

    if (appointmentDay.isAtSameMomentAs(today)) {
      // 오늘
      final hour = nextAppointment.hour.toString().padLeft(2, '0');
      final minute = nextAppointment.minute.toString().padLeft(2, '0');
      return '今日 $hour:$minute';
    } else if (appointmentDay.difference(today).inDays == 1) {
      // 내일
      final hour = nextAppointment.hour.toString().padLeft(2, '0');
      final minute = nextAppointment.minute.toString().padLeft(2, '0');
      return '明日 $hour:$minute';
    } else {
      // 그 이후
      final month = nextAppointment.month;
      final day = nextAppointment.day;
      final hour = nextAppointment.hour.toString().padLeft(2, '0');
      final minute = nextAppointment.minute.toString().padLeft(2, '0');
      return '$month/$day $hour:$minute';
    }
  }
}
