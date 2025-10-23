import 'package:aipet_frontend/features/walk/domain/entities/walk_record_entity.dart';
import 'package:aipet_frontend/shared/core/utils/date_time_utils.dart';
import 'package:aipet_frontend/shared/ui.dart';
import 'package:flutter/material.dart';

/// 산책 상세 정보 카드 위젯
class WalkDetailInfoCard extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final VoidCallback? onEdit;

  const WalkDetailInfoCard({super.key, required this.walkRecord, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildTimeRow(),
          const SizedBox(height: AppSpacing.md),
          _buildDistanceRow(),
          if (walkRecord.route.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              'ルートポイント',
              '${walkRecord.route.length}箇所',
              Icons.location_on,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow() {
    final endTimeString = walkRecord.endTime != null
        ? DateTimeUtils.formatTime(walkRecord.endTime!)
        : '進行中';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: const Icon(
            Icons.access_time,
            size: 16,
            color: AppColors.pointBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '開始時間',
                      style: AppFonts.base(
                        fontSize: AppFonts.sm,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      walkRecord.timeString,
                      style: AppFonts.fredoka(
                        fontSize: AppFonts.lg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.pointBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.pointBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '完了時間',
                            style: AppFonts.base(
                              fontSize: AppFonts.sm,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            endTimeString,
                            style: AppFonts.fredoka(
                              fontSize: AppFonts.lg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: const Icon(
            Icons.route_rounded,
            size: 16,
            color: AppColors.pointBlue,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '総距離',
                      style: AppFonts.base(
                        fontSize: AppFonts.sm,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      walkRecord.formattedDistance,
                      style: AppFonts.fredoka(
                        fontSize: AppFonts.lg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.pointBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Icon(
                        Icons.timer,
                        size: 14,
                        color: AppColors.pointBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '経過時間',
                            style: AppFonts.base(
                              fontSize: AppFonts.sm,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            walkRecord.formattedDuration,
                            style: AppFonts.fredoka(
                              fontSize: AppFonts.lg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.pointBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Icon(icon, size: 16, color: AppColors.pointBlue),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppFonts.base(
                  fontSize: AppFonts.sm,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: AppFonts.fredoka(
                  fontSize: AppFonts.lg,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
