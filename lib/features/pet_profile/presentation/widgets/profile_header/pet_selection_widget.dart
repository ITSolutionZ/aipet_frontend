import 'dart:io';

import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class PetSelectionWidget extends StatelessWidget {
  final PetProfileEntity pet;
  final VoidCallback onTap;

  const PetSelectionWidget({super.key, required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              backgroundImage: _getPetImageProvider(pet.imagePath),
              child: pet.imagePath == null || pet.imagePath!.isEmpty
                  ? const Icon(
                      Icons.pets,
                      size: 16,
                      color: AppColors.pointBrown,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              pet.name,
              style: AppFonts.bodyMedium.copyWith(
                color: const Color(0xFF5B4034),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF5B4034),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 펫 이미지 Provider 가져오기 - 강화된 로컬 저장 지원
  ImageProvider? _getPetImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    debugPrint('🖼️ PetSelectionWidget - imagePath: $imagePath');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(imagePath) ?? imagePath;
    debugPrint('🖼️ PetSelectionWidget - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    debugPrint('🖼️ PetSelectionWidget - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        debugPrint('🖼️ PetSelectionWidget - File exists: $fileExists');

        if (!fileExists) {
          debugPrint(
            '❌ PetSelectionWidget - File does not exist: $absolutePath',
          );
          return null;
        }

        return FileImage(file);
      case ImageType.network:
        return NetworkImage(absolutePath);
      case ImageType.asset:
        return AssetImage(absolutePath);
    }
  }
}
