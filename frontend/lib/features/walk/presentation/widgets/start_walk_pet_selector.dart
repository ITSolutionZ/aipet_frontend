import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 산책 시작 시 펫 선택 위젯 (Firebase 연동)
class StartWalkPetSelector extends ConsumerWidget {
  final String selectedPetId;
  final Function(String) onSelectPet;

  const StartWalkPetSelector({
    super.key,
    required this.selectedPetId,
    required this.onSelectPet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petProfilesProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: petsAsync.when(
        data: (pets) {
          if (pets.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'ペットを登録してください',
                style: AppFonts.base(
                  fontSize: AppFonts.baseSize,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            children: pets.map((pet) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: pet == pets.last ? 0 : AppSpacing.sm,
                ),
                child: _buildPetOption(
                  pet.id,
                  pet.name,
                  Icons.pets,
                  pet.breed ?? pet.type,
                  selectedPetId,
                  onSelectPet,
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'ペット情報の読み込みに失敗しました',
            style: AppFonts.base(
              fontSize: AppFonts.sm,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildPetOption(
    String petId,
    String name,
    IconData icon,
    String description,
    String selectedPetId,
    Function(String) onSelectPet,
  ) {
    final isSelected = selectedPetId == petId;

    return GestureDetector(
      onTap: () => onSelectPet(petId),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBlue.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? AppColors.pointBlue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.pointBlue : Colors.grey[200],
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppFonts.fredoka(
                      fontSize: AppFonts.baseSize,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.pointBlue
                          : Colors.grey[800],
                    ),
                  ),
                  Text(
                    description,
                    style: AppFonts.base(
                      fontSize: AppFonts.sm,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.pointBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
