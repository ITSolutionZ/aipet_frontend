import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/facility.dart';

class FacilityTypeFilter extends StatelessWidget {
  final dynamic selectedType;
  final Function(dynamic) onTypeSelected;

  const FacilityTypeFilter({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          // 전체 필터
          _buildFilterChip(
            icon: Icons.all_inclusive,
            label: '全て',
            color: AppColors.pointBrown,
            isSelected: selectedType == null,
            onTap: () => onTypeSelected(null),
          ),
          const SizedBox(width: AppSpacing.xs),

          // 동물병원
          _buildFilterChip(
            icon: Icons.medical_services,
            label: '動物病院',
            color: Colors.red,
            isSelected: selectedType == FacilityType.hospital,
            onTap: () => onTypeSelected(FacilityType.hospital),
          ),
          const SizedBox(width: AppSpacing.xs),

          // 트리밍샵
          _buildFilterChip(
            icon: Icons.content_cut,
            label: 'トリミング',
            color: Colors.purple,
            isSelected: selectedType == FacilityType.grooming,
            onTap: () => onTypeSelected(FacilityType.grooming),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 18),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppFonts.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.pointDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
