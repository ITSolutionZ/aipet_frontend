import 'package:flutter/material.dart';

import 'tokens/tokens.dart';

class AppTextStyles {
  static final h1 = AppFonts.point(fontSize: 32, fontWeight: FontWeight.w600);

  static final h2 = AppFonts.point(fontSize: 24, fontWeight: FontWeight.w600);

  static final body = AppFonts.base(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final caption = AppFonts.base(
    fontSize: 12,
    fontWeight: FontWeight.w300,
  );

  // Additional semantic text style getters
  static TextStyle get titleMedium => AppFonts.point(fontSize: 18, fontWeight: FontWeight.w500);
  static TextStyle get headlineSmall => AppFonts.point(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle get bodySmall => AppFonts.base(fontSize: 12, fontWeight: FontWeight.normal);
  static TextStyle get bodyMedium => AppFonts.base(fontSize: 14, fontWeight: FontWeight.normal);
}
