import 'dart:io';

import 'package:aipet_frontend/features/pet_profile/presentation/constants/pet_profile_constants.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// Pet Profile 이미지 위젯
///
/// 펫의 프로필 이미지를 표시하고 편집 기능을 제공하는 재사용 가능한 위젯입니다.
class PetProfileImageWidget extends StatelessWidget {
  final String? imagePath;
  final bool isEditMode;
  final VoidCallback? onImageTap;
  final double size;
  final bool showEditButton;

  const PetProfileImageWidget({
    super.key,
    this.imagePath,
    this.isEditMode = false,
    this.onImageTap,
    this.size = PetProfileConstants.profileImageSize,
    this.showEditButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImageContainer(context),
        if (isEditMode && showEditButton) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildEditButton(context),
        ],
      ],
    );
  }

  Widget _buildImageContainer(BuildContext context) {
    return GestureDetector(
      onTap: isEditMode ? onImageTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.pointGray.withValues(
              alpha: PetProfileConstants.borderOpacity,
            ),
            width: PetProfileConstants.profileImageBorderWidth,
          ),
        ),
        child: ClipOval(
          child: imagePath != null
              ? _buildImageWidget(imagePath!)
              : _buildDefaultImage(),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    final imageType = ImageService.getImageType(imagePath);

    switch (imageType) {
      case ImageType.file:
        return Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: _buildErrorWidget,
        );
      case ImageType.network:
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: _buildErrorWidget,
        );
      case ImageType.asset:
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: _buildErrorWidget,
        );
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      color: AppColors.pointGray.withValues(
        alpha: PetProfileConstants.iconBackgroundOpacity,
      ),
      child: Icon(Icons.pets, size: size * 0.4, color: AppColors.pointGray),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      color: AppColors.pointGray.withValues(
        alpha: PetProfileConstants.iconBackgroundOpacity,
      ),
      child: Icon(Icons.pets, size: size * 0.4, color: AppColors.pointGray),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return TextButton.icon(
      onPressed: onImageTap,
      icon: const Icon(Icons.camera_alt, size: 16),
      label: const Text(PetProfileConstants.changeImageButton),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.pointBrown,
        textStyle: AppFonts.bodySmall,
      ),
    );
  }
}

/// 이미지 선택 다이얼로그
class PetImageSelectionDialog extends StatelessWidget {
  final VoidCallback? onTakePhoto;
  final VoidCallback? onSelectFromGallery;
  final bool allowRemoval;
  final VoidCallback? onRemove;

  const PetImageSelectionDialog({
    super.key,
    this.onTakePhoto,
    this.onSelectFromGallery,
    this.allowRemoval = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          if (onTakePhoto != null)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(PetProfileConstants.takePhotoButton),
              onTap: () {
                Navigator.pop(context);
                onTakePhoto!();
              },
            ),
          if (onSelectFromGallery != null)
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(PetProfileConstants.selectFromGalleryButton),
              onTap: () {
                Navigator.pop(context);
                onSelectFromGallery!();
              },
            ),
          if (allowRemoval && onRemove != null)
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.pointRed),
              title: const Text(
                '削除',
                style: TextStyle(color: AppColors.pointRed),
              ),
              onTap: () {
                Navigator.pop(context);
                onRemove!();
              },
            ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    VoidCallback? onTakePhoto,
    VoidCallback? onSelectFromGallery,
    bool allowRemoval = false,
    VoidCallback? onRemove,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PetImageSelectionDialog(
        onTakePhoto: onTakePhoto,
        onSelectFromGallery: onSelectFromGallery,
        allowRemoval: allowRemoval,
        onRemove: onRemove,
      ),
    );
  }
}
