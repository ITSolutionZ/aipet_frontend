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
  final IconData? icon;
  final Color? backgroundColor;

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
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          leading ??
          (icon != null && backgroundColor != null
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                )
              : null),
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
          const const const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
