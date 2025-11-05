import 'package:flutter/material.dart';

/// 원형 마커 위젯
class CircleMarkerWidget extends StatelessWidget {
  final String iconPath;
  final Color backgroundColor;
  final double size;

  const CircleMarkerWidget({
    super.key,
    required this.iconPath,
    required this.backgroundColor,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          iconPath,
          width: size * 0.5,
          height: size * 0.5,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.pets, size: size * 0.5, color: Colors.white);
          },
        ),
      ),
    );
  }
}
