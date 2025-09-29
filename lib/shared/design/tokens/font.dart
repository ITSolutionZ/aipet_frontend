import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  // 기본 폰트 사이즈 상수
  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double baseSize = 14.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 20.0;
  static const double h1 = 24.0;
  static const double h2 = 28.0;
  static const double h3 = 32.0;
  static const double h4 = 36.0;
  static const double h5 = 40.0;
  static const double h6 = 48.0;

  // Base font: Noto Sans JP
  static TextStyle base({
    double fontSize = baseSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return GoogleFonts.notoSansJp(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Point font: M PLUS 1
  static TextStyle point({
    double fontSize = baseSize,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    return GoogleFonts.mPlus1(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Fredoka font for special titles
  static TextStyle fredoka({
    double fontSize = baseSize,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Aldrich font for buttons
  static TextStyle aldrich({
    double fontSize = baseSize,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return GoogleFonts.aldrich(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // 미리 정의된 텍스트 스타일들
  static TextStyle get caption => base(fontSize: xs);
  static TextStyle get bodySmall => base(fontSize: sm);
  static TextStyle get bodyMedium => base(fontSize: baseSize);
  static TextStyle get bodyLarge => base(fontSize: lg);
  static TextStyle get titleSmall =>
      base(fontSize: xl, fontWeight: FontWeight.w600);
  static TextStyle get titleMedium =>
      base(fontSize: xxl, fontWeight: FontWeight.w600);
  static TextStyle get titleLarge =>
      base(fontSize: h1, fontWeight: FontWeight.w600);
  static TextStyle get headlineSmall =>
      base(fontSize: h2, fontWeight: FontWeight.w700);
  static TextStyle get headlineMedium =>
      base(fontSize: h3, fontWeight: FontWeight.w700);
  static TextStyle get headlineLarge =>
      base(fontSize: h4, fontWeight: FontWeight.w700);
  static TextStyle get displaySmall =>
      base(fontSize: h5, fontWeight: FontWeight.w800);
  static TextStyle get displayMedium =>
      base(fontSize: h6, fontWeight: FontWeight.w800);
}
