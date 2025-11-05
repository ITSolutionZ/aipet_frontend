import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 병원관리 및 예약상황 통합 카드 위젯
class HospitalReservationCard extends StatelessWidget {
  final VoidCallback? onHospitalManagementTap;
  final VoidCallback? onReservationStatusTap;
  final int upcomingReservations;

  const HospitalReservationCard({
    super.key,
    this.onHospitalManagementTap,
    this.onReservationStatusTap,
    this.upcomingReservations = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: Row(
        children: [
          // 병원관리 섹션
          Expanded(
            child: InkWell(
              onTap: onHospitalManagementTap,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.pointBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: AppColors.pointBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '受診病院管理',
                      style: AppFonts.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 구분선
          Container(width: 1, height: 40, color: AppColors.backgroundGray),
          // 예약상황 섹션
          Expanded(
            child: InkWell(
              onTap: onReservationStatusTap,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
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
            ),
          ),
        ],
      ),
    );
  }
}
