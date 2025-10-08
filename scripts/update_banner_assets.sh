#!/bin/bash

# 홈 배너 폴더들을 스캔하여 banner_assets.dart 파일을 자동 생성하는 스크립트

APPBAR_BANNER_DIR="assets/images/home_banner/appbar_banners"
HOME_BANNER_DIR="assets/images/home_banner/home_banners"
OUTPUT_FILE="lib/features/home/data/banner_assets.dart"

echo "Scanning banner directories..."
echo "Appbar banners: $APPBAR_BANNER_DIR"
echo "Home banners: $HOME_BANNER_DIR"

# 앱바 배너 파일 목록 가져오기 (알파벳 순 정렬)
appbar_files=$(ls "$APPBAR_BANNER_DIR"/*.png 2>/dev/null | sort | xargs -n1 basename)

# 홈 배너 파일 목록 가져오기 (알파벳 순 정렬)
home_files=$(ls "$HOME_BANNER_DIR"/*.png 2>/dev/null | sort | xargs -n1 basename)

if [ -z "$appbar_files" ] && [ -z "$home_files" ]; then
    echo "No banner files found in either directory"
    exit 1
fi

# banner_assets.dart 파일 생성
cat > "$OUTPUT_FILE" << 'EOF'
/// 홈 배너 assets 목록
///
/// 이 파일은 자동 생성됩니다. 수동으로 편집하지 마세요.
/// scripts/update_banner_assets.sh 스크립트를 실행하여 업데이트하세요.
class BannerAssets {
  // === 앱바 배너 (상단 헤더용) ===
  static const String _appbarBasePath = 'assets/images/home_banner/appbar_banners/';

  static const List<String> _appbarBannerFileNames = [
EOF

# 앱바 배너 파일명 목록 추가
for file in $appbar_files; do
    echo "    '$file'," >> "$OUTPUT_FILE"
done

cat >> "$OUTPUT_FILE" << 'EOF'
  ];

  /// 앱바 배너 이미지 목록
  static List<String> get appbarBannerImages =>
      _appbarBannerFileNames.map((fileName) => '$_appbarBasePath$fileName').toList();

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
EOF

# 홈 배너 파일명 목록 추가
for file in $home_files; do
    echo "    '$file'," >> "$OUTPUT_FILE"
done

# 파일 마무리
cat >> "$OUTPUT_FILE" << 'EOF'
  ];

  /// 홈 콘텐츠 배너 이미지 목록
  static List<String> get homeBannerImages =>
      _homeBannerFileNames.map((fileName) => '$_homeBasePath$fileName').toList();

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
EOF

echo "Banner assets file updated: $OUTPUT_FILE"
echo ""
echo "Found appbar banner files (${#appbar_files[@]}):"
echo "$appbar_files"
echo ""
echo "Found home banner files (${#home_files[@]}):"
echo "$home_files"