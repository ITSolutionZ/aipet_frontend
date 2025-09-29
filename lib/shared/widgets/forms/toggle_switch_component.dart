import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 토글 스위치 컴포넌트
class ToggleSwitchComponent extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSwitchComponent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.pointBlue),
      title: Text(
        title,
        style: AppFonts.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.pointDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppFonts.bodyMedium.copyWith(
          color: AppColors.pointDark.withValues(alpha: 0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.pointBlue,
      ),
      contentPadding: const const const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
    );
  }
}
