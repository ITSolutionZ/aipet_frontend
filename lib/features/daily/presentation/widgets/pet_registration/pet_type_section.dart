import 'package:aipet_frontend/features/daily/presentation/controllers/pet_registration_controller.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 타입 선택 섹션
class PetTypeSection extends StatelessWidget {
  final String selectedPetType;
  final ValueChanged<String> onPetTypeChanged;

  const PetTypeSection({
    super.key,
    required this.selectedPetType,
    required this.onPetTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildRequiredFieldLabel('펫 종류'),
          const SizedBox(height: AppSpacing.md),
          // 펫 타입 아코디언
          ExpansionTile(
            title: Text(
              selectedPetType.isNotEmpty
                  ? (PetRegistrationController
                                .petTypes[selectedPetType]?['name']
                            as String? ??
                        '펫 종류 선택')
                  : '펫 종류 선택',
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: selectedPetType.isNotEmpty
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            leading: selectedPetType.isNotEmpty
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
                        _getPetTypeImagePath(selectedPetType),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            PetRegistrationController
                                        .petTypes[selectedPetType]?['icon']
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
            children: PetRegistrationController.petTypes.entries.map((entry) {
              final petTypeKey = entry.key;
              final petTypeData = entry.value;
              final petTypeName = petTypeData['name'] as String;
              final petTypeIcon = petTypeData['icon'] as IconData;
              final isSelected = selectedPetType == petTypeKey;

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
                onTap: () => onPetTypeChanged(petTypeKey),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 펫 타입에 따른 이미지 경로 반환
  String _getPetTypeImagePath(String petTypeKey) {
    // 개와 고양이는 대표 이미지 사용
    if (petTypeKey == 'dog') {
      return 'assets/images/dogs.png';
    } else if (petTypeKey == 'cat') {
      return 'assets/images/cat.png';
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
