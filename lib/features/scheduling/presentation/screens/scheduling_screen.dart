import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';

/// 스케줄링 메인 화면
/// 식사, 학습, 급수 카테고리와 알람 설정을 제공합니다.
class SchedulingScreen extends ConsumerStatefulWidget {
  const SchedulingScreen({super.key});

  @override
  ConsumerState<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends ConsumerState<SchedulingScreen> {
  bool _isAlarmEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スケジュール管理'),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 알람 설정 섹션
            _buildAlarmSection(),

            const SizedBox(height: AppSpacing.lg),

            // 카테고리 섹션
            _buildCategorySection(),
          ],
        ),
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
                  Text('アラーム設定', style: AppFonts.titleMedium),
                  Text(
                    'スケジュール通知を受け取りますか？',
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
                      _isAlarmEnabled ? 'アラームを有効にしました' : 'アラームを無効にしました',
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
              title: '食事',
              subtitle: '給餌スケジュール',
              color: AppColors.pointGreen,
              onTap: () => context.go(AppRouter.feedingMainRoute),
            ),
            _buildCategoryCard(
              icon: Icons.school,
              title: '学習',
              subtitle: 'トレーニング',
              color: AppColors.pointBlue,
              onTap: () => context.go(AppRouter.trainingMainRoute),
            ),
            _buildCategoryCard(
              icon: Icons.water_drop,
              title: '給水',
              subtitle: '水分補給',
              color: AppColors.tonePeach,
              onTap: () => context.go(AppRouter.wateringMainRoute),
            ),
            _buildCategoryCard(
              icon: Icons.medical_services,
              title: '健康',
              subtitle: '健康管理',
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
                  color: color.withOpacity(0.1),
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
