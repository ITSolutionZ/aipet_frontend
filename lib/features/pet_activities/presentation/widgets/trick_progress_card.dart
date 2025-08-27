import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/trick_entity.dart';

/// 트릭 진행도 카드 위젯
///
/// 펫이 배운 트릭의 진행도와 완료 상태를 보여줍니다.
class TrickProgressCard extends StatelessWidget {
  final TrickEntity trick;

  const TrickProgressCard({super.key, required this.trick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 트릭 이미지
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              image: DecorationImage(
                image: AssetImage(trick.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 트릭 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trick.name,
                  style: AppFonts.fredoka(
                    fontSize: AppFonts.lg,
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // 진행도 바
                LinearProgressIndicator(
                  value: trick.progressPercentage,
                  backgroundColor: AppColors.toneOffWhite,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    trick.isCompleted
                        ? AppColors.pointGreen
                        : AppColors.pointBlue,
                  ),
                  minHeight: 6,
                ),
                const SizedBox(height: AppSpacing.xs),

                // 진행도 텍스트와 날짜
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${trick.progress ?? 0}%',
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (trick.date != null)
                      Text(
                        _formatDate(trick.date!),
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.pointDark.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 완료 상태 아이콘
          if (trick.isCompleted)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: const BoxDecoration(
                color: AppColors.pointGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }

  /// 날짜를 DD.MM.YY 형식으로 포맷
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    return '$day.$month.$year';
  }
}
