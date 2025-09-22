import 'package:flutter/material.dart';

import '../../../design/tokens/tokens.dart';

/// 📊 메트릭 표시용 카드
///
/// 통계 및 수치 데이터 표시에 특화된 카드 컴포넌트
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String? change;
  final bool? isPositiveChange;
  final Widget? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.change,
    this.isPositiveChange,
    this.icon,
    this.iconColor,
    this.onTap,
    this.semanticLabel,
  });

  /// 간단한 메트릭 카드 팩토리
  factory MetricCard.simple({
    required String title,
    required String value,
    String? unit,
    Widget? icon,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return MetricCard(
      title: title,
      value: value,
      unit: unit,
      icon: icon,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  /// 변화량이 포함된 메트릭 카드 팩토리
  factory MetricCard.withChange({
    required String title,
    required String value,
    required String change,
    required bool isPositiveChange,
    String? unit,
    Widget? icon,
    Color? iconColor,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return MetricCard(
      title: title,
      value: value,
      unit: unit,
      change: change,
      isPositiveChange: isPositiveChange,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                _buildIconContainer(),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppFonts.headlineMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.6),
                  ),
                ),
              ],
              const Spacer(),
              if (change != null) _buildChangeIndicator(),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: card,
      );
    }

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        child: card,
      );
    }

    return card;
  }

  Widget _buildIconContainer() {
    if (icon == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.pointBrown).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: IconTheme(
        data: IconThemeData(
          color: iconColor ?? AppColors.pointBrown,
          size: 24,
        ),
        child: icon!,
      ),
    );
  }

  Widget _buildChangeIndicator() {
    if (change == null) return const SizedBox.shrink();

    final isPositive = isPositiveChange ?? true;
    final color = isPositive ? Colors.green : Colors.red;
    final iconData = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, size: 16, color: color),
        const SizedBox(width: 2),
        Text(
          change!,
          style: AppFonts.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}