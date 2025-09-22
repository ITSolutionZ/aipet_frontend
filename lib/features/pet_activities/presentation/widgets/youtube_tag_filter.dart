import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// YouTube 영상 태그 필터
class YouTubeTagFilter extends StatelessWidget {
  final Set<String> allTags;
  final List<String> selectedTags;
  final ValueChanged<String> onTagToggle;

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
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allTags.length,
        itemBuilder: (context, index) {
          final tag = allTags.elementAt(index);
          final isSelected = selectedTags.contains(tag);

          return Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) => onTagToggle(tag),
              selectedColor: AppColors.pointBrown.withValues(alpha: 0.2),
              checkmarkColor: AppColors.pointBrown,
            ),
          );
        },
      ),
    );
  }
}