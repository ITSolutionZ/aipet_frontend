import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 📋 정보 표시용 카드
///
/// 단순한 정보 표시에 특화된 카드 컴포넌트
class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const InfoCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
    this.semanticLabel,
  });

  /// 기본 정보 카드 팩토리
  factory InfoCard.basic({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return InfoCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.pureWhite,
      borderRadius: AppRadius.medium,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// 강조 정보 카드 팩토리
  factory InfoCard.highlighted({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return InfoCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: AppColors.pointBlue.withValues(alpha: 0.05),
      borderRadius: AppRadius.large,
      border: Border.all(
        color: AppColors.pointBlue.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.pointBlue.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.pureWhite,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.medium),
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.medium),
        child: card,
      );
    }

    if (semanticLabel != null) {
      card = Semantics(label: semanticLabel, child: card);
    }

    return card;
  }
}
