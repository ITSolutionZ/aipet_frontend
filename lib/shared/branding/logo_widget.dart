import 'package:flutter/material.dart';

import '../design/color.dart';

class LogoWidget extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final Color? backgroundColor;

  const LogoWidget({
    super.key,
    required this.imagePath,
    this.width = 196,
    this.height = 130,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: backgroundColor ?? AppColors.pointCream),
      child: ClipRRect(
        child: Image.asset(
          imagePath,
          width: width - 8,
          height: height - 8,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              SizedBox(width: width - 16, height: height - 16),
        ),
      ),
    );
  }
}
