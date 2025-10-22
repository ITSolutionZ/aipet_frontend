import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 알레르기 필터 선택 섹션
class AllergyFilterSection extends StatelessWidget {
  final PetProfileEntity? selectedPet;
  final bool? selectedFilter;
  final Function(bool) onFilterSelected;
  final Function(bool) onNavigateToProductSelection;

  const AllergyFilterSection({
    super.key,
    required this.selectedPet,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onNavigateToProductSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              context,
              label: 'アレルギー あった',
              isSelected: selectedFilter == true,
              color: const Color(0xFFFF6B9D),
              onTap: () {
                onFilterSelected(true);
                if (selectedPet != null) {
                  onNavigateToProductSelection(true);
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildFilterButton(
              context,
              label: 'アレルギー なかった',
              isSelected: selectedFilter == false,
              color: const Color(0xFF4CAF50),
              onTap: () {
                onFilterSelected(false);
                if (selectedPet != null) {
                  onNavigateToProductSelection(false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected
                ? color
                : AppColors.pointDark.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(Icons.add, color: color, size: 32),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppFonts.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
