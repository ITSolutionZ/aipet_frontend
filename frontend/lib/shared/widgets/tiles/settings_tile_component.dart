import 'package:flutter/material.dart';

import '../../../shared/shared.dart';

/// 設定タイル コンポーネント (汎用)
class SettingsTileComponent extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  const SettingsTileComponent({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: ListTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }
}
