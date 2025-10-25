import 'dart:math' show pow;

import 'package:aipet_frontend/features/daily/data/datasources/pet_food_local_datasource.dart';
import 'package:aipet_frontend/features/daily/presentation/widgets/searchable_dropdown.dart'
    as daily;
import 'package:aipet_frontend/features/pet_profile/presentation/controllers/pet_profile_unified_controller.dart';
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
  void didUpdateWidget(PetNutritionTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // pet이 변경되었거나 편집 모드가 종료되면 controller 업데이트
    if (oldWidget.pet.id != widget.pet.id ||
        (oldWidget.isEditMode && !widget.isEditMode)) {
      final additionalInfo = widget.pet.additionalInfo ?? {};
      final food = additionalInfo['food'] as String? ?? '';
      final supplement = additionalInfo['supplement'] as String? ?? '';
      final treat = additionalInfo['treat'] as String? ?? '';

      LoggerService.debug('🔄 영양 탭 데이터 갱신:');
      LoggerService.debug('   - food: "$food"');
      LoggerService.debug('   - supplement: "$supplement"');
      LoggerService.debug('   - treat: "$treat"');

      _foodController.text = food;
      _supplementController.text = supplement;
      _treatController.text = treat;
    }
  }

  void _updateAdditionalInfo(String key, String value) {
    LoggerService.debug('📝 영양 정보 업데이트: $key = "$value"');
    ref
        .read(petProfileUnifiedControllerProvider.notifier)
        .updateFormData(key, value);
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
              // editFormData에 반영
              _updateAdditionalInfo('food', value);
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
              // editFormData에 반영
              _updateAdditionalInfo('supplement', value);
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
              // editFormData에 반영
              _updateAdditionalInfo('treat', value);
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
                    color: hasValue ? AppColors.pointDark : AppColors.pointGray,
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
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
    final additionalInfo = widget.pet.additionalInfo ?? {};

    // 1일 필요 칼로리 계산 또는 로드
    final dailyCalories = _calculateDailyCalories(additionalInfo);

    // 단백질 비율 로드 (기본값: 25%)
    final proteinPercentage =
        additionalInfo['proteinPercentage'] as num? ?? 25;

    // 1일 필요 수분량 계산 또는 로드
    final dailyWater = _calculateDailyWater(additionalInfo);

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
          value: '$dailyCalories kcal',
          iconColor: AppColors.pointBrown,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildNutritionItem(
          icon: Icons.fitness_center,
          title: 'タンパク質',
          value: '$proteinPercentage%',
          iconColor: AppColors.pointBlue,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildNutritionItem(
          icon: Icons.water,
          title: '水分',
          value: '$dailyWater L/日',
          iconColor: AppColors.pointBlue,
        ),
      ],
    );
  }

  /// 1일 필요 칼로리 계산
  /// additionalInfo에 저장된 값이 있으면 사용, 없으면 체중 기반으로 자동 계산
  int _calculateDailyCalories(Map<String, dynamic> additionalInfo) {
    // 저장된 값이 있으면 우선 사용
    if (additionalInfo.containsKey('dailyCalories')) {
      final savedCalories = additionalInfo['dailyCalories'];
      if (savedCalories is num) {
        return savedCalories.toInt();
      }
    }

    // 체중 기반 자동 계산
    final weightInKg = widget.pet.weight > 0 ? widget.pet.weight : 5.0;

    // RER (Resting Energy Requirement) = 70 × (체중kg)^0.75
    // 일반 성견의 경우: RER × 1.6
    final rer = 70 * pow(weightInKg, 0.75);
    final dailyCalories = (rer * 1.6).round();

    LoggerService.debug(
      '📊 칼로리 자동 계산: 체중 ${weightInKg}kg → ${dailyCalories}kcal',
    );

    return dailyCalories;
  }

  /// 1일 필요 수분량 계산
  /// additionalInfo에 저장된 값이 있으면 사용, 없으면 체중 기반으로 자동 계산
  String _calculateDailyWater(Map<String, dynamic> additionalInfo) {
    // 저장된 값이 있으면 우선 사용
    if (additionalInfo.containsKey('dailyWater')) {
      final savedWater = additionalInfo['dailyWater'];
      if (savedWater is num) {
        return savedWater.toStringAsFixed(1);
      }
      if (savedWater is String) {
        return savedWater;
      }
    }

    // 체중 기반 자동 계산: 일반적으로 체중 1kg당 50-60ml
    final weightInKg = widget.pet.weight > 0 ? widget.pet.weight : 5.0;
    final waterInLiters = (weightInKg * 55 / 1000); // 55ml/kg → L로 변환

    LoggerService.debug(
      '💧 수분량 자동 계산: 체중 ${weightInKg}kg → ${waterInLiters.toStringAsFixed(1)}L',
    );

    return waterInLiters.toStringAsFixed(1);
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
