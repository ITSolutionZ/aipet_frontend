import 'package:aipet_frontend/features/daily/data/datasources/pet_food_local_datasource.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/searchable_dropdown.dart'
    as daily;
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetNutritionTab extends ConsumerStatefulWidget {
  final PetProfileEntity pet;
  final bool isEditMode;

  const PetNutritionTab({
    super.key,
    required this.pet,
    this.isEditMode = false,
  });

  @override
  ConsumerState<PetNutritionTab> createState() => _PetNutritionTabState();
}

class _PetNutritionTabState extends ConsumerState<PetNutritionTab> {
  late TextEditingController _foodController;
  late TextEditingController _supplementController;
  late TextEditingController _treatController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final additionalInfo = widget.pet.additionalInfo ?? {};
    final food = additionalInfo['food'] as String? ?? '';
    final supplement = additionalInfo['supplement'] as String? ?? '';
    final treat = additionalInfo['treat'] as String? ?? '';

    _foodController = TextEditingController(text: food);
    _supplementController = TextEditingController(text: supplement);
    _treatController = TextEditingController(text: treat);

    LoggerService.debug('🍽️ PetNutritionTab - 保存された食事情報:');
    LoggerService.debug('   - pet.name: ${widget.pet.name}');
    LoggerService.debug('   - pet.id: ${widget.pet.id}');
    LoggerService.debug('   - additionalInfo (전체): $additionalInfo');
    LoggerService.debug(
      '   - additionalInfo.keys: ${additionalInfo.keys.toList()}',
    );
    LoggerService.debug('   - food: "$food" (길이: ${food.length})');
    LoggerService.debug(
      '   - supplement: "$supplement" (길이: ${supplement.length})',
    );
    LoggerService.debug('   - treat: "$treat" (길이: ${treat.length})');
  }

  @override
  void dispose() {
    _foodController.dispose();
    _supplementController.dispose();
    _treatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final additionalInfo = widget.pet.additionalInfo ?? {};
    final forbiddenIngredients =
        (additionalInfo['forbiddenIngredients'] as List<dynamic>?)
            ?.cast<String>() ??
        [];

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
          _buildDietaryRestrictionsSection(forbiddenIngredients),
        ],
      ),
    );
  }

  Widget _buildFoodPreferencesSection() {
    if (widget.isEditMode) {
      // 편집 모드: SearchableDropdown 사용
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          daily.SearchableDropdown(
            title: '食べる餌',
            selectedValue: _foodController.text,
            options: PetFoodLocalDatasource.foods,
            onChanged: (value) {
              setState(() {
                _foodController.text = value;
              });
            },
            icon: PetFoodLocalDatasource.getCategoryIcons()['food']!,
            hintText: '餌を検索または選択してください',
          ),
          const SizedBox(height: AppSpacing.md),
          daily.SearchableDropdown(
            title: '食べる栄養剤',
            selectedValue: _supplementController.text,
            options: PetFoodLocalDatasource.supplements,
            onChanged: (value) {
              setState(() {
                _supplementController.text = value;
              });
            },
            icon: PetFoodLocalDatasource.getCategoryIcons()['supplement']!,
            hintText: '栄養剤を検索または選択してください',
          ),
          const SizedBox(height: AppSpacing.md),
          daily.SearchableDropdown(
            title: '食べるおやつ',
            selectedValue: _treatController.text,
            options: PetFoodLocalDatasource.treats,
            onChanged: (value) {
              setState(() {
                _treatController.text = value;
              });
            },
            icon: PetFoodLocalDatasource.getCategoryIcons()['treat']!,
            hintText: 'おやつを検索または選択してください',
          ),
        ],
      );
    }

    // 보기 모드: 읽기 전용 카드 표시
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '食事情報',
          style: AppFonts.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.pointDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildReadOnlyFoodField(
          controller: _foodController,
          icon: Icons.restaurant,
          label: '食べる餌',
          hint: '餌を検索または選択してください',
          iconColor: AppColors.pointBrown,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildReadOnlyFoodField(
          controller: _supplementController,
          icon: Icons.medical_services,
          label: '食べる栄養剤',
          hint: '栄養剤を検索または選択してください',
          iconColor: AppColors.pointBlue,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildReadOnlyFoodField(
          controller: _treatController,
          icon: Icons.cake,
          label: '食べるおやつ',
          hint: 'おやつを検索または選択してください',
          iconColor: AppColors.pointPink,
        ),
      ],
    );
  }

  Widget _buildReadOnlyFoodField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    required Color iconColor,
  }) {
    final hasValue = controller.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.pointGray.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  hasValue ? controller.text : hint,
                  style: AppFonts.bodyMedium.copyWith(
                    color: hasValue
                        ? AppColors.pointDark
                        : AppColors.pointGray,
                    fontWeight: hasValue
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (hasValue)
            const Icon(
              Icons.check_circle,
              color: AppColors.pointGreen,
              size: 20,
            ),
        ],
      ),
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
}
