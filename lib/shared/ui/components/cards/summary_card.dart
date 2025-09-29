import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 📄 요약 정보 카드
///
/// 요약 및 개요 정보 표시에 특화된 카드 컴포넌트
class SummaryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? value;
  final String? unit;
  final Widget? icon;
  final Color? iconColor;
  final Widget? leading;
  final Widget? trailing;
  final bool isLoading;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const SummaryCard({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.leading,
    this.trailing,
    this.isLoading = false,
    this.onTap,
    this.semanticLabel,
  });

  /// 기본 요약 카드 팩토리
  factory SummaryCard.basic({
    required String title,
    String? subtitle,
    Widget? icon,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return SummaryCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  /// 값이 포함된 요약 카드 팩토리
  factory SummaryCard.withValue({
    required String title,
    required String value,
    String? subtitle,
    String? unit,
    Widget? icon,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return SummaryCard(
      title: title,
      subtitle: subtitle,
      value: value,
      unit: unit,
      icon: icon,
      iconColor: iconColor,
      trailing: trailing,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  /// 로딩 상태 요약 카드 팩토리
  factory SummaryCard.loading({
    required String title,
    String? subtitle,
    Widget? icon,
    String? semanticLabel,
  }) {
    return SummaryCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isLoading: true,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: const const const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: AppColors.pointDark.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading ? _buildLoadingContent() : _buildContent(),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: card,
      );
    }

    if (semanticLabel != null) {
      card = Semantics(label: semanticLabel, child: card);
    }

    return card;
  }

  Widget _buildLoadingContent() {
    return Row(
      children: [
        if (icon != null) ...[
          _buildIconContainer(),
          const const const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const const const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        const const const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              iconColor ?? AppColors.pointBrown,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const const const SizedBox(width: AppSpacing.md),
        ],
        if (icon != null) ...[
          _buildIconContainer(),
          const const const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const const const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (value != null) ...[
          const const const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value!,
                style: AppFonts.titleLarge.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unit != null)
                Text(
                  unit!,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ],
        if (trailing != null) ...[
          const const const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }

  Widget _buildIconContainer() {
    if (icon == null) return const SizedBox.shrink();

    return Container(
      padding: const const const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.pointBrown).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: IconTheme(
        data: IconThemeData(color: iconColor ?? AppColors.pointBrown, size: 24),
        child: icon!,
      ),
    );
  }
}
