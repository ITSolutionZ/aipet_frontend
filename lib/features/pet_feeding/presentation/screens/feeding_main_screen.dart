import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';

/// 식사&급수 메인 페이지
/// 드로워에서 "食事&給水" 메뉴를 탭했을 때 이동하는 페이지
class FeedingMainScreen extends ConsumerWidget {
  const FeedingMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      appBar: AppBar(
        title: Text(
          '食事&給水',
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pointBrown,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 텍스트
            Text(
              'ペットの食事と給水を管理しましょう',
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'スケジュール設定、記録管理、分析などを通じてペットの健康を体系的に管理できます。',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 메뉴 그리드
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.schedule,
                    title: '給餌スケジュール',
                    subtitle: '食事時間と量設定',
                    color: AppColors.pointBlue,
                    onTap: () => context.go(
                      '${AppRouter.feedingScheduleRoute}?petId=default',
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.history,
                    title: '給餌記録',
                    subtitle: '食事履歴確認',
                    color: AppColors.pointGreen,
                    onTap: () => context.go(AppRouter.feedingRecordsRoute),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.analytics,
                    title: '給餌分析',
                    subtitle: '食事パターン分析',
                    color: AppColors.pointBrown,
                    onTap: () => context.go(
                      '${AppRouter.feedingAnalysisRoute}?petId=default',
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.menu_book,
                    title: 'レシピ',
                    subtitle: 'ペットフードレシピ',
                    color: AppColors.tonePeach,
                    onTap: () => context.go(AppRouter.recipesRoute),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.pointBrown,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.home,
                  label: '홈',
                  isSelected: false,
                  onTap: () => context.go(AppRouter.homeRoute),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.smart_toy,
                  label: 'AI',
                  isSelected: false,
                  onTap: () => context.go(AppRouter.aiRoute),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.calendar_today,
                  label: '캘린더',
                  isSelected: false,
                  onTap: () => context.go(AppRouter.schedulingRoute),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.notifications,
                  label: '알람',
                  isSelected: false,
                  onTap: () => context.go(AppRouter.pushNotificationRoute),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings,
                  label: '설정',
                  isSelected: false,
                  onTap: () => context.go(AppRouter.settingsRoute),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 메뉴 카드 위젯
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),

              // 제목
              Text(
                title,
                style: AppFonts.titleSmall.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),

              // 부제목
              Text(
                subtitle,
                style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 네비게이션 아이템 위젯
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.yellow : Colors.white,
            size: 24,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppFonts.bodySmall.copyWith(
              color: isSelected ? Colors.yellow : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.xs),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
