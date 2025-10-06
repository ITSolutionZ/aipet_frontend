import 'package:aipet_frontend/shared/mock_data/pet_food_mock_data.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 펫 사료 정보 섹션
class PetFoodSection extends StatelessWidget {
  final String selectedFood;
  final String selectedSupplement;
  final String selectedTreat;
  final ValueChanged<String> onFoodChanged;
  final ValueChanged<String> onSupplementChanged;
  final ValueChanged<String> onTreatChanged;

  const PetFoodSection({
    super.key,
    required this.selectedFood,
    required this.selectedSupplement,
    required this.selectedTreat,
    required this.onFoodChanged,
    required this.onSupplementChanged,
    required this.onTreatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchableDropdown(
          title: '食べる餌',
          selectedValue: selectedFood,
          options: PetFoodMockData.foods,
          onChanged: onFoodChanged,
          icon: PetFoodMockData.getCategoryIcons()['food']!,
          hintText: '餌を検索または選択してください',
        ),
        const SizedBox(height: AppSpacing.md),
        SearchableDropdown(
          title: '食べる栄養剤',
          selectedValue: selectedSupplement,
          options: PetFoodMockData.supplements,
          onChanged: onSupplementChanged,
          icon: PetFoodMockData.getCategoryIcons()['supplement']!,
          hintText: '栄養剤を検索または選択してください',
        ),
        const SizedBox(height: AppSpacing.md),
        SearchableDropdown(
          title: '食べるおやつ',
          selectedValue: selectedTreat,
          options: PetFoodMockData.treats,
          onChanged: onTreatChanged,
          icon: PetFoodMockData.getCategoryIcons()['treat']!,
          hintText: 'おやつを検索または選択してください',
        ),
      ],
    );
  }

}
