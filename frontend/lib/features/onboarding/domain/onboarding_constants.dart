import 'package:flutter/material.dart';


import '../../../shared/shared.dart';
/// 온보딩 관련 상수들
class OnboardingConstants {
  // 화면 비율
  static const int imageSectionFlex = 55;
  static const int bottomSheetFlex = 45;

  // 애니메이션 (AppConstants에서 가져옴)
  static Duration get pageTransitionDuration =>
      AppConstants.pageTransitionDuration;
  static Curve get pageTransitionCurve => AppConstants.pageTransitionCurve;

  // UI 상수 (AppConstants에서 가져옴)
  static double get skipButtonOpacity => AppConstants.skipButtonOpacity;
  static double get bottomSheetShadowOpacity =>
      AppConstants.bottomSheetShadowOpacity;
  static double get bottomSheetShadowBlurRadius =>
      AppConstants.bottomSheetShadowBlurRadius;
  static Offset get bottomSheetShadowOffset =>
      AppConstants.bottomSheetShadowOffset;

  // 이미지 상수 (AppConstants에서 가져옴)
  static double get logoWidth => AppConstants.logoWidth;
  static double get logoHeight => AppConstants.logoHeight;
  static double get pageIndicatorIconSize => AppConstants.pageIndicatorIconSize;
  static double get nextButtonIconSize => AppConstants.nextButtonIconSize;

  // 텍스트 상수 (AppConstants에서 가져옴)
  static double get descriptionLineHeight => AppConstants.descriptionLineHeight;
  static int get descriptionMaxLines => AppConstants.descriptionMaxLines;

  // 버튼 텍스트 (AppTexts에서 가져옴)
  static String get nextButtonText => AppTexts.nextButton;
  static String get startButtonText => AppTexts.startButton;
  static String get skipButtonText => AppTexts.skipButton;

  // 공통 스타일 상수 (AppConstants에서 가져옴)
  static double get fallbackBackgroundOpacity =>
      AppConstants.fallbackBackgroundOpacity;
  static double get fallbackIconOpacity => AppConstants.fallbackIconOpacity;
  static double get buttonBackgroundOpacity =>
      AppConstants.buttonBackgroundOpacity;
}
