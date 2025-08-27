import 'package:flutter/material.dart';

import 'font.dart';

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
}
