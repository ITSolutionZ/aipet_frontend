import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 음식 타입 선택 카드
class FoodTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const FoodTypeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pointBrown.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected
                ? AppColors.pointBrown
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.pointBrown.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.pointBrown : Colors.grey,
                size: 30,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppFonts.bodyMedium.copyWith(
                color: isSelected ? AppColors.pointBrown : AppColors.pointDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 영양 관리 아이템 카드
class NutritionItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const NutritionItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pointBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.pointBlue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 예약된 식사 카드
class ScheduledMealCard extends StatelessWidget {
  final String title;
  final String schedule;
  final String time;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  const ScheduledMealCard({
    super.key,
    required this.title,
    required this.schedule,
    required this.time,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      schedule,
                      style: AppFonts.bodyMedium.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      time,
                      style: AppFonts.bodyMedium.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: AppColors.pointBlue,
          ),
        ],
      ),
    );
  }
}

/// 🎯 Nutrition Tab State Provider
final nutritionTabProvider =
    StateNotifierProvider.family<
      NutritionTabController,
      NutritionTabState,
      String
    >((ref, petId) => NutritionTabController());

class NutritionTabController extends StateNotifier<NutritionTabState> {
  NutritionTabController() : super(const NutritionTabState());

  void selectFoodType(String foodType) {
    state = state.copyWith(selectedFoodType: foodType);
  }

  void toggleMealSchedule(String mealType, bool isEnabled) {
    final updatedSchedules = Map<String, bool>.from(state.mealSchedules);
    updatedSchedules[mealType] = isEnabled;
    state = state.copyWith(mealSchedules: updatedSchedules);
  }
}

class NutritionTabState {
  final String selectedFoodType;
  final Map<String, bool> mealSchedules;

  const NutritionTabState({
    this.selectedFoodType = 'kibble',
    this.mealSchedules = const {'breakfast': true, 'dinner': true},
  });

  NutritionTabState copyWith({
    String? selectedFoodType,
    Map<String, bool>? mealSchedules,
  }) {
    return NutritionTabState(
      selectedFoodType: selectedFoodType ?? this.selectedFoodType,
      mealSchedules: mealSchedules ?? this.mealSchedules,
    );
  }
}

/// 영양 탭 전체 위젯
class NutritionTab extends ConsumerWidget {
  final String petId;

  const NutritionTab({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionTabProvider(petId));
    final notifier = ref.read(nutritionTabProvider(petId).notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 음식 타입 카드
          Row(
            children: [
              Expanded(
                child: FoodTypeCard(
                  icon: Icons.eco,
                  title: 'Kibble / Dry',
                  isSelected: state.selectedFoodType == 'kibble',
                  onTap: () => notifier.selectFoodType('kibble'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FoodTypeCard(
                  icon: Icons.restaurant,
                  title: 'Home cooked',
                  isSelected: state.selectedFoodType == 'homemade',
                  onTap: () => notifier.selectFoodType('homemade'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // 레시피 및 음식 일지
          NutritionItemCard(
            icon: Icons.book,
            title: 'Recipes',
            iconColor: AppColors.pointBlue,
            onTap: () {
              // 레시피 화면으로 이동
            },
          ),
          const SizedBox(height: AppSpacing.md),
          NutritionItemCard(
            icon: Icons.pets,
            title: 'Food Journal',
            iconColor: Colors.orange,
            onTap: () {
              // 음식 일지 화면으로 이동
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // 예약된 식사
          Text(
            'Scheduled Meals',
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          ScheduledMealCard(
            title: 'Breakfast',
            schedule: 'everyday',
            time: '10:00',
            isEnabled: state.mealSchedules['breakfast'] ?? false,
            onToggle: (value) {
              notifier.toggleMealSchedule('breakfast', value);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ScheduledMealCard(
            title: 'Dinner',
            schedule: 'everyday',
            time: '20:00',
            isEnabled: state.mealSchedules['dinner'] ?? false,
            onToggle: (value) {
              notifier.toggleMealSchedule('dinner', value);
            },
          ),
        ],
      ),
    );
  }
}
