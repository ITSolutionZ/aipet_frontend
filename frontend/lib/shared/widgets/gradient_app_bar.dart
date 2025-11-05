import 'package:flutter/material.dart';

import '../../shared/shared.dart';

/// 그라데이션 스타일의 공통 AppBar
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;
  final LinearGradient? gradient;

  const GradientAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.elevation = 0,
    this.bottom,
    this.toolbarHeight,
    this.gradient,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient:
              gradient ??
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.pointBrown.withValues(alpha: 0.9),
                  AppColors.pointBrown.withValues(alpha: 0.7),
                ],
              ),
        ),
      ),
      // 기본 아이콘 색상을 흰색으로 설정
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
