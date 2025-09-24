import 'package:aipet_frontend/shared/design/design.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// 감성적인 브라운 그라데이션 AppBar
class SoftGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;

  const SoftGradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // 다크 아이콘 (밝은 배경용)
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.pointBrown.withValues(alpha: 0.19), // 브라운 그라데이션 시작
              AppColors.pointBrown.withValues(alpha: 0.0), // 투명으로 페이드
            ],
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
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // 투명하게 설정
            elevation: 0, // AppBar 자체 elevation 제거
            leading: leading,
            title: Text(
              title,
              style: AppFonts.fredoka(
                fontSize: AppFonts.lg,
                color: AppColors.pointDark, // 다크 브라운 텍스트
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: centerTitle,
            actions: actions,
            iconTheme: const IconThemeData(
              color: AppColors.pointDark, // 다크 브라운 아이콘
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// 뒤로가기 버튼이 있는 감성적 AppBar
class SoftGradientBackAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const SoftGradientBackAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SoftGradientAppBar(
      title: title,
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Drawer가 있는 감성적 AppBar
class SoftGradientDrawerAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? selectedPetInfo;

  const SoftGradientDrawerAppBar({
    super.key,
    required this.title,
    this.selectedPetInfo,
  });

  @override
  Widget build(BuildContext context) {
    return SoftGradientAppBar(
      title: title,
      actions: selectedPetInfo != null ? [selectedPetInfo!] : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
