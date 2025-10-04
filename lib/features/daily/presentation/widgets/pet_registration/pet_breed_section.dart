import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 품종 선택 섹션
class PetBreedSection extends StatelessWidget {
  final String selectedPetType;
  final String selectedBreed;
  final ValueChanged<String> onBreedChanged;

  const PetBreedSection({
    super.key,
    required this.selectedPetType,
    required this.selectedBreed,
    required this.onBreedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final petTypeData = PetRegistrationController.petTypes[selectedPetType];
    final breeds = petTypeData?['breeds'] as List<Map<String, dynamic>>? ?? [];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequiredFieldLabel('품종 선택'),
          const SizedBox(height: AppSpacing.md),
          if (breeds.isNotEmpty)
            // 품종 아코디언
            ExpansionTile(
              title: Text(
                selectedBreed.isNotEmpty ? selectedBreed : '품종 선택',
                style: AppFonts.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: selectedBreed.isNotEmpty
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              leading: selectedBreed.isNotEmpty
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        color: AppColors.backgroundGray.withValues(alpha: 0.3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        child: Image.asset(
                          breeds.firstWhere(
                                (breed) => breed['name'] == selectedBreed,
                                orElse: () => breeds.first,
                              )['image']
                              as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              selectedPetType == 'dog'
                                  ? Icons.pets
                                  : selectedPetType == 'cat'
                                  ? Icons.cruelty_free
                                  : Icons.pets_outlined,
                              size: 20,
                              color: AppColors.textSecondary,
                            );
                          },
                        ),
                      ),
                    )
                  : Icon(
                      selectedPetType == 'dog'
                          ? Icons.pets
                          : selectedPetType == 'cat'
                          ? Icons.cruelty_free
                          : Icons.pets_outlined,
                      color: AppColors.textSecondary,
                    ),
              children: breeds.map((breed) {
                final breedName = breed['name'] as String;
                final breedImage = breed['image'] as String;
                final isSelected = selectedBreed == breedName;

                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                      color: AppColors.backgroundGray.withValues(alpha: 0.3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                      child: Image.asset(
                        breedImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            selectedPetType == 'dog'
                                ? Icons.pets
                                : selectedPetType == 'cat'
                                ? Icons.cruelty_free
                                : Icons.pets_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          );
                        },
                      ),
                    ),
                  ),
                  title: Text(
                    breedName,
                    style: AppFonts.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  selected: isSelected,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                  onTap: () => onBreedChanged(breedName),
                );
              }).toList(),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text(
                  '펫 종류를 먼저 선택해주세요',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequiredFieldLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.pointRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
