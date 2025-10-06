import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
    this.width = 250,
    this.height = 250,
    this.imagePath = 'assets/icons/logos/aipet_logo.png',
    this.backgroundColor = Colors.transparent,
  });

  final double width;
  final double height;
  final String imagePath;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: backgroundColor),
      child: ClipRRect(
        child: Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const SizedBox(width: 200, height: 200),
        ),
      ),
    );
  }
}
