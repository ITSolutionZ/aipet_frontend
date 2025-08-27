import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';

class NotificationSettingsTileWidget extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const NotificationSettingsTileWidget({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: ListTile(
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
