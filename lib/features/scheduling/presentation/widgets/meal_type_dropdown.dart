import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 식사 타입 선택 드롭다운 위젯
class MealTypeDropdown extends StatelessWidget {
  final String selectedMealType;
  final ValueChanged<String?> onChanged;

  const MealTypeDropdown({
    super.key,
    required this.selectedMealType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '食事タイプ',
              style: AppFonts.titleSmall.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: selectedMealType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              items: ['朝食', '昼食', '夕食', 'おやつ'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}