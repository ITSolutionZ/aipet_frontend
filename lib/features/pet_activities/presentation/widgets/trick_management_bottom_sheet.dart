import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 트릭 관리 바텀 시트
class TrickManagementBottomSheet extends StatelessWidget {
  final VoidCallback onResetProgress;

  const TrickManagementBottomSheet({super.key, required this.onResetProgress});

  static void show(
    BuildContext context, {
    required VoidCallback onResetProgress,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TrickManagementBottomSheet(onResetProgress: onResetProgress),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.lg),
          topRight: Radius.circular(AppSpacing.lg),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 제목
              Text(
                'トリック管理',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 메뉴 항목들
              _buildMenuItem(
                icon: Icons.refresh,
                title: '進捗をリセット',
                subtitle: 'すべてのトリックの進捗をリセットします',
                onTap: () {
                  Navigator.pop(context);
                  onResetProgress();
                },
                color: AppColors.pointBrown,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'ヘルプ',
                subtitle: 'トリックの使い方について',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 헬프 화면으로 이동
                },
                color: AppColors.pointBlue,
              ),
              const SizedBox(height: AppSpacing.md),

              _buildMenuItem(
                icon: Icons.settings,
                title: '設定',
                subtitle: 'トリックの設定を変更',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 설정 화면으로 이동
                },
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 취소 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
