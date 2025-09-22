import 'package:flutter/material.dart';

import '../../ui/components/cards/cards.dart';

/// ⚠️ DEPRECATED: 기존 API 호환성을 위해 유지됨
/// 새로운 코드에서는 SummaryCard.basic() 또는 SummaryCard.withValue()를 사용하세요.

@Deprecated('Use SummaryCard.basic() or SummaryCard.withValue() instead')
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
    if (isLoading) {
      return SummaryCard.loading(
        title: title,
        subtitle: subtitle,
        icon: icon,
        semanticLabel: semanticLabel,
      );
    } else if (value != null) {
      return SummaryCard.withValue(
        title: title,
        subtitle: subtitle,
        value: value!,
        unit: unit,
        icon: icon,
        iconColor: iconColor,
        trailing: trailing,
        onTap: onTap,
        semanticLabel: semanticLabel,
      );
    } else {
      return SummaryCard.basic(
        title: title,
        subtitle: subtitle,
        icon: icon,
        onTap: onTap,
        semanticLabel: semanticLabel,
      );
    }
  }
}

@Deprecated('Use MetricCard.simple() or MetricCard.withChange() instead')
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
    if (change != null) {
      return MetricCard.withChange(
        title: title,
        value: value,
        change: change!,
        isPositiveChange: isPositiveChange ?? true,
        unit: unit,
        icon: icon,
        iconColor: iconColor,
        onTap: onTap,
      );
    } else {
      return MetricCard.simple(
        title: title,
        value: value,
        unit: unit,
        icon: icon,
        onTap: onTap,
      );
    }
  }
}

@Deprecated('Use ButtonCard.primary() or ButtonCard.secondary() instead')
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
    return ButtonCard.primary(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
    );
  }
}