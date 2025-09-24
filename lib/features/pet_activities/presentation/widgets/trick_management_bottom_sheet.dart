import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 트릭 관리 바텀시트
class TrickManagementBottomSheet extends StatelessWidget {
  final VoidCallback onResetProgress;

  const TrickManagementBottomSheet({super.key, required this.onResetProgress});

  /// 바텀시트를 표시하는 정적 메서드
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onResetProgress,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return TrickManagementBottomSheet(onResetProgress: onResetProgress);
      },
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointDark.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  'トリック管理',
                  style: AppFonts.fredoka(
                    fontSize: AppFonts.lg,
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _MenuOptionListTile(
                  icon: Icons.edit,
                  title: 'トリックを編集',
                  subtitle: '学んだトリックを変更',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/edit-tricks');
                  },
                ),
                _MenuOptionListTile(
                  icon: Icons.delete_outline,
                  title: '進捗をリセット',
                  subtitle: 'すべてのトリック進捗をクリア',
                  onTap: () {
                    Navigator.pop(context);
                    onResetProgress();
                  },
                ),
                _MenuOptionListTile(
                  icon: Icons.analytics_outlined,
                  title: '統計を表示',
                  subtitle: '学習進整統計を確認',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/trick-statistics');
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 메뉴 옵션 리스트 타일
class _MenuOptionListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuOptionListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.pointBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: Icon(icon, color: AppColors.pointBlue, size: 24),
      ),
      title: Text(
        title,
        style: AppFonts.fredoka(
          fontSize: AppFonts.baseSize,
          color: AppColors.pointDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppFonts.bodySmall.copyWith(
          color: AppColors.pointDark.withValues(alpha: 0.7),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
    );
  }
}
