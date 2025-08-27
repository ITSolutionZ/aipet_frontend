import 'dart:ui';

import 'package:flutter/material.dart';

/// Reusable glassmorphism styled buttons
/// - Size presets: dense / medium / large
/// - Variants: primary (filled glass) / secondary (subtle glass)
/// - Supports leading/trailing icons and loading state
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // disabled when null or isLoading
  final bool isPrimary;
  final bool isLoading;
  final bool expand; // full width

  // Visuals
  final double borderRadius;
  final double blurX;
  final double blurY;
  final double opacity; // glass tint intensity 0~1
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

  /// Small button preset (chip-like)
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

  /// Medium button preset (default)
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

  /// Large button preset (CTA)
  const GlassButton.large({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.expand = true,
    this.borderRadius = 14,
    this.blurX = 14,
    this.blurY = 14,
    this.opacity = 0.20,
    this.borderWidth = 1,
    this.borderColor,
    this.textStyle,
    this.leading,
    this.trailing,
    this.constraints,
  }) : padding = const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
       onPressed = isLoading ? null : onPressed;

  /// Icon convenience constructor (icon at leading)
  factory GlassButton.icon({
    Key? key,
    required String label,
    required VoidCallback onPressed,
    required Widget icon,
    bool isPrimary = true,
    bool isLoading = false,
    bool expand = false,
    double borderRadius = 12,
    double blurX = 12,
    double blurY = 12,
    double opacity = 0.18,
    double borderWidth = 1,
    Color? borderColor,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 20,
    ),
    TextStyle? textStyle,
    Widget? trailing,
    BoxConstraints? constraints,
  }) {
    return GlassButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isPrimary: isPrimary,
      isLoading: isLoading,
      expand: expand,
      borderRadius: borderRadius,
      blurX: blurX,
      blurY: blurY,
      opacity: opacity,
      borderWidth: borderWidth,
      borderColor: borderColor,
      padding: padding,
      textStyle: textStyle,
      leading: icon,
      trailing: trailing,
      constraints: constraints,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color lineColor = (borderColor ?? Colors.white).withAlpha(25);

    final Gradient bg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isPrimary
          ? [
              Colors.white.withAlpha((opacity * 90).toInt()),
              Colors.white.withAlpha((opacity * 40).toInt()),
            ]
          : [
              Colors.white.withAlpha((opacity * 20).toInt()),
              Colors.white.withAlpha((opacity * 5).toInt()),
            ],
    );

    final baseText =
        textStyle ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isPrimary ? Colors.white : Colors.white70,
        );

    final labelWidget = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseText,
      ),
    );

    final rowChildren = <Widget>[
      if (leading != null) ...[leading!, const SizedBox(width: 8)],
      labelWidget,
      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
    ];

    final contentChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPrimary ? Colors.white : Colors.white70,
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: rowChildren,
          );

    final content = Container(
      constraints:
          constraints ??
          (expand
              ? const BoxConstraints(minHeight: 48)
              : const BoxConstraints(minHeight: 40)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: bg,
        border: Border.all(color: lineColor, width: borderWidth),
      ),
      padding: padding,
      alignment: Alignment.center,
      child: contentChild,
    );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
        child: content,
      ),
    );

    final button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onPressed, // null when disabled/loading
        child: expand
            ? SizedBox(width: double.infinity, child: clipped)
            : clipped,
      ),
    );

    return Opacity(opacity: (onPressed == null) ? 0.6 : 1, child: button);
  }
}

