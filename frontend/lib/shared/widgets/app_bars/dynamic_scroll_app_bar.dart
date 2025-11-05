import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../shared/shared.dart';

/// 스크롤에 따라 동적으로 변화하는 앱 바
///
/// 스크롤 진행에 따른 변화:
/// 1. 0% - 기본 색상 배경 (pointBrown)
/// 2. 0-50% - 블러 효과 시작, 배경색 점진적 화이트 전환
/// 3. 50-100% - 완전한 화이트 배경으로 전환
class DynamicScrollAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ScrollController scrollController;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? baseColor;
  final double blurStartOffset;
  final double whiteStartOffset;
  final double maxBlurSigma;

  const DynamicScrollAppBar({
    super.key,
    required this.scrollController,
    this.title,
    this.leading,
    this.actions,
    this.baseColor,
    this.blurStartOffset = 50.0,
    this.whiteStartOffset = 100.0,
    this.maxBlurSigma = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final scrollOffset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;

        // 진행률 계산 (0.0 ~ 1.0)
        final blurProgress = (scrollOffset / blurStartOffset).clamp(0.0, 1.0);
        final whiteProgress = (scrollOffset / whiteStartOffset).clamp(0.0, 1.0);

        // 배경색 계산: baseColor → white
        final backgroundColor =
            Color.lerp(
              baseColor ?? AppColors.pointBrown,
              Colors.white,
              whiteProgress,
            ) ??
            Colors.white;

        // 블러 강도 계산
        final blurSigma = maxBlurSigma * blurProgress;

        // 텍스트 색상: 배경과 대비되도록
        final textColor = whiteProgress > 0.5
            ? AppColors.pointDark
            : Colors.white;

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: whiteProgress > 0.3
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: leading,
              title: title != null
                  ? Text(
                      title!,
                      style: AppFonts.headlineSmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
              actions: actions,
              iconTheme: IconThemeData(color: textColor),
              actionsIconTheme: IconThemeData(color: textColor),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 사전 정의된 스타일의 다이나믹 앱 바들
class DynamicAppBarStyles {
  /// 기본 브라운 테마 앱 바
  static DynamicScrollAppBar brown({
    required ScrollController scrollController,
    String? title,
    Widget? leading,
    List<Widget>? actions,
  }) {
    return DynamicScrollAppBar(
      scrollController: scrollController,
      title: title,
      leading: leading,
      actions: actions,
      baseColor: AppColors.pointBrown,
      blurStartOffset: 30.0,
      whiteStartOffset: 80.0,
    );
  }

  /// 그린 테마 앱 바
  static DynamicScrollAppBar green({
    required ScrollController scrollController,
    String? title,
    Widget? leading,
    List<Widget>? actions,
  }) {
    return DynamicScrollAppBar(
      scrollController: scrollController,
      title: title,
      leading: leading,
      actions: actions,
      baseColor: AppColors.pointGreen,
      blurStartOffset: 30.0,
      whiteStartOffset: 80.0,
    );
  }

  /// 블루 테마 앱 바
  static DynamicScrollAppBar blue({
    required ScrollController scrollController,
    String? title,
    Widget? leading,
    List<Widget>? actions,
  }) {
    return DynamicScrollAppBar(
      scrollController: scrollController,
      title: title,
      leading: leading,
      actions: actions,
      baseColor: AppColors.pointBlue,
      blurStartOffset: 30.0,
      whiteStartOffset: 80.0,
    );
  }
}
