import 'package:aipet_frontend/shared/design/text_styles.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 📋 정보 표시용 카드 컴포넌트
///
/// ## 사용법
/// ```dart
/// InfoCard.basic(
///   child: Text('Basic info'),
/// )
///
/// InfoCard.titled(
///   title: 'Pet Information',
///   icon: Icons.pets,
///   child: Text('Detailed content'),
/// )
/// ```
class InfoCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? semanticLabel;
  final String? tooltip;

  const InfoCard._({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.semanticLabel,
    this.tooltip,
  });

  /// 기본 정보 카드
  const InfoCard.basic({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    String? semanticLabel,
    String? tooltip,
  }) : this._(
         key: key,
         child: child,
         onTap: onTap,
         padding: padding,
         margin: margin,
         borderRadius: borderRadius,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         semanticLabel: semanticLabel,
         tooltip: tooltip,
       );

  /// 제목이 있는 정보 카드
  const InfoCard.titled({
    Key? key,
    required String title,
    required Widget child,
    String? subtitle,
    Widget? icon,
    Color? iconColor,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    String? semanticLabel,
    String? tooltip,
  }) : this._(
         key: key,
         title: title,
         subtitle: subtitle,
         icon: icon,
         iconColor: iconColor,
         child: child,
         onTap: onTap,
         padding: padding,
         margin: margin,
         borderRadius: borderRadius,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         semanticLabel: semanticLabel,
         tooltip: tooltip,
       );

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      margin: margin ?? const const const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackgroundGray,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.md),
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.md),
          child: Padding(
            padding: padding ?? const const const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) _buildHeader(),
                if (title != null) const const const SizedBox(height: AppSpacing.sm),
                child,
              ],
            ),
          ),
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        child: widget,
      );
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(
              color: iconColor ?? AppColors.primary,
              size: 20,
            ),
            child: icon!,
          ),
          const const const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const const const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
