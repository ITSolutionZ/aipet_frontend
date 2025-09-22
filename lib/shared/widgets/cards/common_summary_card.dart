import 'package:flutter/material.dart';

import '../../ui/components/app_card.dart';

/// ⚠️ DEPRECATED: 기존 API 호환성을 위해 유지됨
/// 새로운 코드에서는 AppCard.summary()를 직접 사용하세요.

@Deprecated('Use AppCard.summary() instead')
class CommonSummaryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? value;
  final String? unit;
  final Widget? icon;
  final Color? iconColor;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final String? semanticLabel;

  const CommonSummaryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.leading,
    this.trailing,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.summary(
      title: title,
      subtitle: subtitle,
      value: value,
      unit: unit,
      icon: icon,
      iconColor: iconColor,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      semanticLabel: semanticLabel,
    );
  }
}

@Deprecated('Use AppCard.metric() instead')
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String? change;
  final bool? isPositiveChange;
  final Widget? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.change,
    this.isPositiveChange,
    this.icon,
    this.iconColor,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.metric(
      title: title,
      value: value,
      unit: unit,
      change: change,
      isPositiveChange: isPositiveChange,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
      backgroundColor: backgroundColor,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
    );
  }
}

@Deprecated('Use AppCard.button() instead')
class ActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;

  const ActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.onTap,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.button(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
      backgroundColor: backgroundColor,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
    );
  }
}