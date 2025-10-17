import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// YouTube 태그 필터
class YouTubeTagFilter extends StatelessWidget {
  final Set<String> allTags;
  final List<String> selectedTags;
  final Function(String) onTagToggle;

  const YouTubeTagFilter({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onTagToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (allTags.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'タグでフィルター',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: allTags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    final isSelected = selectedTags.contains(tag);

    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      onSelected: (selected) => onTagToggle(tag),
      selectedColor: AppColors.pointBlue.withValues(alpha: 0.2),
      checkmarkColor: AppColors.pointBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.pointBlue : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
