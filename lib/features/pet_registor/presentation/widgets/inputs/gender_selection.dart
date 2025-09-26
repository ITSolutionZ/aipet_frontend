import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class GenderSelection extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderChanged;

  const GenderSelection({
    super.key,
    this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ペットの性別選択',
      hint: '性別を選択してください。オスまたはメスを選べます。',
      child: Row(
        children: [
          _buildGenderButton(
            gender: 'male',
            symbol: '♂',
            label: 'オス',
            isSelected: selectedGender == 'male',
          ),
          const SizedBox(width: AppSpacing.md),
          _buildGenderButton(
            gender: 'female',
            symbol: '♀',
            label: 'メス',
            isSelected: selectedGender == 'female',
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton({
    required String gender,
    required String symbol,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: Semantics(
        label: '$labelを選択',
        hint: isSelected ? '選択されています' : 'タップして選択',
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: () => onGenderChanged(gender),
          child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.pointBrown : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: isSelected
                  ? AppColors.pointBrown
                  : AppColors.pointBrown.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.pointDark,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppFonts.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.pointDark,
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
