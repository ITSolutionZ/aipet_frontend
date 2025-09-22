import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 트릭 검색 및 필터 섹션
class TricksSearchAndFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;

  const TricksSearchAndFilter({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // 검색 바
          _SearchBar(
            controller: searchController,
            searchQuery: searchQuery,
            onChanged: onSearchChanged,
          ),

          const SizedBox(height: AppSpacing.md),

          // 카테고리 필터
          _CategoryFilter(
            selectedCategory: selectedCategory,
            onCategoryChanged: onCategoryChanged,
          ),
        ],
      ),
    );
  }
}

/// 검색바 위젯
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'トリックを検索...',
        prefixIcon: const Icon(Icons.search, color: AppColors.pointDark),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.pointDark),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

/// 카테고리 필터 위젯
class _CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const _CategoryFilter({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    const categories = [
      {'key': 'all', 'label': 'すべて'},
      {'key': 'easy', 'label': '簡単'},
      {'key': 'medium', 'label': '普通'},
      {'key': 'hard', 'label': '難しい'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category['key'];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(
                category['label']!,
                style: AppFonts.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.pointDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.pointBrown,
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                onCategoryChanged(category['key']!);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.pointBrown
                      : AppColors.pointDark.withValues(alpha: 0.2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}