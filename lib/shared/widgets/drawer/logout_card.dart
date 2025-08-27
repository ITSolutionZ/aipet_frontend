import 'package:flutter/material.dart';

class DrawerLogoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const DrawerLogoutCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
      child: ListTile(
        leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
        title: Text(
          '로그아웃',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
