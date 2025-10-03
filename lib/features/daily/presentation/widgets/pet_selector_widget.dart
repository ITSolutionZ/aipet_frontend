import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 펫 선택기 위젯
/// 두 화면에서 공통으로 사용되는 펫 선택 기능을 제공합니다.
class PetSelectorWidget extends ConsumerWidget {
  final String? selectedPetId;
  final ValueChanged<String?> onPetSelected;

  const PetSelectorWidget({
    super.key,
    required this.selectedPetId,
    required this.onPetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProfilesNotifierProvider);

    return petsAsync.when(
      data: (pets) => _buildPetSelector(pets),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error, ref),
    );
  }

  Widget _buildPetSelector(List<PetProfileEntity> pets) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length + 1, // +1 for add button
        itemBuilder: (context, index) {
          if (index == pets.length) {
            // 펫 추가 버튼
            return _buildAddPetButton();
          }

          final pet = pets[index];
          final isSelected = selectedPetId == pet.id;

          return GestureDetector(
            onTap: () => onPetSelected(pet.id),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.toneOffWhite,
                      backgroundImage:
                          pet.imagePath != null && pet.imagePath!.isNotEmpty
                          ? _getPetImageProvider(pet.imagePath!)
                          : null,
                      child: pet.imagePath == null || pet.imagePath!.isEmpty
                          ? Image.asset(
                              _getPetImagePath(pet.type),
                              width: 20,
                              height: 20,
                              color: AppColors.primary,
                              errorBuilder: (context, error, stackTrace) {
                                // 이미지 로드 실패 시 기본 아이콘 표시
                                return const Icon(
                                  Icons.pets,
                                  color: AppColors.primary,
                                  size: 20,
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddPetButton() {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          // 펫 등록 화면으로 이동
          context.push('/pet-type-selection');
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderGray, width: 1.5),
                  color: AppColors.cardBackgroundWhite,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '追加',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorState(Object error, WidgetRef ref) {
    return Center(
      child: IconButton(
        onPressed: () => ref.invalidate(petProfilesNotifierProvider),
        icon: const Icon(Icons.refresh, color: Colors.red),
      ),
    );
  }

  /// 펫 이미지 프로바이더 반환 (Asset, File, Network 지원)
  ImageProvider? _getPetImageProvider(String imagePath) {
    try {
      if (imagePath.startsWith('http')) {
        // 네트워크 이미지
        return NetworkImage(imagePath);
      } else if (imagePath.startsWith('assets/')) {
        // Asset 이미지
        return AssetImage(imagePath);
      } else {
        // 로컬 파일 이미지
        return AssetImage(imagePath);
      }
    } catch (e) {
      // 이미지 로드 실패 시 null 반환
      return null;
    }
  }

  /// 펫 타입에 따른 이미지 경로 반환
  String _getPetImagePath(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return 'assets/icons/pet_type/dog.png';
      case 'cat':
        return 'assets/icons/pet_type/kitty.png';
      case 'bird':
        return 'assets/icons/pet_type/bird.png';
      case 'small mammals':
      case 'hamster':
        return 'assets/icons/pet_type/hamster.png';
      case 'rabbit':
        return 'assets/icons/pet_type/rabbit.png';
      case 'turtle':
        return 'assets/icons/pet_type/turtle.png';
      case 'fish':
        return 'assets/icons/pet_type/fish.png';
      case 'snake':
        return 'assets/icons/pet_type/snake.png';
      case 'reptile':
      case 'chameleon':
        return 'assets/icons/pet_type/chameleon.png';
      case 'amphibian':
        return 'assets/icons/pet_type/amphibian.png';
      case 'invertebrate':
        return 'assets/icons/pet_type/invertebrate.png';
      case 'arachnid':
      case 'spider':
        return 'assets/icons/pet_type/spider.png';
      case 'insect':
      case 'ladybug':
        return 'assets/icons/pet_type/ladybug.png';
      case 'hedgehog':
        return 'assets/icons/pet_type/hedgehog.png';
      case 'other':
      default:
        return 'assets/icons/aipet_logo.png';
    }
  }
}
