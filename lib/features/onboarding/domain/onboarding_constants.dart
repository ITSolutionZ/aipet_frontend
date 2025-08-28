import 'package:flutter/material.dart';

/// 온보딩 관련 상수들
class OnboardingConstants {
  // 화면 비율
  static const int imageSectionFlex = 55;
  static const int bottomSheetFlex = 45;

  // 애니메이션
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  // UI 상수
  static const double skipButtonOpacity = 0.3;
  static const double bottomSheetShadowOpacity = 0.1;
  static const double bottomSheetShadowBlurRadius = 10.0;
  static const Offset bottomSheetShadowOffset = Offset(0, -2);

  // 이미지 상수
  static const double logoWidth = 100.0;
  static const double logoHeight = 70.0;
  static const double pageIndicatorIconSize = 20.0;
  static const double nextButtonIconSize = 20.0;

  // 텍스트 상수
  static const double descriptionLineHeight = 1.4;
  static const int descriptionMaxLines = 4;

  // 버튼 텍스트
  static const String nextButtonText = '次へ';
  static const String startButtonText = '始める';
  static const String skipButtonText = 'Skip';

  // 공통 스타일 상수
  static const double fallbackBackgroundOpacity = 0.1;
  static const double fallbackIconOpacity = 0.3;
  static const double buttonBackgroundOpacity = 0.8;
}
