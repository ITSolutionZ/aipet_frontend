import 'package:aipet_frontend/features/settings/presentation/controllers/user_profile_controller.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 홈 화면용 커스텀 앱바
/// 스크롤에 따라 투명에서 흰색으로 변하며 배너 이미지를 랜덤으로 표시
class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final double scrollOffset;
  final bool isDrawerOpen;
  final VoidCallback? onMenuTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onNotificationTap;

  const HomeAppBar({
    super.key,
    this.scrollOffset = 0.0,
    this.isDrawerOpen = false,
    this.onMenuTap,
    this.onFavoriteTap,
    this.onNotificationTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileControllerProvider);

    // 프로필이 로드되지 않았으면 로드
    if (profileState.profile == null && !profileState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userProfileControllerProvider.notifier).loadProfile();
      });
    }

    final userName = profileState.profile?.userName ?? 'ゲストユーザー';
    // 배너 높이 계산 (화면 높이의 26% + 상태바 + 앱바 높이)
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bannerHeight = screenHeight * 0.26 + statusBarHeight + 56.0;

    return Container(
      height:
          preferredSize.height +
          MediaQuery.of(context).padding.top, // 상태바 높이 포함
      decoration: BoxDecoration(
        gradient: scrollOffset <= statusBarHeight
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.transparent],
              ) // 초기 상태: 완전 투명
            : scrollOffset > (bannerHeight * 0.9)
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white],
                stops: [0.0, 0.95],
              ) // 스크롤 완료: 흰색 그라데이션
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(
                    alpha: (scrollOffset / bannerHeight) * 0.8,
                  ),
                ],
              ), // 스크롤 중: 투명에서 흰색으로 점진적 변화
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 왼쪽 - ドロワーが開いている時はユーザー名と情報修正ボタン、閉じている時はハンバーガー
              if (isDrawerOpen)
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: AppColors.pointDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () {
                        // プロフィール編集画面へ遷移
                        context.push('/settings/profile-edit');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '情報修正',
                        style: TextStyle(
                          color: AppColors.pointDark,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.pointDark,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Semantics(
                  label: 'メニューボタン',
                  button: true,
                  hint: 'タップしてドロワーメニューを開きます',
                  child: IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(
                      Icons.menu,
                      color: AppColors.pointDark, // 검정색으로 변경
                      size: 24,
                    ),
                  ),
                ),

              const Spacer(),

              // 오른쪽 아이콘들
              Row(
                children: [
                  // 드로워가 닫혀있을 때
                  if (!isDrawerOpen) ...[
                    // 하트 버튼 (즐겨찾기)
                    Semantics(
                      label: 'お気に入りボタン',
                      button: true,
                      hint: 'タップしてお気に入りを表示します',
                      child: IconButton(
                        onPressed: onFavoriteTap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.favorite_outline,
                          color: AppColors.pointDark, // 검정색으로 변경
                          size: 24,
                        ),
                      ),
                    ),
                    // 알림 버튼
                    Semantics(
                      label: '通知ボタン',
                      button: true,
                      hint: 'タップして通知を表示します',
                      child: IconButton(
                        onPressed: onNotificationTap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.pointDark, // 검정색으로 변경
                          size: 24,
                        ),
                      ),
                    ),
                  ],

                  // 드로워가 열렸을 때
                  if (isDrawerOpen) ...[
                    // 알림 버튼
                    IconButton(
                      onPressed: onNotificationTap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.pureWhite,
                        size: 24,
                      ),
                    ),
                    // 1:1 채팅 버튼
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('1:1チャット機能は準備中です'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.pureWhite,
                        size: 24,
                      ),
                    ),
                    // 닫기 버튼
                    IconButton(
                      onPressed: onMenuTap,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.pureWhite,
                        size: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
