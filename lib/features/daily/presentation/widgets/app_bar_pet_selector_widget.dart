import 'dart:io';

import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/services/image_storage_service.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱바용 펫 셀렉터 위젯 (흰색 테마)
class AppBarPetSelectorWidget extends ConsumerWidget {
  final String? selectedPetId;
  final ValueChanged<String?> onPetSelected;

  const AppBarPetSelectorWidget({
    super.key,
    required this.selectedPetId,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      data: (pets) => _buildPetSelector(pets),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error, ref),
    );
  }

  Widget _buildPetSelector(List<PetProfileEntity> pets) {
    const itemWidth = 48.0; // 아이템 하나의 너비 (40px 아바타 + 양쪽 4px 마진)
    const maxVisibleItems = 3;

    return SizedBox(
      height: 40,
      width: itemWidth * maxVisibleItems, // 항상 3개 아이템 너비로 고정
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(), // 스크롤 물리 효과
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          final isSelected = selectedPetId == pet.id;

          return GestureDetector(
            onTap: () => onPetSelected(pet.id),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.transparent
                      : Colors.black.withValues(alpha: 0.3),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(child: _buildPetImage(pet)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetImage(PetProfileEntity pet) {
    if (pet.imagePath == null || pet.imagePath!.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.pets, size: 20, color: Colors.white),
      );
    }

    debugPrint('🖼️ AppBarPetSelectorWidget - imagePath: ${pet.imagePath}');

    // 상대 경로를 절대 경로로 변환
    final storageService = ImageStorageService();
    final absolutePath = storageService.getAbsolutePath(pet.imagePath!) ?? pet.imagePath!;
    debugPrint('🖼️ AppBarPetSelectorWidget - absolutePath: $absolutePath');

    final imageType = ImageService.getImageType(absolutePath);
    debugPrint('🖼️ AppBarPetSelectorWidget - imageType: $imageType');

    Widget imageWidget;

    switch (imageType) {
      case ImageType.file:
        final file = File(absolutePath);
        final fileExists = file.existsSync();
        debugPrint('🖼️ AppBarPetSelectorWidget - File exists: $fileExists');

        if (!fileExists) {
          debugPrint('❌ AppBarPetSelectorWidget - File does not exist: $absolutePath');
          return _buildDefaultPetIcon();
        }

        imageWidget = Image.file(
          file,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('🖼️ AppBarPetSelectorWidget - File image error: $error');
            return _buildDefaultPetIcon();
          },
        );
        break;
      case ImageType.network:
        imageWidget = Image.network(
          absolutePath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('🖼️ AppBarPetSelectorWidget - Network image error: $error');
            return _buildDefaultPetIcon();
          },
        );
        break;
      case ImageType.asset:
        imageWidget = Image.asset(
          absolutePath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('🖼️ AppBarPetSelectorWidget - Asset image error: $error');
            return _buildDefaultPetIcon();
          },
        );
        break;
    }

    return ClipOval(child: imageWidget);
  }

  Widget _buildDefaultPetIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.pets, size: 20, color: Colors.white),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, WidgetRef ref) {
    return Center(
      child: IconButton(
        onPressed: () => ref.invalidate(petProfilesProvider),
        icon: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}
