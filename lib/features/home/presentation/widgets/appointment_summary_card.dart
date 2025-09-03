import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/shared.dart';
import '../../../../app/router/routes/route_constants.dart';
import '../../data/providers/home_providers.dart';

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
      'nextType': '健康診断',
      'totalThisMonth': totalThisMonth,
    };

    return GestureDetector(
      onTap: () => context.go(RouteConstants.todayAppointmentsRoute),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppSpacing.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 원형 아이콘
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.pointBrown.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: AppColors.pointBrown.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: AppColors.pointBrown,
                size: 24,
              ),
            ),

            const SizedBox(height: 12),

            // 메인 수치와 단위
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${appointmentData['upcomingCount']}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '件',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.pointGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
