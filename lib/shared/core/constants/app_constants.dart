import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 공통 상수들
class AppConstants {
  AppConstants._();

  // ========== UI 관련 상수 ==========

  /// 기본 크기
  static const double defaultIconSize = 24.0;
  static const double defaultButtonHeight = 48.0;
  static const double defaultCardElevation = 4.0;
  static const double defaultBorderRadius = 8.0;

  /// 프로필 이미지 관련
  static const double profileImageSize = 120.0;
  static const double profileImageRadius = 60.0;
  static const double smallProfileImageSize = 40.0;
  static const double largeProfileImageSize = 200.0;

  /// 간격 (Spacing)
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  /// 패딩
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(12.0);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);

  // ========== 애니메이션 관련 상수 ==========

  /// 기본 애니메이션 지속시간
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration verySlowAnimation = Duration(milliseconds: 1000);

  /// 특수 애니메이션 지속시간
  static const Duration fadeAnimation = Duration(milliseconds: 1000);
  static const Duration scaleAnimation = Duration(milliseconds: 1000);
  static const Duration slideAnimation = Duration(milliseconds: 400);

  /// 애니메이션 곡선
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve fastCurve = Curves.easeIn;

  // ========== API 관련 상수 ==========

  /// 타임아웃 설정
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(seconds: 60);

  /// 재시도 설정
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration exponentialBackoffBase = Duration(seconds: 2);

  /// API 호출 제한
  static const Duration requestDebounce = Duration(milliseconds: 300);
  static const Duration cacheExpiry = Duration(minutes: 5);

  // ========== 파일 관련 상수 ==========

  /// 이미지 파일
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];

  /// 파일 업로드
  static const int maxFileSizeMB = 10;
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  // ========== 검증 관련 상수 ==========

  /// 텍스트 길이 제한
  static const int minNameLength = 1;
  static const int maxNameLength = 50;
  static const int minUsernameLength = 2;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;

  /// 숫자 범위
  static const double minWeight = 0.1;
  static const double maxWeight = 200.0;
  static const int minAge = 0;
  static const int maxAge = 30;

  /// 마이크로칩
  static const int microchipLength = 15;

  // ========== UI 제한사항 ==========

  /// 최대 개수 제한
  static const int maxFamilyManagers = 5;
  static const int maxPetsPerUser = 10;
  static const int maxNotifications = 100;

  /// 링크 만료 시간
  static const Duration defaultLinkExpiry = Duration(days: 30);
  static const Duration shortLinkExpiry = Duration(hours: 24);

  // ========== 로깅 관련 상수 ==========

  /// 로그 레벨
  static const String logLevelDebug = 'DEBUG';
  static const String logLevelInfo = 'INFO';
  static const String logLevelWarning = 'WARNING';
  static const String logLevelError = 'ERROR';

  /// 로그 메시지 길이 제한
  static const int maxLogMessageLength = 1000;

  // ========== 성능 관련 상수 ==========

  /// 메모리 사용량 제한
  static const int maxMemoryUsageMB = 100;

  /// 캐시 크기 제한
  static const int maxCacheSizeMB = 50;

  /// 이미지 캐시 설정
  static const int maxImageCacheCount = 100;
  static const Duration imageCacheExpiry = Duration(days: 7);

  // ========== 보안 관련 상수 ==========

  /// 토큰 만료 시간
  static const Duration defaultTokenExpiry = Duration(hours: 24);
  static const Duration refreshTokenExpiry = Duration(days: 30);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  /// 세션 타임아웃
  static const Duration sessionTimeout = Duration(hours: 2);
  static const Duration idleTimeout = Duration(minutes: 30);

  // ========== 네트워크 관련 상수 ==========

  /// 연결 상태 확인
  static const Duration connectionCheckInterval = Duration(seconds: 30);
  static const Duration offlineRetryDelay = Duration(seconds: 5);

  /// 데이터 동기화
  static const Duration syncFrequency = Duration(hours: 1);
  static const Duration backgroundSyncInterval = Duration(minutes: 15);

  // ========== UI 피드백 관련 상수 ==========

  /// 메시지 표시 시간
  static const Duration errorDisplayDuration = Duration(seconds: 5);
  static const Duration successDisplayDuration = Duration(seconds: 3);
  static const Duration infoDisplayDuration = Duration(seconds: 4);

  /// 로딩 표시 지연
  static const Duration loadingDebounce = Duration(milliseconds: 300);
  static const Duration minimumLoadingDuration = Duration(milliseconds: 500);

  // ========== 온보딩 관련 상수 ==========

  /// 페이지 전환 애니메이션
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;

  /// 버튼 투명도
  static const double skipButtonOpacity = 0.3;
  static const double buttonBackgroundOpacity = 0.8;

  /// 로고 크기
  static const double logoWidth = 100.0;
  static const double logoHeight = 70.0;

  /// 아이콘 크기
  static const double pageIndicatorIconSize = 20.0;
  static const double nextButtonIconSize = 20.0;

  /// 텍스트 설정
  static const double descriptionLineHeight = 1.4;
  static const int descriptionMaxLines = 4;

  /// 그림자 설정
  static const double bottomSheetShadowOpacity = 0.1;
  static const double bottomSheetShadowBlurRadius = 10.0;
  static const Offset bottomSheetShadowOffset = Offset(0, -2);

  /// Fallback 설정
  static const double fallbackBackgroundOpacity = 0.1;
  static const double fallbackIconOpacity = 0.3;

  // ========== 스플래시 관련 상수 ==========

  /// 스플래시 타이밍
  static const Duration splashLogoDisplayDuration = Duration(seconds: 2);
  static const Duration splashAnimationDuration = Duration(milliseconds: 2000);
  static const Duration splashFadeAnimationDuration = Duration(
    milliseconds: 1000,
  );
  static const Duration splashScaleAnimationDuration = Duration(
    milliseconds: 1000,
  );

  /// 스플래시 이미지 경로
  static const String splashCompanyLogoPath = 'assets/icons/logos/itz.png';
  static const String splashAppLogoPath = 'assets/icons/logos/aipet_logo.png';
  static const String splashLoadingLottiePath = 'assets/lottie/loading.json';

  /// 스플래시 크기
  static const double splashAppLogoSize = 200.0; // 앱 로고 크기 (스크린에 맞게 조정)
  static const double splashCompanyLogoWidth = 200.0; // ITZ 로고 크기
  static const double splashCompanyLogoHeight = 133.0; // 비율에 맞게 조정 (200 * 2/3)
  static const double splashLoadingLottieSize = 200.0;

  /// 스플래시 애니메이션
  static const double splashFadeStart = 0.0;
  static const double splashFadeEnd = 1.0;
  static const double splashScaleStart = 0.5;
  static const double splashScaleEnd = 1.0;
  static const double splashLogoRadius = 20.0;

  /// 스플래시 애니메이션 인터벌
  static const Interval splashFadeInterval = Interval(
    0.0,
    0.33,
    curve: Curves.easeIn,
  );
  static const Interval splashScaleInterval = Interval(
    0.0,
    0.33,
    curve: Curves.elasticOut,
  );

  /// 스플래시 색상 투명도
  static const int splashGradientAlpha1 = 23;
  static const int splashGradientAlpha2 = 10;
  static const int splashBorderAlpha = 22;
}
