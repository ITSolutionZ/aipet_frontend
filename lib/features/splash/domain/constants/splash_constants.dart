import 'package:flutter/material.dart';

/// 스플래시 관련 상수 정의
class SplashConstants {
  // 생성자 비활성화
  const SplashConstants._();

  // 타이밍 상수
  static const Duration logoDisplayDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 3000);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 1000);
  static const Duration scaleAnimationDuration = Duration(milliseconds: 1000);

  // 이미지 경로
  static const String companyLogoPath = 'assets/icons/itz.png';
  static const String appLogoPath = 'assets/icons/aipet_logo.png';

  // 크기 상수
  static const double companyLogoWidth = 196.0;
  static const double companyLogoHeight = 130.0;
  static const double appLogoSize = 300.0;

  // 애니메이션 상수
  static const double fadeStart = 0.0;
  static const double fadeEnd = 1.0;
  static const double scaleStart = 0.5;
  static const double scaleEnd = 1.0;
  static const double logoRadius = 20.0;
  static const double companyLogoRadius = 8.0;

  // 애니메이션 인터벌
  static const Interval fadeInterval = Interval(0.0, 0.33, curve: Curves.easeIn);
  static const Interval scaleInterval = Interval(0.0, 0.33, curve: Curves.elasticOut);

  // 색상 투명도
  static const int gradientAlpha1 = 23;
  static const int gradientAlpha2 = 10;
  static const int borderAlpha = 22;
}