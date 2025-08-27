import 'package:flutter/material.dart';

/// 화면 크기 타입
enum ScreenSize {
  small, // 모바일 (320-480px)
  medium, // 태블릿 (481-768px)
  large, // 데스크톱 (769px+)
}

/// 반응형 레이아웃 위젯
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint = 480.0,
    this.tabletBreakpoint = 768.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= tabletBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (width >= mobileBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }

  /// 현재 화면 크기 타입 반환
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 768.0) {
      return ScreenSize.large;
    } else if (width >= 480.0) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.small;
    }
  }

  /// 화면 크기별 조건부 위젯 반환
  static Widget responsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return ResponsiveLayout(mobile: mobile, tablet: tablet, desktop: desktop);
  }
}

/// 반응형 그리드 위젯
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double mobileCrossAxisCount;
  final double tabletCrossAxisCount;
  final double desktopCrossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileCrossAxisCount = 1.0,
    this.tabletCrossAxisCount = 2.0,
    this.desktopCrossAxisCount = 3.0,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double crossAxisCount;

        if (width >= 768.0) {
          crossAxisCount = desktopCrossAxisCount;
        } else if (width >= 480.0) {
          crossAxisCount = tabletCrossAxisCount;
        } else {
          crossAxisCount = mobileCrossAxisCount;
        }

        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount.toInt(),
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// 반응형 컨테이너 위젯
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double? containerWidth;
        double? containerHeight;
        EdgeInsetsGeometry? containerPadding;

        if (width >= 768.0) {
          containerWidth = desktopWidth;
          containerHeight = desktopHeight;
          containerPadding = desktopPadding;
        } else if (width >= 480.0) {
          containerWidth = tabletWidth;
          containerHeight = tabletHeight;
          containerPadding = tabletPadding;
        } else {
          containerWidth = mobileWidth;
          containerHeight = mobileHeight;
          containerPadding = mobilePadding;
        }

        return Container(
          width: containerWidth,
          height: containerHeight,
          padding: containerPadding,
          decoration: decoration,
          child: child,
        );
      },
    );
  }
}

/// 반응형 텍스트 위젯
class ResponsiveText extends StatelessWidget {
  final String text;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double? fontSize;

        if (width >= 768.0) {
          fontSize = desktopFontSize;
        } else if (width >= 480.0) {
          fontSize = tabletFontSize;
        } else {
          fontSize = mobileFontSize;
        }

        return Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
