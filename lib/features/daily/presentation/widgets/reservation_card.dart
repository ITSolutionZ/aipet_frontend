import 'package:aipet_frontend/features/daily/data/services/reservation_local_storage_service.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/cancel_reservation_modal.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 예약 카드 위젯
class ReservationCard extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.onTap,
    this.onCancel,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final status = reservation['status'] as String;
    final statusColor = ReservationLocalStorageService.getStatusColor(status);
    final statusIcon = ReservationLocalStorageService.getStatusIcon(status);
    final statusDisplayName =
        ReservationLocalStorageService.getStatusDisplayName(status);

    final scheduledDate = reservation['scheduledDate'] as DateTime;
    final scheduledTime = reservation['scheduledTime'] as String;
    final facilityName = reservation['facilityName'] as String;
    final serviceType = reservation['serviceType'] as String;
    final petName = reservation['petName'] as String;
    final notes = reservation['notes'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (상태 + 펫 이름)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        statusDisplayName,
                        style: AppFonts.bodyMedium.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      petName,
                      style: AppFonts.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // 시설 정보
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.toneDarkGray,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      facilityName,
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // 서비스 정보
              Row(
                children: [
                  const Icon(
                    Icons.medical_services,
                    color: AppColors.toneDarkGray,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(serviceType, style: AppFonts.bodyMedium),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // 예약 시간
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: AppColors.toneDarkGray,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_formatDate(scheduledDate)} $scheduledTime',
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // 메모가 있는 경우
              if (notes != null && notes.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.toneOffWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.note,
                        color: AppColors.toneDarkGray,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          notes,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.toneDarkGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 액션 버튼들 (상태에 따라)
              if (status == ReservationLocalStorageService.pending) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCancelModal(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        child: Text(
                          'キャンセル',
                          style: AppFonts.bodySmall.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pointBrown,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        child: Text(
                          '確認',
                          style: AppFonts.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CancelReservationModal(
        reservationId: reservation['id'] as String,
        facilityName: reservation['facilityName'] as String,
        onCancelConfirmed: (String reason, String detail) {
          // 예약 취소 확인 후 콜백 실행
          onCancel?.call();
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '今日';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      return '明日';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
