import 'package:flutter/material.dart';

/// 설정 타일 위젯
class SettingsTileWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final Color? tileColor;
  final EdgeInsetsGeometry? contentPadding;

  const SettingsTileWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.tileColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(color: enabled ? null : Colors.grey.shade500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            )
          : null,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      tileColor: tileColor,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
