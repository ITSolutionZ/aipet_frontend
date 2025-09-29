import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 🎯 간소화된 AppCard
///
/// ## 설계 원칙
/// - ✅ 단일 파일로 모든 카드 변형 제공
/// - ✅ 팩토리 패턴으로 간단한 API
/// - ✅ 과도한 추상화 제거
/// - ✅ 성능 최적화
///
/// **Before**: 8개 파일, 1,700+ 줄
/// **After**: 1개 파일, < 200줄
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;

  const AppCard._({
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
  });

  /// 🏗️ 팩토리 생성자들

  /// 기본 카드 (가장 일반적인 사용)
  factory AppCard({
    required Widget child,
    EdgeInsetsGeometry? padding = const const EdgeInsets.all(AppSpacing.md),
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return AppCard._(
      padding: padding,
      margin: margin,
      backgroundColor: AppColors.cardBackgroundWhite,
      elevation: 2,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      onTap: onTap,
      child: child,
    );
  }

  /// 강조된 카드 (그림자 있음)
  factory AppCard.elevated({
    required Widget child,
    EdgeInsetsGeometry? padding = const const EdgeInsets.all(AppSpacing.md),
    EdgeInsetsGeometry? margin,
    double elevation = 4,
    VoidCallback? onTap,
  }) {
    return AppCard._(
      padding: padding,
      margin: margin,
      backgroundColor: AppColors.cardBackgroundWhite,
      elevation: elevation,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      onTap: onTap,
      child: child,
    );
  }

  /// 테두리가 있는 카드
  factory AppCard.outlined({
    required Widget child,
    EdgeInsetsGeometry? padding = const const EdgeInsets.all(AppSpacing.md),
    EdgeInsetsGeometry? margin,
    Color borderColor = AppColors.borderGray,
    VoidCallback? onTap,
  }) {
    return AppCard._(
      padding: padding,
      margin: margin,
      backgroundColor: AppColors.cardBackgroundWhite,
      elevation: 0,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      border: Border.all(color: borderColor),
      onTap: onTap,
      child: child,
    );
  }

  /// 플랫 카드 (그림자 없음)
  factory AppCard.flat({
    required Widget child,
    EdgeInsetsGeometry? padding = const const EdgeInsets.all(AppSpacing.md),
    EdgeInsetsGeometry? margin,
    Color? backgroundColor = AppColors.cardBackgroundGray,
    VoidCallback? onTap,
  }) {
    return AppCard._(
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      onTap: onTap,
      child: child,
    );
  }

  /// 선택 가능한 카드
  factory AppCard.selectable({
    required Widget child,
    required bool isSelected,
    EdgeInsetsGeometry? padding = const const EdgeInsets.all(AppSpacing.md),
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return AppCard._(
      padding: padding,
      margin: margin,
      backgroundColor: isSelected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.cardBackgroundWhite,
      elevation: isSelected ? 4 : 1,
      borderRadius: BorderRadius.circular(AppSpacing.md),
      border: Border.all(
        color: isSelected ? AppColors.primary : AppColors.borderGray,
        width: isSelected ? 2 : 1,
      ),
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cardWidget = Material(
      color: backgroundColor,
      elevation: elevation ?? 0,
      borderRadius: borderRadius,
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(borderRadius: borderRadius, border: border),
        child: child,
      ),
    );

    if (onTap != null) {
      cardWidget = InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// 📋 정보 표시용 카드
class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const const const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const const const SizedBox(width: AppSpacing.md),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// 📊 요약 정보 카드
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? accentColor;
  final IconData? icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.accentColor = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (icon != null) Icon(icon, color: accentColor, size: 20),
            ],
          ),
          const const const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const const const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
