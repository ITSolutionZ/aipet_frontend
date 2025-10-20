import '../../domain/domain.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 알레르기 타입 필터 칩
class AllergyFilterChips extends StatelessWidget {
  final AllergyType? selectedType;
  final ValueChanged<AllergyType?> onTypeChanged;

  const AllergyFilterChips({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip(
            label: 'ピ部発疹',
            type: AllergyType.skinDisease,
            isSelected: selectedType == AllergyType.skinDisease,
          ),
          _buildChip(
            label: '涙',
            type: AllergyType.tears,
            isSelected: selectedType == AllergyType.tears,
          ),
          _buildChip(
            label: '耳炎症',
            type: AllergyType.earInflammation,
            isSelected: selectedType == AllergyType.earInflammation,
          ),
          _buildChip(
            label: 'かゆみ',
            type: AllergyType.itching,
            isSelected: selectedType == AllergyType.itching,
          ),
          _buildChip(
            label: '抜け毛',
            type: AllergyType.hairLoss,
            isSelected: selectedType == AllergyType.hairLoss,
          ),
          _buildChip(
            label: 'くしゃみ',
            type: AllergyType.sneezing,
            isSelected: selectedType == AllergyType.sneezing,
          ),
          _buildChip(
            label: 'その他',
            type: AllergyType.other,
            isSelected: selectedType == AllergyType.other,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required AllergyType type,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          onTypeChanged(selected ? type : null);
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.pointBrown.withValues(alpha: 0.2),
        labelStyle: AppFonts.bodyMedium.copyWith(
          color: isSelected ? AppColors.pointBrown : AppColors.pointDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected
              ? AppColors.pointBrown
              : AppColors.pointDark.withValues(alpha: 0.2),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }
}
