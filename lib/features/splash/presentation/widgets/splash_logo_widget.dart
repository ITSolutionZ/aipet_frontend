import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class SplashLogoWidget extends StatelessWidget {
  final String logoPath;
  final double width;
  final double height;

  const SplashLogoWidget({
    super.key,
    required this.logoPath,
    this.width = 300,
    this.height = 349,
  });

  @override
  Widget build(BuildContext context) {
    return LogoWidget(
      imagePath: logoPath,
      width: width,
      height: height,
    );
  }
}
