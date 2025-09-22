import 'package:flutter/material.dart';

import '../../ui/components/app_button.dart';

/// ⚠️ DEPRECATED: 기존 API 호환성을 위해 유지됨
/// 새로운 코드에서는 AppButton을 직접 사용하세요.
///
/// 마이그레이션 예시:
/// ```dart
/// // Before
/// GlassButton(label: "확인", onPressed: () {})
///
/// // After
/// AppButton.glass(text: "확인", onPressed: () {})
/// ```

@Deprecated('Use AppButton.glass() instead')
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final bool expand;
  final double borderRadius;
  final double blurX;
  final double blurY;
  final double opacity;
  final double borderWidth;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final Widget? leading;
  final Widget? trailing;
  final BoxConstraints? constraints;

  const GlassButton({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.expand = false,
    this.borderRadius = 12,
    this.blurX = 12,
    this.blurY = 12,
    this.opacity = 0.18,
    this.borderWidth = 1,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    this.textStyle,
    this.leading,
    this.trailing,
    this.constraints,
  }) : onPressed = isLoading ? null : onPressed;

  const GlassButton.dense({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.expand = false,
    this.borderRadius = 10,
    this.blurX = 10,
    this.blurY = 10,
    this.opacity = 0.16,
    this.borderWidth = 1,
    this.borderColor,
    this.textStyle,
    this.leading,
    this.trailing,
    this.constraints,
  }) : padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
       onPressed = isLoading ? null : onPressed;

  const GlassButton.medium({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.expand = false,
    this.borderRadius = 12,
    this.blurX = 12,
    this.blurY = 12,
    this.opacity = 0.18,
    this.borderWidth = 1,
    this.borderColor,
    this.textStyle,
    this.leading,
    this.trailing,
    this.constraints,
  }) : padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
       onPressed = isLoading ? null : onPressed;

  const GlassButton.large({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.expand = false,
    this.borderRadius = 14,
    this.blurX = 14,
    this.blurY = 14,
    this.opacity = 0.2,
    this.borderWidth = 1,
    this.borderColor,
    this.textStyle,
    this.leading,
    this.trailing,
    this.constraints,
  }) : padding = const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
       onPressed = isLoading ? null : onPressed;

  @override
  Widget build(BuildContext context) {
    // GlassButton을 AppButton.glass로 변환
    return AppButton.glass(
      text: label,
      onPressed: onPressed,
      size: _getSize(),
      isLoading: isLoading,
      expand: expand,
      leading: leading,
      trailing: trailing,
      backgroundColor: isPrimary ? null : Colors.transparent,
      borderColor: borderColor,
      padding: padding != const EdgeInsets.symmetric(vertical: 14, horizontal: 20) ? padding : null,
      textStyle: textStyle,
      borderRadius: borderRadius != 12 ? borderRadius : null,
    );
  }

  ButtonSize _getSize() {
    if (padding == const EdgeInsets.symmetric(vertical: 8, horizontal: 12)) {
      return ButtonSize.small;
    }
    if (padding == const EdgeInsets.symmetric(vertical: 18, horizontal: 28)) {
      return ButtonSize.large;
    }
    return ButtonSize.medium;
  }
}

@Deprecated('Use AppButton.point() instead')
class PointButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final double borderRadius;

  const PointButton({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isLoading = false,
    this.expand = false,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    this.textStyle,
    this.borderRadius = 12,
  }) : onPressed = isLoading ? null : onPressed;

  const PointButton.small({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isLoading = false,
    this.expand = false,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius = 10,
  }) : padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
       onPressed = isLoading ? null : onPressed;

  const PointButton.medium({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isLoading = false,
    this.expand = false,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius = 12,
  }) : padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
       onPressed = isLoading ? null : onPressed;

  const PointButton.large({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isLoading = false,
    this.expand = false,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius = 14,
  }) : padding = const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
       onPressed = isLoading ? null : onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton.point(
      text: label,
      onPressed: onPressed,
      size: _getSize(),
      isLoading: isLoading,
      expand: expand,
      leading: leading,
      trailing: trailing,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: _isCustomPadding() ? padding : null,
      textStyle: textStyle,
      borderRadius: borderRadius != 12 ? borderRadius : null,
    );
  }

  ButtonSize _getSize() {
    if (padding == const EdgeInsets.symmetric(vertical: 8, horizontal: 12)) {
      return ButtonSize.small;
    }
    if (padding == const EdgeInsets.symmetric(vertical: 18, horizontal: 28)) {
      return ButtonSize.large;
    }
    return ButtonSize.medium;
  }

  bool _isCustomPadding() {
    return padding != const EdgeInsets.symmetric(vertical: 14, horizontal: 20) &&
           padding != const EdgeInsets.symmetric(vertical: 8, horizontal: 12) &&
           padding != const EdgeInsets.symmetric(vertical: 18, horizontal: 28);
  }
}

@Deprecated('Use AppButton.point(variant: ButtonVariant.text) instead')
class PointTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final Color? textColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const PointTextButton({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isLoading = false,
    this.leading,
    this.trailing,
    this.textColor,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  }) : onPressed = isLoading ? null : onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: label,
      onPressed: onPressed,
      variant: ButtonVariant.text,
      size: ButtonSize.small,
      isLoading: isLoading,
      leading: leading,
      trailing: trailing,
      foregroundColor: textColor,
      padding: padding,
      textStyle: textStyle,
    );
  }
}

@Deprecated('Use AppButton.point(variant: ButtonVariant.outlined) instead')
class PointOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final Color? borderColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const PointOutlinedButton({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isLoading = false,
    this.leading,
    this.trailing,
    this.borderColor,
    this.textColor,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    this.borderRadius = 12,
  }) : onPressed = isLoading ? null : onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: label,
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      size: ButtonSize.medium,
      isLoading: isLoading,
      leading: leading,
      trailing: trailing,
      borderColor: borderColor,
      foregroundColor: textColor,
      padding: padding,
      textStyle: textStyle,
      borderRadius: borderRadius != 12 ? borderRadius : null,
    );
  }
}