import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';

/// 식사&급수 메인 페이지
/// 드로워에서 "食事&給水" 메뉴를 탭했을 때 이동하는 페이지
class FeedingMainScreen extends ConsumerWidget {
  final bool showBackButton;

  const FeedingMainScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.pointOffWhite,
      drawer: showBackButton ? null : const AppDrawer(),
      appBar: showBackButton
          ? _buildBackAppBar()
          : _buildDrawerAppBar(),
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

            // 메뉴 리스트
            Expanded(
              child: ListView(
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
                  const SizedBox(height: AppSpacing.md),
                  _buildMenuCard(
                    context,
                    icon: Icons.history,
                    title: '給餌記録',
                    subtitle: '食事履歴確認',
                    color: AppColors.pointGreen,
                    onTap: () => context.go(AppRouter.feedingRecordsRoute),
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                  const SizedBox(height: AppSpacing.md),
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
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: showBackButton ? -1 : 0, // 홈에서 접근 시 선택 없음, drawer에서 접근 시 홈 선택
        onItemTapped: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/ai');
              break;
            case 2:
              context.go('/scheduling');
              break;
            case 3:
              context.go('/settings/push-notification');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
      ),
    );
  }

  /// 뒤로가기 버튼이 있는 AppBar (홈에서 접근 시)
  PreferredSizeWidget _buildBackAppBar() {
    return const BackAppBar(title: '食事&給水');
  }

  /// Drawer가 있는 AppBar (drawer에서 접근 시)
  PreferredSizeWidget _buildDrawerAppBar() {
    return const DrawerAppBar(title: '食事&給水');
  }

  /// 메뉴 카드 위젯 (세로 레이아웃)
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
          child: Row(
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
              const SizedBox(width: AppSpacing.lg),

              // 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.titleSmall.copyWith(
                        color: AppColors.pointDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 화살표 아이콘
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.pointGray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
