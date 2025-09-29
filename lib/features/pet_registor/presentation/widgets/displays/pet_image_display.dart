import 'dart:io';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class PetImageDisplay extends StatelessWidget {
  final String? imagePath;
  final dynamic imageFile; // String 또는 File을 받을 수 있도록 변경
  final double width;
  final double height;
  final bool showUploadIcon;
  final VoidCallback? onTap;
  final Widget? badge;

  const PetImageDisplay({
    super.key,
    this.imagePath,
    this.imageFile,
    this.width = 180,
    this.height = 180,
    this.showUploadIcon = false,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width / 2),
              child: _buildImage(),
            ),
          ),
          if (showUploadIcon)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.pointPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pureWhite, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.pureWhite,
                  size: 20,
                ),
              ),
            ),
          if (badge != null) Positioned(top: 10, right: 10, child: badge!),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageFile != null) {
      // imageFile이 실제로 File 타입인지 확인하고 처리
      if (imageFile is File) {
        return Image.file(
          imageFile!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
        );
      } else if (imageFile is String) {
        // String 경로가 전달된 경우 File로 변환
        return Image.file(
          File(imageFile as String),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
        );
      }
    }

    if (imagePath != null) {
      // 먼저 파일 경로인지 확인
      if (imagePath!.startsWith('/') || imagePath!.contains('\\')) {
        // 절대 경로인 경우 File로 처리
        return Image.file(
          File(imagePath!),
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
        );
      } else {
        // Asset 경로인 경우
        return Image.asset(
          imagePath!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
        );
      }
    }

    return _buildDefaultImage();
  }

  Widget _buildDefaultImage() {
    return Container(
      width: width,
      height: height,
      color: AppColors.pointGray.withValues(alpha: 0.2),
      child: Icon(Icons.pets, size: width * 0.3, color: AppColors.pointPink),
    );
  }
}
