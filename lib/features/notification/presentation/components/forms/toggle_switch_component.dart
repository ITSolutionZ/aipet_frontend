import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 순수 UI 전용 토글 스위치 위젯
class ToggleSwitchUI extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSwitchUI({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            margin: const const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pointBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(icon, color: AppColors.pointBrown, size: 24),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.pointDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.pointBrown,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: AppColors.pointGray.withValues(alpha: 0.3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
