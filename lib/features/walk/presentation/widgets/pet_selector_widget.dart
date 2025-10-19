import 'dart:io';

import 'package:aipet_frontend/features/walk/domain/entities/pet_info.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class PetSelectorWidget extends StatelessWidget {
  final WalkPetInfo? selectedPet;
  final Function(WalkPetInfo) onPetSelected;

  const PetSelectorWidget({
    super.key,
    this.selectedPet,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPetSelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: AppColors.pointBrown.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 반려동물 이미지
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.pointBrown.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  selectedPet?.imageUrl ?? 'assets/images/dogs/shiba.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.pets,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // 반려동물 이름
            Text(
              selectedPet?.name ?? 'Maxi',
              style: AppFonts.bodySmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            // 드롭다운 아이콘
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.pointGray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showPetSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PetSelectorBottomSheet(
        selectedPet: selectedPet,
        onPetSelected: onPetSelected,
      ),
    );
  }
}

class _PetSelectorBottomSheet extends StatelessWidget {
  final WalkPetInfo? selectedPet;
  final Function(WalkPetInfo) onPetSelected;

  const _PetSelectorBottomSheet({
    this.selectedPet,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final pets = [
      const WalkPetInfo(
        id: 'pet1',
        type: 'dog',
        name: 'Maxi',
        imageUrl: 'assets/images/dogs/shiba.png',
      ),
      const WalkPetInfo(
        id: 'pet2',
        type: 'dog',
        name: 'Luna',
        imageUrl: 'assets/images/dogs/poodle.jpg',
      ),
      const WalkPetInfo(
        id: 'pet3',
        type: 'dog',
        name: 'Buddy',
        imageUrl: 'assets/images/dogs/chiwawa.png',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '반려동물 선택',
            style: AppFonts.fredoka(
              fontSize: AppFonts.lg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...pets.map((pet) => _buildPetOption(context, pet)),
        ],
      ),
    );
  }

  Widget _buildPetOption(BuildContext context, WalkPetInfo pet) {
    final isSelected = selectedPet?.id == pet.id;

    return GestureDetector(
      onTap: () {
        onPetSelected(pet);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.pointBrown : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 반려동물 이미지
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.pointBrown : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: _buildPetImage(pet.imageUrl),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // 반려동물 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: AppFonts.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.pointBrown
                          : AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '散歩記録を見る',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
            // 선택 표시
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.pointBrown,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// 펫 이미지 위젯 빌드 - 강화된 로컬 저장 지원
  Widget _buildPetImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Icon(Icons.pets, color: Colors.grey[600], size: 24),
      );
    }

    debugPrint('🖼️ PetSelectorWidget - imageUrl: $imageUrl');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(imageUrl) ?? imageUrl;
    debugPrint('🖼️ PetSelectorWidget - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    debugPrint('🖼️ PetSelectorWidget - imageType: $imageType');

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        debugPrint('🖼️ PetSelectorWidget - File exists: $fileExists');

        if (!fileExists) {
          debugPrint(
            '❌ PetSelectorWidget - File does not exist: $absolutePath',
          );
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.pets, color: Colors.grey[600], size: 24),
          );
        }

        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('🖼️ PetSelectorWidget - File image error: $error');
            return Container(
              color: Colors.grey[300],
              child: Icon(Icons.pets, color: Colors.grey[600], size: 24),
            );
          },
        );
      case ImageType.network:
        return Image.network(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('🖼️ PetSelectorWidget - Network image error: $error');
            return Container(
              color: Colors.grey[300],
              child: Icon(Icons.pets, color: Colors.grey[600], size: 24),
            );
          },
        );
      case ImageType.asset:
        return Image.asset(
          absolutePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('🖼️ PetSelectorWidget - Asset image error: $error');
            return Container(
              color: Colors.grey[300],
              child: Icon(Icons.pets, color: Colors.grey[600], size: 24),
            );
          },
        );
    }
  }
}
