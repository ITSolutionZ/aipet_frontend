import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 트릭 검색 및 필터 위젯
class TricksSearchAndFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedCategory;
  final Function(String) onSearchChanged;
  final Function(String) onCategoryChanged;

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
      padding: const const const EdgeInsets.all(AppSpacing.lg),
      color: Colors.white,
      child: Column(
        children: [
          // 검색 바
          _buildSearchBar(),
          const const const SizedBox(height: AppSpacing.md),

          // 카테고리 필터
          _buildCategoryFilter(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'トリックを検索...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  searchController.clear();
                  onSearchChanged('');
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.md)),
          borderSide: BorderSide(color: AppColors.borderGray),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSpacing.md)),
          borderSide: BorderSide(color: AppColors.pointGreen),
        ),
        contentPadding: const const const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'key': 'all', 'label': 'すべて'},
      {'key': 'easy', 'label': '簡単'},
      {'key': 'medium', 'label': '普通'},
      {'key': 'hard', 'label': '難しい'},
      {'key': 'expert', 'label': '専門家'},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['key'];

          return Padding(
            padding: const const const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(category['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onCategoryChanged(category['key']!);
                }
              },
              selectedColor: AppColors.pointGreen.withValues(alpha: 0.2),
              checkmarkColor: AppColors.pointGreen,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.pointGreen
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}
