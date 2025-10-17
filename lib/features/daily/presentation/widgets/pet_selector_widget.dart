import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/features/pet_profile/presentation/utils/utils.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final petsAsync = ref.watch(petProfilesProvider);

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
                    child: ClipOval(child: _buildPetImage(pet)),
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

  Widget _buildPetImage(PetProfileEntity pet) {
    final imagePath = PetImageUtils.getImagePath(pet.imagePath, pet.type);

    // 빈 문자열 체크
    if (imagePath.isEmpty) {
      return Container(
        width: 36,
        height: 36,
        color: AppColors.pointGray.withValues(alpha: 0.2),
        child: const Icon(Icons.pets, size: 20, color: AppColors.pointBrown),
      );
    }

    return Image.asset(
      imagePath,
      width: 36,
      height: 36,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 36,
          height: 36,
          color: AppColors.pointGray.withValues(alpha: 0.2),
          child: const Icon(Icons.pets, size: 20, color: AppColors.pointBrown),
        );
      },
    );
  }

  Widget _buildAddPetButton() {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          // Daily Health 스타일 펫 등록 화면으로 이동
          context.push('/daily-pet-registration');
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
        onPressed: () => ref.invalidate(petProfilesProvider),
        icon: const Icon(Icons.refresh, color: Colors.red),
      ),
    );
  }
}
