import 'package:flutter/material.dart';

import '../../../../../shared/shared.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const HomeHeader({super.key, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.sm,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.pointBrown.withValues(alpha: 0.8),
      ),
      child: Row(
        children: [
          _buildMenuButton(context),
          const Spacer(),
          _buildTitle(),
          const Spacer(),
          _buildNotificationButton(),
          const SizedBox(width: 8),
          _buildProfileAvatar(),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => Scaffold.of(context).openDrawer(),
        child: const Icon(Icons.menu, size: 24, color: AppColors.pointOffWhite),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'ホーム',
      style: TextStyle(
        fontSize: 18,
        color: AppColors.pointOffWhite,
        fontWeight: FontWeight.bold,
        fontFamily: 'Fredoka',
      ),
    );
  }

  Widget _buildNotificationButton() {
    return IconButton(
      onPressed: onNotificationTap,
      icon: const Stack(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: AppColors.pointOffWhite,
            size: 24,
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Icon(Icons.circle, color: AppColors.pointPink, size: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.pointOffWhite, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/placeholder.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.pointGray.withValues(alpha: 0.3),
              child: const Icon(
                Icons.person,
                color: AppColors.pointGray,
                size: 16,
              ),
            );
          },
        ),
      ),
    );
  }
}
