import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 트릭이 없을 때 표시되는 빈 상태 위젯
class TricksEmptyState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRefresh;

  const TricksEmptyState({super.key, this.message, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 빈 상태 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.pointBrown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(Icons.pets, size: 60, color: AppColors.pointBrown),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 메시지
            Text(
              message ?? 'トリックが見つかりません',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              '新しいトリックを探してみましょう',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // 새로고침 버튼
            if (onRefresh != null)
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointGreen,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
