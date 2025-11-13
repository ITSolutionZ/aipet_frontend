import 'package:aipet_frontend/app/router/routes/route_constants.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 산책 요약 위젯
class WalkSummaryWidget extends StatelessWidget {
  final int totalMinutes;
  final bool isWeeklyRecord; // 이번주 최장 기록 여부

  const WalkSummaryWidget({
    super.key,
    required this.totalMinutes,
    this.isWeeklyRecord = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_walk, color: AppColors.primary, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 이번주 최장 기록일 때 랭킹 스타 표시
                    if (isWeeklyRecord) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Image.asset(
                        'assets/icons/common/ranking-star.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
                Text(
                  '$totalMinutes分',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go(RouteConstants.walkCalendarRoute),
            child: const Text('詳細', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
