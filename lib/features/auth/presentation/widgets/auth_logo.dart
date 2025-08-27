import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
    this.width = 250,
    this.height = 250,
    this.imagePath = 'assets/icons/aipet_logo.png',
    this.backgroundColor = Colors.transparent,
  });

  final double width;
  final double height;
  final String imagePath;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return LogoWidget(
      imagePath: imagePath,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
    );
  }
}
