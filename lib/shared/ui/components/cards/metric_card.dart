import 'package:aipet_frontend/shared/design/text_styles.dart';
import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 📊 메트릭/통계 표시용 카드 컴포넌트
///
/// ## 사용법
/// ```dart
/// MetricCard.value(
///   title: 'Weight',
///   value: '12.5',
///   unit: 'kg',
///   icon: Icons.monitor_weight,
/// )
///
/// MetricCard.withChange(
///   title: 'Daily Steps',
///   value: '8,432',
///   change: '+1,234',
///   isPositiveChange: true,
/// )
/// ```
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String? change;
  final bool? isPositiveChange;
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

  const MetricCard._({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.change,
    this.isPositiveChange,
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

  /// 값과 단위가 있는 메트릭 카드
  const MetricCard.value({
    Key? key,
    required String title,
    required String value,
    String? unit,
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
         value: value,
         unit: unit,
         icon: icon,
         iconColor: iconColor,
         onTap: onTap,
         padding: padding,
         margin: margin,
         borderRadius: borderRadius,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         semanticLabel: semanticLabel,
         tooltip: tooltip,
       );

  /// 변화량이 있는 메트릭 카드
  const MetricCard.withChange({
    Key? key,
    required String title,
    required String value,
    String? unit,
    required String change,
    required bool isPositiveChange,
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
         value: value,
         unit: unit,
         change: change,
         isPositiveChange: isPositiveChange,
         icon: icon,
         iconColor: iconColor,
         onTap: onTap,
         padding: padding,
         margin: margin,
         borderRadius: borderRadius,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         semanticLabel: semanticLabel,
         tooltip: tooltip,
       );

  /// 간단한 메트릭 카드
  const MetricCard.simple({
    Key? key,
    required String title,
    required String value,
    String? unit,
    Widget? icon,
    Color? iconColor,
    VoidCallback? onTap,
    String? semanticLabel,
  }) : this._(
         key: key,
         title: title,
         value: value,
         unit: unit,
         icon: icon,
         iconColor: iconColor,
         onTap: onTap,
         semanticLabel: semanticLabel,
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
                _buildHeader(),
                const const const SizedBox(height: AppSpacing.sm),
                _buildValue(),
                if (change != null) ...[
                  const const const SizedBox(height: AppSpacing.xs),
                  _buildChange(),
                ],
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
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (unit != null) ...[
          const const const SizedBox(width: AppSpacing.xs),
          Text(
            unit!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChange() {
    final isPositive = isPositiveChange ?? false;
    final changeColor = isPositive ? AppColors.success : AppColors.error;
    final changeIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      children: [
        Icon(
          changeIcon,
          size: 16,
          color: changeColor,
        ),
        const const const SizedBox(width: AppSpacing.xs),
        Text(
          change!,
          style: AppTextStyles.bodySmall.copyWith(
            color: changeColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
