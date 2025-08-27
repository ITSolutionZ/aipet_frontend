import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/walk_record_entity.dart';

class WalkRecordCardWidget extends StatelessWidget {
  final WalkRecordEntity walkRecord;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const WalkRecordCardWidget({
    super.key,
    required this.walkRecord,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.pointBrown.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                walkRecord.ownerAvatar ?? 'assets/images/placeholder.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 산책 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  walkRecord.fullDateTimeString,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    // 산책 아이콘
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.pointBrown.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_walk,
                        size: 16,
                        color: AppColors.pointBrown,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // 산책 제목
                    Expanded(
                      child: Text(
                        walkRecord.title,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 산책 통계 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                walkRecord.formattedDuration,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                walkRecord.formattedDistance,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
