import 'package:aipet_frontend/features/pet_registor/domain/entities/pet_profile_entity.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetNutritionTab extends ConsumerWidget {
  final PetProfileEntity pet;

  const PetNutritionTab({super.key, required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildFoodPreferencesSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildNutritionInfoSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildFeedingScheduleSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildDietaryRestrictionsSection(),
        ],
      ),
    );
  }

  Widget _buildFoodPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'フードタイプ',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildFoodTypeCard(
                icon: Icons.pets,
                title: 'ドライフード',
                isSelected: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildFoodTypeCard(
                icon: Icons.water_drop,
                title: 'ウェットフード',
                isSelected: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildFoodTypeCard(
                icon: Icons.eco,
                title: '生食',
                isSelected: false,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildFoodTypeCard(
                icon: Icons.kitchen,
                title: '手作り',
                isSelected: true,
              ),
            ),
          ],
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

  Widget _buildDietaryRestrictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '食事制限・アレルギー',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GenericInfoCard.withIcon(
          icon: Icons.warning,
          iconColor: AppColors.pointPink,
          iconBackgroundColor: AppColors.pointPink.withValues(alpha: 0.1),
          title: 'アレルギー',
          subtitle: '鶏肉、小麦',
          badge: '注意',
          badgeColor: AppColors.pointPink,
        ),
        const SizedBox(height: AppSpacing.sm),
        GenericInfoCard.withIcon(
          icon: Icons.block,
          iconColor: AppColors.pointGray,
          iconBackgroundColor: AppColors.pointGray.withValues(alpha: 0.1),
          title: '禁止食品',
          subtitle: 'チョコレート、玉ねぎ、ブドウ',
          badge: '禁止',
          badgeColor: AppColors.pointGray,
        ),
      ],
    );
  }

  Widget _buildFoodTypeCard({
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.pointBrown.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppFonts.bodySmall.copyWith(
              color: isSelected ? AppColors.pointBrown : AppColors.pointGray,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
}
