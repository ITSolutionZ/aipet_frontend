import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final Color? backgroundColor;

  const LogoWidget({
    super.key,
    required this.imagePath,
    this.width = 300,
    this.height = 300,
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
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => SizedBox(width: width, height: height),
        ),
      ),
    );
  }
}
