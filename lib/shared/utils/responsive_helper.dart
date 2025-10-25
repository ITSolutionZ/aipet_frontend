import 'package:flutter/material.dart';

/// レスポンシブヘルパークラス
///
/// すべての画面でMediaQueryを使用して、
/// 端末サイズに応じた適切なサイズとスペーシングを提供します
class ResponsiveHelper {
  final BuildContext context;
  final MediaQueryData _mediaQuery;

  ResponsiveHelper(this.context) : _mediaQuery = MediaQuery.of(context);

  /// 画面の幅
  double get screenWidth => _mediaQuery.size.width;

  /// 画面の高さ
  double get screenHeight => _mediaQuery.size.height;

  /// 画面の向き
  Orientation get orientation => _mediaQuery.orientation;

  /// 横向きかどうか
  bool get isLandscape => orientation == Orientation.landscape;

  /// 縦向きかどうか
  bool get isPortrait => orientation == Orientation.portrait;

  /// デバイスのピクセル密度
  double get pixelRatio => _mediaQuery.devicePixelRatio;

  /// テキストスケールファクター
  double get textScaleFactor => _mediaQuery.textScaler.scale(1.0);

  // ==================== 画面サイズ判定 ====================

  /// スマートフォンサイズ（< 600px）
  bool get isMobile => screenWidth < 600;

  /// タブレットサイズ（600px ~ 900px）
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// デスクトップサイズ（>= 900px）
  bool get isDesktop => screenWidth >= 900;

  /// 小さい画面（< 360px）
  bool get isSmallMobile => screenWidth < 360;

  /// 大きいタブレット（>= 900px & < 1200px）
  bool get isLargeTablet => screenWidth >= 900 && screenWidth < 1200;

  // ==================== レスポンシブサイズ計算 ====================

  /// 幅のパーセンテージ
  double wp(double percentage) => screenWidth * percentage / 100;

  /// 高さのパーセンテージ
  double hp(double percentage) => screenHeight * percentage / 100;

  /// 画面幅基準のレスポンシブサイズ
  /// デザインベース幅を375px（iPhone 11 Pro）とした場合のスケーリング
  double rw(double size, {double baseWidth = 375}) {
    return (screenWidth / baseWidth) * size;
  }

  /// 画面高さ基準のレスポンシブサイズ
  /// デザインベース高さを812px（iPhone 11 Pro）とした場合のスケーリング
  double rh(double size, {double baseHeight = 812}) {
    return (screenHeight / baseHeight) * size;
  }

  /// フォントサイズのレスポンシブスケーリング
  /// テキストスケールファクターも考慮
  double rf(double fontSize, {double baseWidth = 375}) {
    final scaledSize = (screenWidth / baseWidth) * fontSize;
    // 最小・最大サイズを制限
    return scaledSize.clamp(fontSize * 0.8, fontSize * 1.2);
  }

  /// アイコンサイズのレスポンシブスケーリング
  double ri(double iconSize) => rw(iconSize).clamp(iconSize * 0.8, iconSize * 1.5);

  /// スペーシングのレスポンシブスケーリング
  double rs(double spacing) => rw(spacing);

  // ==================== セーフエリア ====================

  /// トップセーフエリアのパディング
  double get topPadding => _mediaQuery.padding.top;

  /// ボトムセーフエリアのパディング
  double get bottomPadding => _mediaQuery.padding.bottom;

  /// 左セーフエリアのパディング
  double get leftPadding => _mediaQuery.padding.left;

  /// 右セーフエリアのパディング
  double get rightPadding => _mediaQuery.padding.right;

  /// セーフエリアを考慮した画面高さ
  double get safeHeight => screenHeight - topPadding - bottomPadding;

  /// セーフエリアを考慮した画面幅
  double get safeWidth => screenWidth - leftPadding - rightPadding;

  // ==================== レスポンシブEdgeInsets ====================

  /// レスポンシブな全方向パディング
  EdgeInsets rPadding(double padding) {
    return EdgeInsets.all(rs(padding));
  }

  /// レスポンシブな対称パディング
  EdgeInsets rPaddingSymmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal != null ? rs(horizontal) : 0,
      vertical: vertical != null ? rs(vertical) : 0,
    );
  }

  /// レスポンシブな個別パディング
  EdgeInsets rPaddingOnly({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null ? rs(left) : 0,
      top: top != null ? rs(top) : 0,
      right: right != null ? rs(right) : 0,
      bottom: bottom != null ? rs(bottom) : 0,
    );
  }

  // ==================== デバイス情報 ====================

  /// キーボードが表示されているかどうか
  bool get isKeyboardVisible => _mediaQuery.viewInsets.bottom > 0;

  /// キーボードの高さ
  double get keyboardHeight => _mediaQuery.viewInsets.bottom;

  /// ステータスバーの高さ
  double get statusBarHeight => _mediaQuery.padding.top;

  /// ナビゲーションバーの高さ
  double get navigationBarHeight => _mediaQuery.padding.bottom;

  // ==================== 条件付きレイアウト ====================

  /// デバイスサイズに応じた値を返す
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  /// デバイスサイズに応じたウィジェットを返す
  Widget responsiveWidget({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // ==================== 静的メソッド ====================

  /// BuildContextから直接ResponsiveHelperを取得
  static ResponsiveHelper of(BuildContext context) {
    return ResponsiveHelper(context);
  }

  /// 画面幅のパーセンテージ（静的）
  static double widthPercent(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage / 100;
  }

  /// 画面高さのパーセンテージ（静的）
  static double heightPercent(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage / 100;
  }

  /// レスポンシブ幅（静的）
  static double responsiveWidth(
    BuildContext context,
    double size, {
    double baseWidth = 375,
  }) {
    final width = MediaQuery.of(context).size.width;
    return (width / baseWidth) * size;
  }

  /// レスポンシブ高さ（静的）
  static double responsiveHeight(
    BuildContext context,
    double size, {
    double baseHeight = 812,
  }) {
    final height = MediaQuery.of(context).size.height;
    return (height / baseHeight) * size;
  }

  /// レスポンシブフォントサイズ（静的）
  static double responsiveFontSize(
    BuildContext context,
    double fontSize, {
    double baseWidth = 375,
  }) {
    final width = MediaQuery.of(context).size.width;
    final scaledSize = (width / baseWidth) * fontSize;
    return scaledSize.clamp(fontSize * 0.8, fontSize * 1.2);
  }
}

/// ResponsiveHelper のエクステンション
extension ResponsiveExtension on BuildContext {
  /// BuildContextからResponsiveHelperを取得
  ResponsiveHelper get responsive => ResponsiveHelper(this);

  /// 画面の幅
  double get screenWidth => MediaQuery.of(this).size.width;

  /// 画面の高さ
  double get screenHeight => MediaQuery.of(this).size.height;

  /// スマートフォンかどうか
  bool get isMobile => screenWidth < 600;

  /// タブレットかどうか
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// デスクトップかどうか
  bool get isDesktop => screenWidth >= 900;
}
