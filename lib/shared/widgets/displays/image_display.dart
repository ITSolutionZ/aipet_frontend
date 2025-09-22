import 'dart:io';

import 'package:flutter/material.dart';

import '../../shared.dart';

/// 범용 이미지 표시 위젯
class ImageDisplay extends StatelessWidget {
  final String? imagePath;
  final dynamic imageFile; // String 또는 File을 받을 수 있도록 변경
  final double width;
  final double height;
  final bool showUploadIcon;
  final VoidCallback? onTap;
  final Widget? badge;
  final BoxFit fit;
  final String? placeholderAsset;
  final Widget? placeholder;

  const ImageDisplay({
    super.key,
    this.imagePath,
    this.imageFile,
    this.width = 180,
    this.height = 180,
    this.showUploadIcon = false,
    this.onTap,
    this.badge,
    this.fit = BoxFit.cover,
    this.placeholderAsset,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.pointGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: AppColors.pointGray.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: _buildImageContent(),
            ),
          ),

          // 업로드 아이콘
          if (showUploadIcon)
            Positioned(
              bottom: -8,
              right: -8,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.pointBrown,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pureWhite, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.pureWhite,
                  size: 18,
                ),
              ),
            ),

          // 배지
          if (badge != null) Positioned(top: 8, right: 8, child: badge!),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    // File 객체가 있는 경우
    if (imageFile != null && imageFile is File) {
      return Image.file(
        imageFile as File,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    // 이미지 경로가 있는 경우
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('http') || imagePath!.startsWith('https')) {
        // 네트워크 이미지
        return Image.network(
          imagePath!,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.pointBrown,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } else {
        // 로컬 에셋 이미지
        return Image.asset(
          imagePath!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    // String 형태의 imageFile (경로)
    if (imageFile != null && imageFile is String) {
      final String path = imageFile as String;
      if (path.startsWith('http') || path.startsWith('https')) {
        return Image.network(
          path,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } else {
        return Image.asset(
          path,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    if (placeholderAsset != null) {
      return Image.asset(
        placeholderAsset!,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: width * 0.3,
            color: AppColors.pointGray.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointGray.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
