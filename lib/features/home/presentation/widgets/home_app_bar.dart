import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 홈 화면용 커스텀 앱바
/// 스크롤에 따라 투명에서 흰색으로 변하며 배너 이미지를 랜덤으로 표시
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
    // 배너 높이 계산 (화면 높이의 26% + 상태바 + 앱바 높이)
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bannerHeight = screenHeight * 0.26 + statusBarHeight + 56.0;

    return Container(
      height:
          preferredSize.height +
          MediaQuery.of(context).padding.top, // 상태바 높이 포함
      decoration: BoxDecoration(
        color: scrollOffset <= statusBarHeight
            ? null // 배너 시작 위치에서는 색상 없음
            : scrollOffset > (bannerHeight * 0.9)
            ? Colors
                  .white // 배너를 거의 지나가면 완전한 흰색
            : Colors.white.withValues(
                alpha: 0.1 + (scrollOffset / bannerHeight) * 0.5,
              ), // 스크롤 시작하면 반투명 흰색
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
                    const Text(
                      'ゲストユーザー',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        // プロフィール編集画面へ遷移
                        context.push('/settings/profile-edit');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '情報修正',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
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
                    icon: Icon(
                      Icons.menu,
                      color: scrollOffset <= statusBarHeight
                          ? AppColors.pureWhite
                          : AppColors.pointDark,
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
                        icon: Icon(
                          Icons.favorite_outline,
                          color: scrollOffset <= statusBarHeight
                              ? AppColors.pureWhite
                              : AppColors.pointDark,
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
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: scrollOffset <= statusBarHeight
                              ? AppColors.pureWhite
                              : AppColors.pointDark,
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
                        color: Colors.white,
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
                        color: Colors.white,
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
                        color: Colors.white,
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
