import 'dart:ui';

import 'package:flutter/material.dart';

/// Reusable light glassmorphism card
/// - Thin blur, subtle gradient, hairline border
/// - Keep props minimal and composable (DRY)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurX;
  final double blurY;
  final double opacity; // 0 ~ 1, overall tint strength
  final double borderWidth;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Clip clipBehavior;
  final BoxConstraints? constraints;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 14,
    this.blurX = 12,
    this.blurY = 12,
    this.opacity = 0.18,
    this.borderWidth = 1,
    this.borderColor,
    this.gradient,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.constraints,
  });

  /// Dense preset for chips / small tiles
  const GlassCard.dense({
    super.key,
    required this.child,
    this.margin,
    this.borderRadius = 12,
    this.blurX = 10,
    this.blurY = 10,
    this.opacity = 0.16,
    this.borderWidth = 1,
    this.borderColor,
    this.gradient,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.constraints,
  }) : padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  /// Panel preset for larger sections
  const GlassCard.panel({
    super.key,
    required this.child,
    this.margin,
    this.borderRadius = 16,
    this.blurX = 14,
    this.blurY = 14,
    this.opacity = 0.20,
    this.borderWidth = 1,
    this.borderColor,
    this.gradient,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.constraints,
  }) : padding = const EdgeInsets.all(20);

  @override
  Widget build(BuildContext context) {
    final Color lineColor = (borderColor ?? Colors.white).withAlpha(22);

    final Gradient bg =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha((opacity * 90).toInt()),
            Colors.white.withAlpha((opacity * 40).toInt()),
          ],
        );

    final content = Container(
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: bg,
        border: Border.all(
          color: lineColor,
          width: borderWidth,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
        child: content,
      ),
    );

    if (onTap == null) return clipped;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashFactory: InkRipple.splashFactory,
        child: clipped,
      ),
    );
  }
}

/// Reusable white background card
/// - Clean white background with subtle shadow
/// - Same API as GlassCard for consistency
/// - Perfect for content-heavy sections
class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double elevation;
  final Color? backgroundColor;
  final double borderWidth;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Clip clipBehavior;
  final BoxConstraints? constraints;

  const WhiteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 14,
    this.elevation = 2,
    this.backgroundColor,
    this.borderWidth = 0,
    this.borderColor,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.constraints,
  });

  /// Dense preset for chips / small tiles
  const WhiteCard.dense({
    super.key,
    required this.child,
    this.margin,
    this.borderRadius = 12,
    this.elevation = 1,
    this.backgroundColor,
    this.borderWidth = 0,
    this.borderColor,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.constraints,
  }) : padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  /// Panel preset for larger sections
  const WhiteCard.panel({
    super.key,
    required this.child,
    this.margin,
    this.borderRadius = 16,
    this.elevation = 4,
    this.backgroundColor,
    this.borderWidth = 0,
    this.borderColor,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.constraints,
  }) : padding = const EdgeInsets.all(20);

  /// Elevated preset for prominent cards
  const WhiteCard.elevated({
    super.key,
    required this.child,
    this.margin,
    this.borderRadius = 14,
    this.elevation = 8,
    this.backgroundColor,
    this.borderWidth = 0,
    this.borderColor,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    this.constraints,
  }) : padding = const EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = backgroundColor ?? Colors.white;
    final Color lineColor = borderColor ?? Colors.grey[300]!;

    final content = Container(
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderWidth > 0
            ? Border.all(color: lineColor, width: borderWidth)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: clipBehavior,
      child: content,
    );

    if (onTap == null) return clipped;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashFactory: InkRipple.splashFactory,
        child: clipped,
      ),
    );
  }
}
