import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class ImageSourceSelectionWidget extends StatelessWidget {
  final VoidCallback onGallerySelected;
  final VoidCallback onDefaultSelected;

  const ImageSourceSelectionWidget({
    super.key,
    required this.onGallerySelected,
    required this.onDefaultSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('プロフィール写真変更', style: AppFonts.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ギャラリーから選択
              _buildSourceOption(
                icon: Icons.photo_library,
                label: 'ギャラリー',
                color: AppColors.pointBlue,
                onTap: onGallerySelected,
              ),
              // デフォルト画像に変更
              _buildSourceOption(
                icon: Icons.pets,
                label: 'デフォルト',
                color: AppColors.pointBrown,
                onTap: onDefaultSelected,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label),
      ],
    );
  }
}
