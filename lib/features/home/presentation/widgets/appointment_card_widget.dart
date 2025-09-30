import 'package:aipet_frontend/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 예약 카드 위젯
class AppointmentCardWidget extends StatelessWidget {
  final AppointmentSummary appointment;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const AppointmentCardWidget({
    super.key,
    required this.appointment,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(appointment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.pointGreen,
        child: const Icon(Icons.check, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        // 완료 처리 확인
        return showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('予約完了'),
              content: const Text('この予約を完了としてマークしますか？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('完了'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onComplete?.call();
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(color: AppColors.pureWhite),
          child: Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      appointment.petName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${appointment.scheduledTime.hour}:${appointment.scheduledTime.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
