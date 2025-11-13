import 'package:aipet_frontend/shared/ui/components/cards/cards.dart';
import 'package:flutter/material.dart';

/// ⚠️ DEPRECATED: 기존 API 호환성을 위해 유지됨
/// 새로운 코드에서는 SelectionCard.option()을 직접 사용하세요.

@Deprecated('Use SelectionCard.option() instead')
class LegacySelectionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final String? semanticLabel;

  const LegacySelectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (title != null || subtitle != null) {
      return SelectionCard.titled(
        title: title!,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        isSelected: isSelected,
        selectedColor: selectedColor,
        onTap: onTap,
        semanticLabel: semanticLabel,
        child: child,
      );
    } else {
      return SelectionCard.basic(
        isSelected: isSelected,
        selectedColor: selectedColor,
        onTap: onTap,
        semanticLabel: semanticLabel,
        child: child,
      );
    }
  }
}

@Deprecated('Use SelectionCard.option() instead')
class MediaCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;

  const MediaCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (title != null || subtitle != null) {
      return SelectionCard.titled(
        title: title!,
        subtitle: subtitle,
        isSelected: isSelected,
        selectedColor: selectedColor,
        onTap: onTap,
        child: child,
      );
    } else {
      return SelectionCard.basic(
        isSelected: isSelected,
        selectedColor: selectedColor,
        onTap: onTap,
        child: child,
      );
    }
  }
}
