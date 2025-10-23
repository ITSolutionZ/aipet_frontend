import 'package:aipet_frontend/shared/domain/entities/entities.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetNutritionTab extends ConsumerWidget {
  final PetProfileEntity pet;

  const PetNutritionTab({super.key, required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 保存された食事情報を取得
    final additionalInfo = pet.additionalInfo ?? {};
    final food = additionalInfo['food'] as String? ?? '';
    final supplement = additionalInfo['supplement'] as String? ?? '';
    final treat = additionalInfo['treat'] as String? ?? '';
    final forbiddenIngredients =
        (additionalInfo['forbiddenIngredients'] as List<dynamic>?)
            ?.cast<String>() ??
        [];

    LoggerService.debug('🍽️ PetNutritionTab - 保存された食事情報:');
    LoggerService.debug('   - food: $food');
    LoggerService.debug('   - supplement: $supplement');
    LoggerService.debug('   - treat: $treat');
    LoggerService.debug('   - forbiddenIngredients: $forbiddenIngredients');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildFoodPreferencesSection(food, supplement, treat),
          const SizedBox(height: AppSpacing.lg),
          _buildNutritionInfoSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildFeedingScheduleSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildDietaryRestrictionsSection(forbiddenIngredients),
        ],
      ),
    );
  }

  Widget _buildFoodPreferencesSection(
    String food,
    String supplement,
    String treat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '食べる餌',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildFoodItem(
          icon: Icons.restaurant,
          title: '食べる餌',
          value: food.isEmpty ? '餌を検索または選択してください' : food,
          isEmpty: food.isEmpty,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildFoodItem(
          icon: Icons.medical_services,
          title: '食べる栄養剤',
          value: supplement.isEmpty ? '栄養剤を検索または選択してください' : supplement,
          isEmpty: supplement.isEmpty,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildFoodItem(
          icon: Icons.cake,
          title: '食べるおやつ',
          value: treat.isEmpty ? 'おやつを検索または選択してください' : treat,
          isEmpty: treat.isEmpty,
        ),
      ],
    );
  }

  Widget _buildNutritionInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '栄養情報',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildNutritionItem(
          icon: Icons.speed,
          title: '1日の必要カロリー',
          value: '800 kcal',
          iconColor: AppColors.pointBrown,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildNutritionItem(
          icon: Icons.fitness_center,
          title: 'タンパク質',
          value: '25%',
          iconColor: AppColors.pointBlue,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildNutritionItem(
          icon: Icons.water,
          title: '水分',
          value: '1.2L/日',
          iconColor: AppColors.pointBlue,
        ),
      ],
    );
  }

  Widget _buildFeedingScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '給餌スケジュール',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildScheduledMealCard(
          title: '朝食',
          schedule: '毎日',
          time: '7:00',
          amount: '200g',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildScheduledMealCard(
          title: '昼食',
          schedule: '毎日',
          time: '12:00',
          amount: '150g',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildScheduledMealCard(
          title: '夕食',
          schedule: '毎日',
          time: '18:00',
          amount: '200g',
        ),
      ],
    );
  }

  Widget _buildDietaryRestrictionsSection(List<String> forbiddenIngredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '食べてはいけない原料',
              style: AppFonts.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.pointDark,
              ),
            ),
            Text(
              '${forbiddenIngredients.length}/8',
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (forbiddenIngredients.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pointOffWhite,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: AppColors.pointGray.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppColors.pointGray.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'まだ原料が登録されていません',
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'ペットが食べてはいけない原料を登録してください。最大8個まで登録できます。',
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...forbiddenIngredients.map(
            (ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GenericInfoCard.withIcon(
                icon: Icons.warning,
                iconColor: AppColors.pointPink,
                iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
                title: ingredient,
                subtitle: '禁止原料',
                badge: '禁止',
                badgeColor: AppColors.pointPink,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNutritionItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return GenericInfoCard.withIcon(
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconColor.withValues(alpha: 0.1),
      title: title,
      subtitle: value,
    );
  }

  Widget _buildScheduledMealCard({
    required String title,
    required String schedule,
    required String time,
    required String amount,
  }) {
    return GenericInfoCard.withIcon(
      icon: Icons.schedule,
      iconColor: AppColors.pointGreen,
      iconBackgroundColor: AppColors.pointGreen.withValues(alpha: 0.1),
      title: title,
      subtitle: '$schedule • $time',
      badge: amount,
      badgeColor: AppColors.pointBrown,
    );
  }

  Widget _buildFoodItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isEmpty,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isEmpty ? AppColors.pointOffWhite : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isEmpty
              ? AppColors.pointGray.withValues(alpha: 0.3)
              : AppColors.pointBrown.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isEmpty ? AppColors.pointGray : AppColors.pointBrown,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppFonts.bodyMedium.copyWith(
                    color: isEmpty ? AppColors.pointGray : AppColors.pointDark,
                    fontWeight: isEmpty ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isEmpty)
            const Icon(
              Icons.check_circle,
              color: AppColors.pointGreen,
              size: 20,
            ),
        ],
      ),
    );
  }
}
