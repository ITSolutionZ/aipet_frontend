import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 通知空状態ウィジェット
///
/// 通知がない場合の表示
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.pointGray,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '通知がありません',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '新しい通知が届くとここに表示されます',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }
}

/// 通知エラー状態ウィジェット
///
/// エラーが発生した場合の表示
class NotificationErrorState extends StatelessWidget {
  final Object error;

  const NotificationErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.pointGray),
          const SizedBox(height: AppSpacing.md),
          Text(
            'エラーが発生しました',
            style: AppFonts.titleMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '通知の読み込みに失敗しました',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
        ],
      ),
    );
  }
}

/// さらに読み込みボタンウィジェット
class NotificationLoadMoreButton extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationLoadMoreButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '1件以上表示',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.pointBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
