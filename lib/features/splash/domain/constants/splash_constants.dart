import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

/// 스플래시 관련 상수 정의
class SplashConstants {
  // 생성자 비활성화
  const SplashConstants._();

  // 타이밍 상수 (AppConstants에서 가져옴)
  static Duration get logoDisplayDuration =>
      AppConstants.splashLogoDisplayDuration;
  static Duration get animationDuration => AppConstants.splashAnimationDuration;
  static Duration get fadeAnimationDuration =>
      AppConstants.splashFadeAnimationDuration;
  static Duration get scaleAnimationDuration =>
      AppConstants.splashScaleAnimationDuration;

  // 이미지 경로 (AppConstants에서 가져옴)
  static String get companyLogoPath => AppConstants.splashCompanyLogoPath;
  static String get appLogoPath => AppConstants.splashAppLogoPath;
  static String get loadingLottiePath => AppConstants.splashLoadingLottiePath;

  // 크기 상수 (AppConstants에서 가져옴)
  static double get companyLogoWidth => AppConstants.splashCompanyLogoWidth;
  static double get companyLogoHeight => AppConstants.splashCompanyLogoHeight;
  static double get appLogoSize => AppConstants.splashAppLogoSize;
  static double get loadingLottieSize => AppConstants.splashLoadingLottieSize;

  // 애니메이션 상수 (AppConstants에서 가져옴)
  static double get fadeStart => AppConstants.splashFadeStart;
  static double get fadeEnd => AppConstants.splashFadeEnd;
  static double get scaleStart => AppConstants.splashScaleStart;
  static double get scaleEnd => AppConstants.splashScaleEnd;
  static double get logoRadius => AppConstants.splashLogoRadius;
  static const double companyLogoRadius = 8.0;

  // 애니메이션 인터벌 (AppConstants에서 가져옴)
  static Interval get fadeInterval => AppConstants.splashFadeInterval;
  static Interval get scaleInterval => AppConstants.splashScaleInterval;

  // 색상 투명도 (AppConstants에서 가져옴)
  static int get gradientAlpha1 => AppConstants.splashGradientAlpha1;
  static int get gradientAlpha2 => AppConstants.splashGradientAlpha2;
  static int get borderAlpha => AppConstants.splashBorderAlpha;
}
