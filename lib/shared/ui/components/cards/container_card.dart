import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 📦 컨테이너 카드
///
/// 일반적인 콘텐츠 래핑에 특화된 카드 컴포넌트
class ContainerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final bool isEnabled;
  final String? semanticLabel;

  const ContainerCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.onTap,
    this.isEnabled = true,
    this.semanticLabel,
  });

  /// 기본 컨테이너 카드 팩토리
  factory ContainerCard.basic({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return ContainerCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.pureWhite,
      borderRadius: AppRadius.medium,
      elevation: 2,
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// 플랫 컨테이너 카드 팩토리 (그림자 없음)
  factory ContainerCard.flat({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? borderColor,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return ContainerCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      backgroundColor: backgroundColor ?? AppColors.pureWhite,
      borderColor: borderColor ?? AppColors.pointDark.withValues(alpha: 0.1),
      borderRadius: AppRadius.medium,
      elevation: 0,
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// 높은 elevation 컨테이너 카드 팩토리
  factory ContainerCard.elevated({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return ContainerCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: backgroundColor ?? AppColors.pureWhite,
      borderRadius: AppRadius.large,
      elevation: 8,
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// 둥근 모서리 컨테이너 카드 팩토리
  factory ContainerCard.rounded({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return ContainerCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      backgroundColor: backgroundColor ?? AppColors.pureWhite,
      borderRadius: AppRadius.large,
      elevation: 4,
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.pureWhite,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.medium),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: AppColors.pointDark.withValues(alpha: 0.1),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation!),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null && isEnabled) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.medium),
          child: card,
        ),
      );
    }

    if (!isEnabled) {
      card = Opacity(opacity: 0.6, child: card);
    }

    if (semanticLabel != null) {
      card = Semantics(label: semanticLabel, child: card);
    }

    return card;
  }
}
