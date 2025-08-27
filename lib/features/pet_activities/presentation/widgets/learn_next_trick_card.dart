import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/trick_entity.dart';

/// 다음에 배울 트릭 카드 위젯
///
/// 펫이 다음에 배울 수 있는 트릭을 보여줍니다.
class LearnNextTrickCard extends StatelessWidget {
  final TrickEntity trick;

  const LearnNextTrickCard({super.key, required this.trick});

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
          // 트릭 썸네일 (비디오인 경우 플레이 아이콘 오버레이)
          Stack(
            children: [
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  image: DecorationImage(
                    image: AssetImage(trick.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (trick.isVideo)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
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

                // 난이도와 소요 시간
                Row(
                  children: [
                    // 난이도 배지
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(trick.difficulty),
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                      ),
                      child: Text(
                        _getDifficultyText(trick.difficulty),
                        style: AppFonts.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // 소요 시간
                    if (trick.duration != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.pointDark.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            trick.duration!,
                            style: AppFonts.bodySmall.copyWith(
                              color: AppColors.pointDark.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // 트릭 설명
                if (trick.description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    trick.description!,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointDark.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 화살표 아이콘
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.pointDark,
            size: 16,
          ),
        ],
      ),
    );
  }

  /// 난이도에 따른 색상 반환
  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return AppColors.pointGreen;
      case 'medium':
      case 'intermediate':
        return AppColors.pointBrown;
      case 'hard':
      case 'advanced':
        return AppColors.pointBlue;
      default:
        return AppColors.pointBrown;
    }
  }

  /// 난이도 텍스트 반환
  String _getDifficultyText(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
      case 'beginner':
        return 'Beginner';
      case 'medium':
      case 'intermediate':
        return 'Intermediate';
      case 'hard':
      case 'advanced':
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }
}
