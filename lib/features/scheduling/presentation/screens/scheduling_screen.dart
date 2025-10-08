import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 스케줄링 메인 화면
/// 식사, 학습, 급수 카테고리와 알람 설정을 제공합니다.
class SchedulingScreen extends ConsumerStatefulWidget {
  const SchedulingScreen({super.key});

  @override
  ConsumerState<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends ConsumerState<SchedulingScreen> {
  bool _isAlarmEnabled = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: DynamicAppBarStyles.brown(
        scrollController: _scrollController,
        title: 'スケジュール管理',
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 알람 설정 섹션
                _buildAlarmSection(),

                const SizedBox(height: AppSpacing.lg),

                // 카테고리 섹션
                _buildCategorySection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// 알람 설정 섹션
  Widget _buildAlarmSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.alarm, color: AppColors.pointBrown, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppTexts.alarmSettings, style: AppFonts.titleMedium),
                  Text(
                    AppTexts.scheduleNotification,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isAlarmEnabled,
              onChanged: (value) {
                setState(() {
                  _isAlarmEnabled = value;
                });
                // TODO: 알람 설정 저장 로직 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isAlarmEnabled
                          ? AppTexts.alarmEnabled
                          : AppTexts.alarmDisabled,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 섹션
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('カテゴリー', style: AppFonts.titleLarge),
        const SizedBox(height: AppSpacing.md),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          children: [
            _buildCategoryCard(
              icon: Icons.restaurant,
              title: AppTexts.feedingSchedule,
              subtitle: AppTexts.feedingScheduleDescription,
              color: AppColors.pointGreen,
              onTap: () => context.go(AppRouter.feedingMainRoute),
            ),
            _buildCategoryCard(
              icon: Icons.school,
              title: AppTexts.training,
              subtitle: AppTexts.trainingDescription,
              color: AppColors.pointBlue,
              onTap: () => context.go(AppRouter.trainingMainRoute),
            ),
            _buildCategoryCard(
              icon: Icons.water_drop,
              title: AppTexts.watering,
              subtitle: AppTexts.wateringDescription,
              color: AppColors.tonePeach,
              onTap: () => context.go(AppRouter.wateringMainRoute),
            ),
            _buildCategoryCard(
              icon: Icons.medical_services,
              title: AppTexts.healthManagement,
              subtitle: AppTexts.healthManagementDescription,
              color: AppColors.pointBrown,
              onTap: () => context.go(AppRouter.healthMainRoute),
            ),
          ],
        ),
      ],
    );
  }

  /// 카테고리 카드
  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppFonts.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
