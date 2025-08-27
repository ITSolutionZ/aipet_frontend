import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';

class NotificationAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const NotificationAppBarWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.pointBrown.withValues(alpha: 0.8),
      title: Text(
        title,
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
