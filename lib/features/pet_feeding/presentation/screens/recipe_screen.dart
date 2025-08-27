import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  final String petId;

  const RecipeScreen({super.key, required this.petId});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Pet Profile',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              'Recipes',
              style: AppFonts.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // 펫 선택 드롭다운
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.pets,
                    size: 16,
                    color: AppColors.pointBrown,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Maxi',
                  style: AppFonts.bodyMedium.copyWith(color: Colors.white),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
      body: recipesAsync.when(
        data: (recipes) => GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.8,
          ),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return _buildRecipeCard(recipe);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: AppSpacing.md),
              Text(
                '레시피를 불러오는데 실패했습니다',
                style: AppFonts.bodyLarge.copyWith(color: Colors.red),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: () {
                  ref.read(recipesNotifierProvider.notifier).refresh();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // 새 레시피 추가 화면으로 이동
              _showAddRecipeDialog(context);
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add recipe',
              style: AppFonts.fredoka(
                fontSize: AppFonts.lg,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.large),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeEntity recipe) {
    return GestureDetector(
      onTap: () {
        // 레시피 상세 화면으로 이동
        _showRecipeDetailDialog(context, recipe);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 레시피 이미지
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.large),
                  ),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 40,
                  color: AppColors.pointBrown.withValues(alpha: 0.5),
                ),
              ),
            ),

            // 레시피 정보
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppFonts.titleSmall.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      recipe.description,
                      style: AppFonts.bodySmall.copyWith(
                        color: AppColors.pointDark.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.pointBlue,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          recipe.cookingTime,
                          style: AppFonts.bodySmall.copyWith(
                            color: AppColors.pointBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(
                              recipe.difficulty,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppRadius.small,
                            ),
                          ),
                          child: Text(
                            recipe.difficulty,
                            style: AppFonts.bodySmall.copyWith(
                              color: _getDifficultyColor(recipe.difficulty),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddRecipeDialog(BuildContext context) {
    // 새 레시피 추가 화면으로 이동
    context.push(AppRouter.addRecipeRoute);
  }

  void _showRecipeDetailDialog(BuildContext context, RecipeEntity recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipe.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('설명: ${recipe.description}'),
            const SizedBox(height: AppSpacing.sm),
            Text('조리시간: ${recipe.cookingTime}'),
            const SizedBox(height: AppSpacing.sm),
            Text('난이도: ${recipe.difficulty}'),
            const SizedBox(height: AppSpacing.sm),
            Text('평점: ${recipe.rating}'),
            if (recipe.ingredients.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text('재료:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...recipe.ingredients.map((ingredient) => Text('• $ingredient')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteRecipe(recipe.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _deleteRecipe(String recipeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('레시피 삭제'),
        content: const Text('이 레시피를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(recipesNotifierProvider.notifier).deleteRecipe(recipeId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
