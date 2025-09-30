import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 📋 섹션 헤더
///
/// 제목과 선택적 액션 버튼이 있는 공통 섹션 헤더
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showDivider;
  final Color? titleColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.leading,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.showDivider = false,
    this.titleColor,
    this.titleStyle,
    this.subtitleStyle,
  });

  /// 기본 섹션 헤더 팩토리
  factory SectionHeader.basic({required String title, String? subtitle, Widget? action}) {
    return SectionHeader(
      title: title,
      subtitle: subtitle,
      action: action,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    );
  }

  /// 구분선이 있는 섹션 헤더 팩토리
  factory SectionHeader.withDivider({
    required String title,
    String? subtitle,
    Widget? action,
    EdgeInsetsGeometry? padding,
  }) {
    return SectionHeader(
      title: title,
      subtitle: subtitle,
      action: action,
      showDivider: true,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
    );
  }

  /// 아이콘이 있는 섹션 헤더 팩토리
  factory SectionHeader.withIcon({
    required String title,
    required IconData icon,
    String? subtitle,
    Widget? action,
    Color? iconColor,
  }) {
    return SectionHeader(
      title: title,
      subtitle: subtitle,
      action: action,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.pointBrown).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.pointBrown, size: 20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    );
  }

  /// 카운트가 있는 섹션 헤더 팩토리
  factory SectionHeader.withCount({
    required String title,
    required int count,
    String? subtitle,
    Widget? action,
    Color? countColor,
  }) {
    return SectionHeader(
      title: title,
      subtitle: subtitle,
      action: action,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: (countColor ?? AppColors.pointBlue).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(
          count.toString(),
          style: TextStyle(
            color: countColor ?? AppColors.pointBlue,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget header = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.md)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style:
                        titleStyle ??
                        AppFonts.titleMedium.copyWith(
                          color: titleColor ?? AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      style:
                          subtitleStyle ?? AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
                    ),
                  ],
                ],
              ),
            ),
            if (action != null) ...[const SizedBox(width: AppSpacing.md), action!],
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.pointGray.withValues(alpha: 0.3), thickness: 1, height: 1),
        ],
      ],
    );

    if (padding != null) {
      header = Padding(padding: padding!, child: header);
    }

    return header;
  }
}
