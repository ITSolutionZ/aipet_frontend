import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ペット選択セクション
class PetSelectionSection extends ConsumerWidget {
  final PetProfileEntity? selectedPet;
  final bool isPetSelectorExpanded;
  final ValueChanged<PetProfileEntity> onPetSelected;
  final VoidCallback onToggleExpanded;

  const PetSelectionSection({
    super.key,
    required this.selectedPet,
    required this.isPetSelectorExpanded,
    required this.onPetSelected,
    required this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ペット選択',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // ペット選択ヘッダー (常時表示)
          InkWell(
            onTap: onToggleExpanded,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pets, color: AppColors.pointGreen),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      selectedPet != null
                          ? selectedPet!.name
                          : 'ペットを選択してください',
                      style: AppFonts.bodyMedium.copyWith(
                        color: selectedPet != null
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isPetSelectorExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ペットリスト (アコーディオン形式で展開)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isPetSelectorExpanded ? null : 0,
            child: isPetSelectorExpanded
                ? petsAsync.when(
                    data: (pets) {
                      if (pets.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      return _buildPetList(pets);
                    },
                    loading: () => Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => _buildErrorState(error),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(
            Icons.pets,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '登録されたペットがありません',
            style: AppFonts.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () {
              context.push('/pet-registration');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBrown,
              foregroundColor: Colors.white,
            ),
            child: const Text('ペット登録'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetList(List<PetProfileEntity> pets) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: pets.map((pet) {
          final isSelected = selectedPet?.id == pet.id;

          return InkWell(
            onTap: () => onPetSelected(pet),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.pointBrown.withValues(alpha: 0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Row(
                children: [
                  // ペット画像
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AppColors.pointBrown.withValues(alpha: 0.1),
                    backgroundImage: pet.imagePath != null
                        ? AssetImage(pet.imagePath!)
                        : null,
                    child: pet.imagePath == null
                        ? Text(
                            pet.typeIcon,
                            style: const TextStyle(fontSize: 16),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // ペット情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: AppFonts.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.pointBrown
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          pet.typeName,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 選択表示
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.pointBrown,
                      size: 20,
                    )
                  else
                    const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ペット情報の読み込み失敗',
            style: AppFonts.bodyMedium.copyWith(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error.toString(),
            style: AppFonts.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
