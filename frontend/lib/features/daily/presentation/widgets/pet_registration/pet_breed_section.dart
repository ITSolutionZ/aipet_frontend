import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration/pet_registration_constants.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 품종 선택 섹션
class PetBreedSection extends StatefulWidget {
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
  State<PetBreedSection> createState() => _PetBreedSectionState();
}

class _PetBreedSectionState extends State<PetBreedSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final petTypeData =
        PetRegistrationConstants.petTypes[widget.selectedPetType];

    // breeds를 안전하게 List<Map<String, dynamic>>로 변환
    List<Map<String, dynamic>> breeds = [];
    final rawBreeds = petTypeData?['breeds'];
    if (rawBreeds is List) {
      breeds = rawBreeds.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredFieldLabel('品種選択'),
        const SizedBox(height: AppSpacing.md),
        if (breeds.isNotEmpty)
          // 품종 아코디언
          ExpansionTile(
            key: ValueKey(_isExpanded),
            initiallyExpanded: _isExpanded,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            title: Text(
              widget.selectedBreed.isNotEmpty ? widget.selectedBreed : '品種選択',
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.selectedBreed.isNotEmpty
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            leading: widget.selectedBreed.isNotEmpty
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
                              (breed) => breed['name'] == widget.selectedBreed,
                              orElse: () => breeds.first,
                            )['image']
                            as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            widget.selectedPetType == 'dog'
                                ? Icons.pets
                                : widget.selectedPetType == 'cat'
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
                    widget.selectedPetType == 'dog'
                        ? Icons.pets
                        : widget.selectedPetType == 'cat'
                        ? Icons.cruelty_free
                        : Icons.pets_outlined,
                    color: AppColors.textSecondary,
                  ),
            children: breeds.map((breed) {
              final breedName = breed['name'] as String;
              final breedImage = breed['image'] as String;
              final isSelected = widget.selectedBreed == breedName;

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
                          widget.selectedPetType == 'dog'
                              ? Icons.pets
                              : widget.selectedPetType == 'cat'
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
                onTap: () {
                  widget.onBreedChanged(breedName);
                  // 선택 후 아코디언 닫기
                  setState(() {
                    _isExpanded = false;
                  });
                },
              );
            }).toList(),
          )
        else
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Text(
                'ペットの種類を先に選択してください',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
      ],
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
