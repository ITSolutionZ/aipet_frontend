import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 성별 선택 섹션 (중성화 체크박스 포함)
class PetGenderSection extends StatelessWidget {
  final String selectedGender;
  final bool isNeutered;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<bool> onNeuteringChanged;

  const PetGenderSection({
    super.key,
    required this.selectedGender,
    required this.isNeutered,
    required this.onGenderChanged,
    required this.onNeuteringChanged,
  });

  static const List<String> genders = ['オス', 'メス'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '性別',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: genders.map((gender) {
            final isSelected = selectedGender == gender;
            return Column(
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: gender,
                      groupValue: selectedGender,
                      onChanged: (value) {
                        if (value != null) {
                          onGenderChanged(value);
                        }
                      },
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      gender,
                      style: AppFonts.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    // 중성화 체크박스
                    Checkbox(
                      value: isSelected && isNeutered,
                      onChanged: isSelected
                          ? (value) {
                              onNeuteringChanged(value ?? false);
                            }
                          : null,
                      activeColor: AppColors.primary,
                      checkColor: Colors.white,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(
                      '去勢・避妊',
                      style: AppFonts.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (gender != genders.last)
                  const SizedBox(height: AppSpacing.sm),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
