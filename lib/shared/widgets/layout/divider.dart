import 'package:flutter/material.dart';

/// Reusable Divider widget
/// - Supports horizontal and vertical orientation
/// - Optional opacity and margin
/// - Consistent design for shared use
class SharedDivider extends StatelessWidget {
  final Axis axis;
  final double thickness;
  final double opacity;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double length; // only applies if vertical divider
  final bool glass;

  const SharedDivider({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = 1,
    this.opacity = 0.12,
    this.margin,
    this.color,
    this.length = double.infinity,
    this.glass = false,
  });

  @override
  Widget build(BuildContext context) {
    if (glass) {
      final gradient = LinearGradient(
        begin: axis == Axis.horizontal
            ? Alignment.centerLeft
            : Alignment.topCenter,
        end: axis == Axis.horizontal
            ? Alignment.centerRight
            : Alignment.bottomCenter,
        colors: [
          Colors.white.withAlpha((opacity * 0).toInt()),
          Colors.white.withAlpha((opacity).toInt()),
          Colors.white.withAlpha((opacity * 0).toInt()),
        ],
      );

      final line = Container(
        width: axis == Axis.horizontal ? double.infinity : thickness,
        height: axis == Axis.horizontal ? thickness : length,
        decoration: BoxDecoration(gradient: gradient),
      );

      if (margin != null) {
        return Padding(padding: margin!, child: line);
      }
      return line;
    } else {
      final dividerColor = (color ?? Colors.white).withAlpha(
        (255 * opacity).toInt(),
      );

      final line = Container(
        width: axis == Axis.horizontal ? double.infinity : thickness,
        height: axis == Axis.horizontal ? thickness : length,
        color: dividerColor,
      );

      if (margin != null) {
        return Padding(padding: margin!, child: line);
      }
      return line;
    }
  }
}
