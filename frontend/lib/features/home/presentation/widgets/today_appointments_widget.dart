import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../domain/domain.dart';
import 'appointment_card_widget.dart';

/// 오늘의 예약 위젯
class TodayAppointmentsWidget extends StatelessWidget {
  final List<AppointmentSummary> appointments;
  final Function(AppointmentSummary)? onAppointmentTap;
  final Function(AppointmentSummary)? onAppointmentComplete;

  const TodayAppointmentsWidget({
    super.key,
    required this.appointments,
    this.onAppointmentTap,
    this.onAppointmentComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          ...appointments.map(
            (appointment) => AppointmentCardWidget(
              appointment: appointment,
              onTap: () => onAppointmentTap?.call(appointment),
              onComplete: () => onAppointmentComplete?.call(appointment),
            ),
          ),
        ],
      ),
    );
  }
}
