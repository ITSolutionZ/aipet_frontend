import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 성별 선택 섹션
class PetGenderSection extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const PetGenderSection({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  static const List<String> genders = ['남아', '여아'];

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
          Text(
            '성별',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: genders.map((gender) {
              return Expanded(
                child: Row(
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
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
