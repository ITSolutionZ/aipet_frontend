import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
import '../../../../../../features/daily/presentation/controllers/pet_registration/pet_registration_constants.dart';

/// 펫 타입 선택 섹션
class PetTypeSection extends StatefulWidget {
  final String selectedPetType;
  final ValueChanged<String> onPetTypeChanged;

  const PetTypeSection({
    super.key,
    required this.selectedPetType,
    required this.onPetTypeChanged,
  });

  @override
  State<PetTypeSection> createState() => _PetTypeSectionState();
}

class _PetTypeSectionState extends State<PetTypeSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredFieldLabel('ペットの種類'),
        const SizedBox(height: AppSpacing.md),
        // 펫 타입 아코디언
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
            widget.selectedPetType.isNotEmpty
                ? (PetRegistrationConstants.petTypes[widget
                              .selectedPetType]?['name']
                          as String? ??
                      'ペットの種類を選択')
                : 'ペットの種類を選択',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.selectedPetType.isNotEmpty
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
          leading: widget.selectedPetType.isNotEmpty
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
                      _getPetTypeImagePath(widget.selectedPetType),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          PetRegistrationConstants.petTypes[widget
                                      .selectedPetType]?['icon']
                                  as IconData? ??
                              Icons.pets,
                          size: 20,
                          color: AppColors.textSecondary,
                        );
                      },
                    ),
                  ),
                )
              : const Icon(Icons.pets, color: AppColors.textSecondary),
          children: PetRegistrationConstants.petTypes.entries.map((entry) {
            final petTypeKey = entry.key;
            final petTypeData = entry.value;
            final petTypeName = petTypeData['name'] as String;
            final petTypeIcon = petTypeData['icon'] as IconData;
            final isSelected = widget.selectedPetType == petTypeKey;

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
                    _getPetTypeImagePath(petTypeKey),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        petTypeIcon,
                        size: 20,
                        color: AppColors.textSecondary,
                      );
                    },
                  ),
                ),
              ),
              title: Text(
                petTypeName,
                style: AppFonts.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              selected: isSelected,
              selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
              onTap: () {
                widget.onPetTypeChanged(petTypeKey);
                // 선택 후 아코디언 닫기
                setState(() {
                  _isExpanded = false;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 펫 타입에 따른 이미지 경로 반환
  String _getPetTypeImagePath(String petTypeKey) {
    // 개와 고양이는 대표 이미지 사용
    if (petTypeKey == 'dog') {
      return 'assets/images/dogs/dogs.png';
    } else if (petTypeKey == 'cat') {
      return 'assets/images/cats/cats.png';
    } else {
      // 나머지는 etc 폴더의 이미지 사용
      return 'assets/images/etc/$petTypeKey.png';
    }
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
