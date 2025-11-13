/// 홈 배너 assets 목록
///
/// 이 파일은 자동 생성됩니다. 수동으로 편집하지 마세요.
/// scripts/update_banner_assets.sh 스크립트를 실행하여 업데이트하세요.
class BannerAssets {
  // === 앱바 배너 (상단 헤더용) ===
  static const String _appbarBasePath =
      'assets/images/home_banner/appbar_banners/';

  static const List<String> _appbarBannerFileNames = [
    'appbar_banner1.png',
    'appbar_banner2.png',
    'appbar_banner3.png',
  ];

  /// 앱바 배너 이미지 목록
  static List<String> get appbarBannerImages => _appbarBannerFileNames
      .map((fileName) => '$_appbarBasePath$fileName')
      .toList();

  /// 앱바 배너 개수
  static int get appbarBannerCount => _appbarBannerFileNames.length;

  /// 특정 인덱스의 앱바 배너 이미지 경로
  static String getAppbarBannerAt(int index) {
    if (index < 0 || index >= appbarBannerCount) {
      throw ArgumentError('Invalid appbar banner index: $index');
    }
    return appbarBannerImages[index];
  }

  // === 홈 콘텐츠 배너 (메인 콘텐츠용) ===
  static const String _homeBasePath = 'assets/images/home_banner/home_banners/';

  static const List<String> _homeBannerFileNames = [
    'home_banner1.png',
    'home_banner2.png',
    'home_banner3.png',
    'home_banner4.png',
  ];

  /// 홈 콘텐츠 배너 이미지 목록
  static List<String> get homeBannerImages => _homeBannerFileNames
      .map((fileName) => '$_homeBasePath$fileName')
      .toList();

  /// 홈 콘텐츠 배너 개수
  static int get homeBannerCount => _homeBannerFileNames.length;

  /// 특정 인덱스의 홈 콘텐츠 배너 이미지 경로
  static String getHomeBannerAt(int index) {
    if (index < 0 || index >= homeBannerCount) {
      throw ArgumentError('Invalid home banner index: $index');
    }
    return homeBannerImages[index];
  }

  // === 레거시 지원 (기존 코드 호환성) ===
  @Deprecated('Use homeBannerImages instead')
  static List<String> get bannerImages => homeBannerImages;

  @Deprecated('Use homeBannerCount instead')
  static int get bannerCount => homeBannerCount;

  @Deprecated('Use getHomeBannerAt instead')
  static String getBannerAt(int index) => getHomeBannerAt(index);

  @Deprecated('Use homeBannerCount > index instead')
  static bool isValidIndex(int index) {
    return index >= 0 && index < homeBannerCount;
  }
}
