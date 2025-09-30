import 'package:aipet_frontend/shared/core/services/image_service.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:aipet_frontend/shared/widgets/displays/image_display.dart';
import 'package:flutter/material.dart';

/// 🖼️ 통합 이미지 선택 위젯
///
/// ImageService를 사용하여 일관된 이미지 선택 경험을 제공합니다.
/// 갤러리, 카메라, 기본 이미지 선택을 지원합니다.
class ImagePickerWidget extends StatelessWidget {
  final String? currentImagePath;
  final ValueChanged<String?> onImageChanged;
  final double size;
  final bool showUploadIcon;
  final bool allowRemoval;
  final bool showDefaultImages;
  final List<String>? customDefaultImages;
  final Widget? placeholder;
  final String? placeholderAsset;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ImagePickerWidget({
    super.key,
    required this.onImageChanged,
    this.currentImagePath,
    this.size = 120,
    this.showUploadIcon = true,
    this.allowRemoval = false,
    this.showDefaultImages = true,
    this.customDefaultImages,
    this.placeholder,
    this.placeholderAsset,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  /// 펫 프로필용 팩토리
  factory ImagePickerWidget.petProfile({
    required ValueChanged<String?> onImageChanged,
    String? currentImagePath,
    double size = 120,
  }) {
    return ImagePickerWidget(
      onImageChanged: onImageChanged,
      currentImagePath: currentImagePath,
      size: size,
      showUploadIcon: true,
      allowRemoval: true,
      showDefaultImages: true,
      placeholderAsset: 'assets/images/pet_selector/dog.png',
      borderRadius: BorderRadius.circular(size / 2), // 원형
    );
  }

  /// 일반용 팩토리
  factory ImagePickerWidget.general({
    required ValueChanged<String?> onImageChanged,
    String? currentImagePath,
    double size = 100,
    bool allowRemoval = true,
  }) {
    return ImagePickerWidget(
      onImageChanged: onImageChanged,
      currentImagePath: currentImagePath,
      size: size,
      showUploadIcon: true,
      allowRemoval: allowRemoval,
      showDefaultImages: false,
      borderRadius: BorderRadius.circular(AppRadius.medium),
    );
  }

  /// 작은 사이즈 팩토리
  factory ImagePickerWidget.small({
    required ValueChanged<String?> onImageChanged,
    String? currentImagePath,
  }) {
    return ImagePickerWidget(
      onImageChanged: onImageChanged,
      currentImagePath: currentImagePath,
      size: 80,
      showUploadIcon: true,
      allowRemoval: false,
      showDefaultImages: false,
      borderRadius: BorderRadius.circular(AppRadius.small),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.large),
          child: Stack(children: [_buildImageContent(), if (showUploadIcon) _buildUploadIcon()]),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    return ImageDisplay(
      imagePath: currentImagePath,
      width: size,
      height: size,
      fit: fit,
      placeholder: placeholder,
      placeholderAsset: placeholderAsset,
    );
  }

  Widget _buildUploadIcon() {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        width: size * 0.25,
        height: size * 0.25,
        decoration: BoxDecoration(
          color: AppColors.pointBrown,
          borderRadius: BorderRadius.circular(size * 0.125),
          border: Border.all(color: AppColors.pureWhite, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(Icons.camera_alt, color: AppColors.pureWhite, size: size * 0.15),
      ),
    );
  }

  Future<void> _showImagePickerOptions(BuildContext context) async {
    final result = await ImageService.showImagePickerOptions(
      context,
      showDefaultImages: showDefaultImages,
      allowRemoval: allowRemoval,
      customDefaultImages: customDefaultImages,
      currentImagePath: currentImagePath,
    );

    if (result != null) {
      if (result == 'REMOVE') {
        onImageChanged(null);
      } else {
        onImageChanged(result);
      }
    }
  }
}

/// 간단한 이미지 선택 버튼
class ImagePickerButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color? color;

  const ImagePickerButton({
    super.key,
    required this.onTap,
    required this.label,
    this.icon = Icons.add_photo_alternate,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: color ?? AppColors.pointBrown, width: 2),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? AppColors.pointBrown, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppFonts.bodyMedium.copyWith(
                color: color ?? AppColors.pointBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 이미지 미리보기 그리드
class ImagePreviewGrid extends StatelessWidget {
  final List<String> imagePaths;
  final ValueChanged<String>? onImageTap;
  final ValueChanged<String>? onImageRemove;
  final int crossAxisCount;
  final double spacing;

  const ImagePreviewGrid({
    super.key,
    required this.imagePaths,
    this.onImageTap,
    this.onImageRemove,
    this.crossAxisCount = 3,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        final imagePath = imagePaths[index];
        return _buildImagePreviewCard(context, imagePath);
      },
    );
  }

  Widget _buildImagePreviewCard(BuildContext context, String imagePath) {
    return GestureDetector(
      onTap: () => onImageTap?.call(imagePath),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.pointGray.withValues(alpha: 0.3), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: ImageDisplay(
                imagePath: imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (onImageRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onImageRemove!(imagePath),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.pointPink,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.pureWhite, width: 1),
                  ),
                  child: const Icon(Icons.close, color: AppColors.pureWhite, size: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
