import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 예약현황 카드 위젯
class ReservationStatusCard extends StatelessWidget {
  final VoidCallback? onTap;
  final int upcomingReservations;

  const ReservationStatusCard({
    super.key,
    this.onTap,
    this.upcomingReservations = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.pointGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: const Icon(
                    Icons.event_note,
                    color: AppColors.pointGreen,
                    size: 20,
                  ),
                ),
                if (upcomingReservations > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.pointRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$upcomingReservations',
                        style: AppFonts.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '予約状況',
              style: AppFonts.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
