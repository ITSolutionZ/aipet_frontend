import 'package:aipet_frontend/features/ai/domain/entities/ai_category_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class AiCategorySelection extends StatelessWidget {
  final List<AiCategoryEntity> categories;
  final AiCategoryEntity? selectedCategory;
  final Function(AiCategoryEntity) onCategorySelected;

  const AiCategorySelection({
    super.key,
    required this.categories,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'どのような内容について相談しますか？',
            style: AppFonts.headlineSmall.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '相談内容のカテゴリを選択してください',
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCategoryGrid(categories),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<AiCategoryEntity> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategory?.id == category.id;

        return _buildCategoryCard(category, isSelected);
      },
    );
  }

  Widget _buildCategoryCard(AiCategoryEntity category, bool isSelected) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${category.name}カテゴリ: ${category.description}',
      hint: isSelected ? '選択済み' : 'タップして選択',
      child: GestureDetector(
        onTap: () => onCategorySelected(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? category.color.withValues(alpha: 0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? category.color : AppColors.pointGray.withValues(alpha: 0.3),
              width: isSelected ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: category.color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.name,
                      style: AppFonts.bodyMedium.copyWith(
                        color: isSelected ? category.color : AppColors.pointDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      category.description,
                      style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
