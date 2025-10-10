import 'package:aipet_frontend/features/daily/data/datasources/pet_food_local_datasource.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/searchable_dropdown.dart'
    as daily;
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
        daily.SearchableDropdown(
          title: '食べる餌',
          selectedValue: selectedFood,
          options: PetFoodLocalDatasource.foods,
          onChanged: onFoodChanged,
          icon: PetFoodLocalDatasource.getCategoryIcons()['food']!,
          hintText: '餌を検索または選択してください',
        ),
        const SizedBox(height: AppSpacing.md),
        daily.SearchableDropdown(
          title: '食べる栄養剤',
          selectedValue: selectedSupplement,
          options: PetFoodLocalDatasource.supplements,
          onChanged: onSupplementChanged,
          icon: PetFoodLocalDatasource.getCategoryIcons()['supplement']!,
          hintText: '栄養剤を検索または選択してください',
        ),
        const SizedBox(height: AppSpacing.md),
        daily.SearchableDropdown(
          title: '食べるおやつ',
          selectedValue: selectedTreat,
          options: PetFoodLocalDatasource.treats,
          onChanged: onTreatChanged,
          icon: PetFoodLocalDatasource.getCategoryIcons()['treat']!,
          hintText: 'おやつを検索または選択してください',
        ),
      ],
    );
  }
}
