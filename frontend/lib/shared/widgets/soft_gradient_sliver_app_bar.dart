import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../shared/shared.dart';

/// 스크롤 화면용 감성적인 브라운 그라데이션 SliverAppBar
class SoftGradientSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double expandedHeight;

  const SoftGradientSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: leading,
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle.dark, // 다크 아이콘
      iconTheme: const IconThemeData(
        color: AppColors.pointDark, // 다크 브라운 아이콘
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: AppFonts.fredoka(
            fontSize: AppFonts.lg,
            color: AppColors.pointDark, // 다크 브라운 텍스트
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: centerTitle,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.pointBrown.withValues(alpha: 0.19), // 브라운 그라데이션 시작
                AppColors.pointBrown.withValues(alpha: 0.0), // 투명으로 페이드
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08), // 가벼운 그림자
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 뒤로가기 버튼이 있는 감성적 SliverAppBar
class SoftGradientSliverBackAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double expandedHeight;

  const SoftGradientSliverBackAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return SoftGradientSliverAppBar(
      title: title,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: AppColors.pointDark,
        onPressed:
            onBackPressed ??
            () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
      ),
    );
  }
}
