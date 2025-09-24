import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class FacilityFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FacilityFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.pointBrown.withValues(alpha: 0.2),
      checkmarkColor: AppColors.pointBrown,
    );
  }
}
