import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 이미지 선택 섹션
class PetImageSection extends StatelessWidget {
  final String? petImagePath;
  final VoidCallback onImageTap;

  const PetImageSection({
    super.key,
    required this.petImagePath,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = petImagePath != null && petImagePath!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: GestureDetector(
              onTap: onImageTap,
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
                        image: hasImage
                            ? DecorationImage(
                                image: _getImageProvider(petImagePath!),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage(
                                  'assets/icons/aipet_logo.png',
                                ),
                                fit: BoxFit.contain,
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
    return const AssetImage('assets/icons/aipet_logo.png');
  }
}
