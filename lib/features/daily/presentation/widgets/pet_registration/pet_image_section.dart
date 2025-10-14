import 'dart:io';

import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 이미지 선택 섹션
class PetImageSection extends StatelessWidget {
  final String? petImagePath;
  final bool isLoading;
  final VoidCallback onImageTap;

  const PetImageSection({
    super.key,
    required this.petImagePath,
    this.isLoading = false,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = petImagePath != null && petImagePath!.isNotEmpty;

    debugPrint(
      '🖼️ PetImageSection build - petImagePath: $petImagePath, hasImage: $hasImage',
    );

    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Center(
          child: GestureDetector(
            onTap: isLoading ? null : onImageTap,
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundGray,
                      border: Border.all(
                        color: AppColors.borderGray,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          hasImage
                              ? Image(
                                  image: _getImageProvider(petImagePath!),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultImage();
                                  },
                                )
                              : _buildDefaultImage(),
                          if (isLoading)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasImage ? Icons.edit : Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 기본 이미지 위젯
  Widget _buildDefaultImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: AppColors.backgroundGray,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Image(
          image: AssetImage('assets/icons/logos/aipet_logo.png'),
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  ImageProvider<Object> _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    // 로컬 파일 경로인 경우 FileImage 사용
    return FileImage(File(path));
  }
}
