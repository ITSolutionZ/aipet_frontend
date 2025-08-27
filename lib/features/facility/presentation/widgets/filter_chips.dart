import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class FilterChips extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const FilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('全て', Icons.list),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('お気に入り', Icons.favorite),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip('履歴', Icons.history),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = currentFilter == label;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppFonts.bodySmall.copyWith(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(label);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
    );
  }
}