/// Reusable point color styled buttons
/// - Uses AppColors.pointBrown as primary color
/// - Size presets: small / medium / large
/// - Variants: primary (filled) / secondary (outlined) / text
/// - Supports leading/trailing icons and loading state
class PointButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // disabled when null or isLoading
  final bool isPrimary;
  final bool isLoading;
  final bool expand; // full width

  // Visuals
  final double borderRadius;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final Widget? leading;
  final Widget? trailing;
  final BoxConstraints? constraints;

  const PointButton({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.expand = false,
    this.borderRadius = 12,
    this.elevation = 2,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    this.textStyle,
    this.leading,
    this.trailing,
    this.constraints,
  }) : onPressed = isLoading ? null : onPressed;

  /// Small button preset
  const PointButton.small({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.expand = false,
    this.borderRadius = 8,
    this.elevation = 1,
    this.textStyle,
    this.leading,
    this.trailing,
    this.constraints,
  }) : padding = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
       onPressed = isLoading ? null : onPressed;

  /// Medium button preset (default)
  const PointButton.medium({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.expand = false,
    this.borderRadius = 12,
    this.elevation = 2,
    this.textStyle,
    this.leading,
    this.trailing,
    this.constraints,
  }) : padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
       onPressed = isLoading ? null : onPressed;

  /// Large button preset (CTA)
  const PointButton.large({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.expand = true,
    this.borderRadius = 14,
    this.elevation = 4,
    this.textStyle,
    this.leading,
    this.trailing,
    this.constraints,
  }) : padding = const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
       onPressed = isLoading ? null : onPressed;

  /// Icon convenience constructor (icon at leading)
  factory PointButton.icon({
    Key? key,
    required String label,
    required VoidCallback onPressed,
    required Widget icon,
    bool isPrimary = true,
    bool isLoading = false,
    bool expand = false,
    double borderRadius = 12,
    double elevation = 2,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 20,
    ),
    TextStyle? textStyle,
    Widget? trailing,
    BoxConstraints? constraints,
  }) {
    return PointButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isPrimary: isPrimary,
      isLoading: isLoading,
      expand: expand,
      borderRadius: borderRadius,
      elevation: elevation,
      padding: padding,
      textStyle: textStyle,
      leading: icon,
      trailing: trailing,
      constraints: constraints,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Import AppColors dynamically to avoid circular dependency
    const Color pointBrown = Color(0xFFA47764);

    final baseText =
        textStyle ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isPrimary ? Colors.white : pointBrown,
        );

    final labelWidget = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseText,
      ),
    );

    final rowChildren = <Widget>[
      if (leading != null) ...[leading!, const SizedBox(width: 8)],
      labelWidget,
      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
    ];

    final contentChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPrimary ? Colors.white : pointBrown,
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: rowChildren,
          );

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? pointBrown : Colors.transparent,
        foregroundColor: isPrimary ? Colors.white : pointBrown,
        elevation: isPrimary ? elevation : 0,
        shadowColor: pointBrown.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: pointBrown, width: 2),
        ),
        padding: padding,
        minimumSize: Size(
          expand ? double.infinity : 0,
          constraints?.minHeight ?? (expand ? 48 : 40),
        ),
      ),
      child: contentChild,
    );

    return Opacity(opacity: (onPressed == null) ? 0.6 : 1, child: button);
  }
}

/// Text button with point color styling
class PointTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final TextStyle? textStyle;
  final Widget? leading;
  final Widget? trailing;

  const PointTextButton({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isLoading = false,
    this.textStyle,
    this.leading,
    this.trailing,
  }) : onPressed = isLoading ? null : onPressed;

  @override
  Widget build(BuildContext context) {
    const Color pointBrown = Color(0xFFA47764);

    final baseText =
        textStyle ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: pointBrown,
        );

    final contentChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(pointBrown),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(label, style: baseText),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          );

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: pointBrown,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: contentChild,
    );
  }
}

/// Outlined button with point color styling
class PointOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final Widget? leading;
  final Widget? trailing;

  const PointOutlinedButton({
    super.key,
    required this.label,
    required VoidCallback onPressed,
    this.isLoading = false,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    this.textStyle,
    this.leading,
    this.trailing,
  }) : onPressed = isLoading ? null : onPressed;

  @override
  Widget build(BuildContext context) {
    const Color pointBrown = Color(0xFFA47764);

    final baseText =
        textStyle ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: pointBrown,
        );

    final contentChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(pointBrown),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(label, style: baseText),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          );

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: pointBrown,
        side: const BorderSide(color: pointBrown, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
      child: contentChild,
    );
  }
}
