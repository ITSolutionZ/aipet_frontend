import 'package:aipet_frontend/shared/design/text_styles.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 🎯 선택 가능한 카드 컴포넌트
///
/// ## 사용법
/// ```dart
/// SelectionCard.basic(
///   child: Text('Select this option'),
///   isSelected: true,
///   onTap: () => handleSelection(),
/// )
///
/// SelectionCard.titled(
///   title: 'Pet Type',
///   subtitle: 'Choose your pet',
///   icon: Icons.pets,
///   isSelected: false,
///   child: Text('Dog'),
/// )
/// ```
class SelectionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? selectedColor;
  final String? semanticLabel;
  final String? tooltip;

  const SelectionCard._({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    required this.isSelected,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.selectedColor,
    this.semanticLabel,
    this.tooltip,
  });

  /// 기본 선택 카드
  const SelectionCard.basic({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    bool isSelected = false,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    Color? selectedColor,
    String? semanticLabel,
    String? tooltip,
  }) : this._(
         key: key,
         child: child,
         onTap: onTap,
         isSelected: isSelected,
         padding: padding,
         margin: margin,
         borderRadius: borderRadius,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         selectedColor: selectedColor,
         semanticLabel: semanticLabel,
         tooltip: tooltip,
       );

  /// 제목이 있는 선택 카드
  const SelectionCard.titled({
    Key? key,
    required String title,
    required Widget child,
    String? subtitle,
    Widget? icon,
    Color? iconColor,
    VoidCallback? onTap,
    bool isSelected = false,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
    Color? selectedColor,
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
         isSelected: isSelected,
         padding: padding,
         margin: margin,
         borderRadius: borderRadius,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         selectedColor: selectedColor,
         semanticLabel: semanticLabel,
         tooltip: tooltip,
       );

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isSelected
        ? (selectedColor ?? AppColors.primary.withValues(alpha: 0.1))
        : (backgroundColor ?? AppColors.cardBackgroundGray);

    final effectiveBorderColor = isSelected
        ? (selectedColor ?? AppColors.primary)
        : (borderColor ?? AppColors.borderGray);

    final widget = Container(
      margin: margin ?? const const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.md),
        border: Border.all(
          color: effectiveBorderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: (selectedColor ?? AppColors.primary).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
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
            padding: padding ?? const const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) _buildHeader(),
                if (title != null) const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(child: child),
                    if (isSelected) ...[
                      const const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.check_circle,
                        color: selectedColor ?? AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        selected: isSelected,
        button: onTap != null,
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
          const const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (selectedColor ?? AppColors.primary)
                      : AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
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