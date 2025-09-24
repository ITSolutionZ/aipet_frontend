import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 공통 AppBar 스타일을 위한 위젯
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor = AppColors.pointBrown,
    this.foregroundColor = AppColors.pointOffWhite,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      leading: leading,
      title: Text(
        title,
        style: AppFonts.fredoka(
          fontSize: AppFonts.lg,
          color: foregroundColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 뒤로가기 버튼이 있는 AppBar
class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const BackAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.backgroundColor = AppColors.pointBrown,
    this.foregroundColor = AppColors.pointOffWhite,
  });

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: title,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed:
            onBackPressed ??
            () {
              // GoRouter 환경에서 안전한 뒤로가기
              if (context.canPop()) {
                context.pop();
              } else {
                // 홈으로 이동
                context.go('/home');
              }
            },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Drawer가 있는 AppBar
class DrawerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? selectedPetInfo;
  final Color backgroundColor;
  final Color foregroundColor;

  const DrawerAppBar({
    super.key,
    required this.title,
    this.selectedPetInfo,
    this.backgroundColor = AppColors.pointBrown,
    this.foregroundColor = AppColors.pointOffWhite,
  });

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: title,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      actions: selectedPetInfo != null ? [selectedPetInfo!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
