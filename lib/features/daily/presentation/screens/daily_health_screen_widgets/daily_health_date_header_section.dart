import 'package:aipet_frontend/features/daily/data/providers/weekly_task_provider.dart';
import 'package:aipet_frontend/features/daily/presentation/controllers/daily_health_screen_controller.dart';
import 'package:aipet_frontend/features/daily/presentation/logic/daily_health_logic.dart';
import 'package:aipet_frontend/features/pet_profile/data/providers/pet_profile_providers.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Daily Health 화면 날짜 헤더 섹션
class DailyHealthDateHeaderSection extends ConsumerWidget {
  final DailyHealthLogic logic;

  const DailyHealthDateHeaderSection({
    super.key,
    required this.logic,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final formattedDate = logic.formatDate(today);
    final weekday = logic.getWeekdayName(today.weekday);
    final screenData = ref.watch(dailyHealthScreenControllerProvider);
    final petsAsync = ref.watch(petProfilesProvider);

    return petsAsync.when(
      data: (pets) {
        String petType = 'dog';
        int weekOfYear = _getWeekOfYear(today);

        if (pets.isNotEmpty && screenData.selectedPetId != null) {
          final selectedPet = pets.firstWhere(
            (pet) => pet.id == screenData.selectedPetId,
            orElse: () => pets.first,
          );
          petType = selectedPet.type;
          weekOfYear = _getWeeksSinceBirth(selectedPet.birthDate, today);
        }

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedDate,
                      style: AppFonts.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildWeeklyTaskRow(ref, petType, weekOfYear),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                weekday,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildLoadingHeader(formattedDate, weekday),
      error: (error, stack) => _buildErrorHeader(formattedDate, weekday, today),
    );
  }

  Widget _buildWeeklyTaskRow(WidgetRef ref, String petType, int weekOfYear) {
    final weeklyTaskAsync = ref.watch(
      weeklyTasksProvider(petType: petType, weekOfYear: weekOfYear),
    );

    return weeklyTaskAsync.when(
      data: (task) {
        final normalizedTask = task.replaceAll('\\n', ' ').replaceAll('\n', ' ');
        return Row(
          children: [
            Text(
              '$weekOfYear週目 : ',
              style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            Expanded(
              child: Text(
                normalizedTask,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Text(
            '$weekOfYear週目 : ',
            style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
      error: (error, stack) => Text(
        '$weekOfYear週目',
        style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildLoadingHeader(String formattedDate, String weekday) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedDate,
                  style: AppFonts.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 20, child: CircularProgressIndicator()),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            weekday,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorHeader(
    String formattedDate,
    String weekday,
    DateTime today,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedDate,
                  style: AppFonts.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) => _buildWeeklyTaskRow(
                    ref,
                    'dog',
                    _getWeekOfYear(today),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            weekday,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 해당 날짜가 그 해의 몇 번째 주인지 계산
  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    final firstDayWeekday = firstDayOfYear.weekday;
    final daysInFirstWeek = 8 - firstDayWeekday;

    if (daysSinceFirstDay < daysInFirstWeek) {
      return 1;
    } else {
      return ((daysSinceFirstDay - daysInFirstWeek) / 7).ceil() + 1;
    }
  }

  /// 펫의 생일부터 현재까지의 주차 계산
  int _getWeeksSinceBirth(DateTime birthDate, DateTime currentDate) {
    final thisYearBirthday = DateTime(
      currentDate.year,
      birthDate.month,
      birthDate.day,
    );

    final referenceBirthday = currentDate.isBefore(thisYearBirthday)
        ? DateTime(currentDate.year - 1, birthDate.month, birthDate.day)
        : thisYearBirthday;

    final daysSinceBirth = currentDate.difference(referenceBirthday).inDays;
    return (daysSinceBirth / 7).floor() + 1;
  }
}

