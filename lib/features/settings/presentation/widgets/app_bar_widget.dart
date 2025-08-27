import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfileImage;

  const AppBarWidget({
    super.key,
    required this.title,
    this.showProfileImage = false,
  });

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
      actions: showProfileImage
          ? [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, size: 20),
                      );
                    },
                  ),
                ),
              ),
            ]
          : null,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
