import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 🔘 버튼 형태 카드
///
/// 액션 버튼 UI에 특화된 카드 컴포넌트
class ButtonCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isEnabled;
  final String? semanticLabel;

  const ButtonCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.isEnabled = true,
    this.semanticLabel,
  });

  /// 기본 버튼 카드 팩토리
  factory ButtonCard.primary({
    required String title,
    String? subtitle,
    Widget? icon,
    required VoidCallback onTap,
    bool isEnabled = true,
    String? semanticLabel,
  }) {
    return ButtonCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      backgroundColor: AppColors.pointBrown,
      textColor: Colors.white,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }

  /// 보조 버튼 카드 팩토리
  factory ButtonCard.secondary({
    required String title,
    String? subtitle,
    Widget? icon,
    required VoidCallback onTap,
    bool isEnabled = true,
    String? semanticLabel,
  }) {
    return ButtonCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      backgroundColor: AppColors.pureWhite,
      textColor: AppColors.pointBrown,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }

  /// 위험 액션 버튼 카드 팩토리
  factory ButtonCard.danger({
    required String title,
    String? subtitle,
    Widget? icon,
    required VoidCallback onTap,
    bool isEnabled = true,
    String? semanticLabel,
  }) {
    return ButtonCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }

  /// 아웃라인 버튼 카드 팩토리
  factory ButtonCard.outline({
    required String title,
    String? subtitle,
    Widget? icon,
    required VoidCallback onTap,
    Color? borderColor,
    bool isEnabled = true,
    String? semanticLabel,
  }) {
    return ButtonCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      backgroundColor: Colors.transparent,
      textColor: borderColor ?? AppColors.pointBrown,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      padding: const const const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: backgroundColor == Colors.transparent
            ? Border.all(color: textColor ?? AppColors.pointBrown, width: 2)
            : null,
        boxShadow: backgroundColor != Colors.transparent
            ? [
                BoxShadow(
                  color: AppColors.pointDark.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: textColor ?? AppColors.pointDark,
                  size: 24,
                ),
                child: icon!,
              ),
              const const const SizedBox(width: AppSpacing.sm),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppFonts.titleMedium.copyWith(
                    color: textColor ?? AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const const const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppFonts.bodySmall.copyWith(
                      color: (textColor ?? AppColors.pointDark).withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: card,
      ),
    );

    if (!isEnabled) {
      button = Opacity(opacity: 0.6, child: button);
    }

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: isEnabled,
        child: button,
      );
    }

    return button;
  }
}
