import 'package:flutter/material.dart';

import '../../ui/components/app_card.dart';

/// ⚠️ DEPRECATED: 기존 API 호환성을 위해 유지됨
/// 새로운 코드에서는 AppCard를 직접 사용하세요.
///
/// 마이그레이션 예시:
/// ```dart
/// // Before
/// InfoCard(title: "제목", subtitle: "부제목", icon: Icons.info)
///
/// // After
/// AppCard.info(title: "제목", subtitle: "부제목", icon: Icons.info)
/// ```

@Deprecated('Use AppCard instead')
abstract class CommonCard extends StatelessWidget {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final double? elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isDisabled;
  final bool isSelected;
  final String? semanticLabel;

  const CommonCard({
    super.key,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.elevation,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.isSelected = false,
    this.semanticLabel,
  });

  /// 카드 내용을 빌드하는 추상 메서드
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      width: width,
      height: height,
      isLoading: isLoading,
      isEnabled: !isDisabled,
      isSelected: isSelected,
      semanticLabel: semanticLabel,
      elevation: _getCardElevation(),
      child: buildContent(context),
    );
  }

  CardElevation _getCardElevation() {
    if (elevation == null) return CardElevation.low;
    if (elevation! <= 2) return CardElevation.none;
    if (elevation! <= 4) return CardElevation.low;
    if (elevation! <= 8) return CardElevation.medium;
    return CardElevation.high;
  }
}

@Deprecated('Use AppCard.info() instead')
class InfoCard extends CommonCard {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;
  final Widget? trailing;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    super.onTap,
    super.padding,
    super.margin,
    super.backgroundColor,
    super.borderRadius,
    super.elevation,
    super.width,
    super.height,
    super.isLoading,
    super.isDisabled,
    super.isSelected,
    super.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.info(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      trailing: trailing,
      onTap: onTap,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    // This method won't be called since we override build()
    return const SizedBox.shrink();
  }
}

@Deprecated('Use AppCard.metric() instead')
class MetricCard extends CommonCard {
  final String title;
  final String value;
  final String? unit;
  final String? change;
  final bool? isPositiveChange;
  final Widget? icon;
  final Color? iconColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.change,
    this.isPositiveChange,
    this.icon,
    this.iconColor,
    super.onTap,
    super.padding,
    super.margin,
    super.backgroundColor,
    super.borderRadius,
    super.elevation,
    super.width,
    super.height,
    super.isLoading,
    super.isDisabled,
    super.isSelected,
    super.semanticLabel,
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
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    // This method won't be called since we override build()
    return const SizedBox.shrink();
  }
}

@Deprecated('Use AppCard.button() instead')
class ButtonCard extends CommonCard {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;

  const ButtonCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required VoidCallback super.onTap,
    super.padding,
    super.margin,
    super.backgroundColor,
    super.borderRadius,
    super.elevation,
    super.width,
    super.height,
    super.isLoading,
    super.isDisabled,
    super.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.button(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap!,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    // This method won't be called since we override build()
    return const SizedBox.shrink();
  }
}