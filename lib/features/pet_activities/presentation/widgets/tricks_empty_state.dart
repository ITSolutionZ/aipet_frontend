import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 트릭이 없을 때의 빈 상태 위젯
class TricksEmptyState extends StatelessWidget {
  const TricksEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.pointDark.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'トリックが見つかりません',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '検索キーワードやフィルターを調整してください',
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointDark.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}