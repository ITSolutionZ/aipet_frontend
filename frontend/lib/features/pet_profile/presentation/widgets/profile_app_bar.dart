import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PetProfileEntity pet;

  const ProfileAppBar({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.pointBrown,
      foregroundColor: Colors.white,
      title: Text(
        pet.name,
        style: AppFonts.titleLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Navigate to edit screen or show edit options
          },
          icon: const Icon(Icons.edit, color: Colors.white),
          tooltip: '編集',
        ),
        IconButton(
          onPressed: () {
            // Show more options menu
          },
          icon: const Icon(Icons.more_vert, color: Colors.white),
          tooltip: 'メニュー',
        ),
      ],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
