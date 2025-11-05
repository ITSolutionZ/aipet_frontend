import 'package:flutter/material.dart';


import '../../../../../shared/shared.dart';
/// 生食入力タブウィジェット
///
/// 生食用食材を入力して管理する専用タブ
class RawFoodInputTab extends StatelessWidget {
  final List<String> ingredients;
  final Function(int) onRemove;
  final Function(String) onSelect;

  const RawFoodInputTab({
    super.key,
    required this.ingredients,
    required this.onRemove,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // 案内メッセージ
          _buildInfoMessage(),
          const SizedBox(height: AppSpacing.lg),

          // 追加された生食材料リスト
          Expanded(child: _buildIngredientsList()),
        ],
      ),
    );
  }

  /// 案内メッセージ
  Widget _buildInfoMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pointOffWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.pointBrown.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.restaurant,
            color: AppColors.pointBrown,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '生食用食材を入力してください',
            style: AppFonts.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.pointDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '例: チーズ、にんじん、牛乳、りんごなど',
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointGray,
            ),
          ),
        ],
      ),
    );
  }

  /// 食材リスト
  Widget _buildIngredientsList() {
    if (ingredients.isEmpty) {
      return Center(
        child: Text(
          'まだ食材が追加されていません',
          style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
        ),
      );
    }

    return ListView.builder(
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: AppColors.pointBrown.withValues(alpha: 0.3),
            ),
          ),
          child: ListTile(
            leading: const Icon(Icons.restaurant, color: AppColors.pointBrown),
            title: Text(
              ingredient,
              style: AppFonts.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.pointDark,
              ),
            ),
            trailing: IconButton(
              onPressed: () => onRemove(index),
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.pointGray,
              ),
            ),
            onTap: () => onSelect(ingredient),
          ),
        );
      },
    );
  }
}
