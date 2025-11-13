import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 공통 카드 컨테이너 컴포넌트
///
/// 모든 화면에서 일관된 스타일의 카드 컨테이너를 제공합니다.
class CardContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  const CardContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
    this.constraints,
  });

  /// 기본 스타일의 카드 컨테이너
  const CardContainer.standard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
  }) : backgroundColor = Colors.white,
       borderRadius = AppSpacing.md,
       boxShadow = const [
         BoxShadow(
           color: Color.fromRGBO(0, 0, 0, 0.05),
           blurRadius: 8,
           offset: Offset(0, 4),
         ),
       ],
       border = null;

  /// 강조된 스타일의 카드 컨테이너
  const CardContainer.highlighted({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
  }) : backgroundColor = Colors.white,
       borderRadius = AppSpacing.md,
       boxShadow = const [
         BoxShadow(
           color: Color.fromRGBO(0, 0, 0, 0.08),
           blurRadius: 12,
           offset: Offset(0, 4),
         ),
       ],
       border = null;

  /// 테두리가 있는 카드 컨테이너
  const CardContainer.bordered({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    Border? border,
  }) : backgroundColor = Colors.white,
       borderRadius = AppSpacing.md,
       boxShadow = const [
         BoxShadow(
           color: Color.fromRGBO(0, 0, 0, 0.05),
           blurRadius: 4,
           offset: Offset(0, 2),
         ),
       ],
       border =
           border ??
           const Border.fromBorderSide(BorderSide(color: AppColors.borderGray));

  /// 투명 배경의 카드 컨테이너
  const CardContainer.transparent({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
  }) : backgroundColor = Colors.transparent,
       borderRadius = AppSpacing.md,
       boxShadow = null,
       border = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? AppSpacing.md),
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// 섹션 헤더가 포함된 카드 컨테이너
class SectionCardContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final Widget? titleWidget;
  final Widget? actionWidget;

  const SectionCardContainer({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.width,
    this.height,
    this.constraints,
    this.titleWidget,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      border: border,
      width: width,
      height: height,
      constraints: constraints,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titleWidget != null)
                      titleWidget!
                    else
                      Text(
                        title,
                        style: AppFonts.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle!,
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actionWidget != null) actionWidget!,
            ],
          ),

          // 콘텐츠
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
