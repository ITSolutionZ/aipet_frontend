import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 날짜 헤더 위젯
class DateHeaderWidget extends StatelessWidget {
  final DateTime? date;
  final String? customText;

  const DateHeaderWidget({super.key, this.date, this.customText});

  @override
  Widget build(BuildContext context) {
    final displayDate = date ?? DateTime.now();
    final dateText =
        customText ?? '${displayDate.month}月${displayDate.day}日 今日';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + AppSpacing.xs,
            vertical: AppSpacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            dateText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// 빈 상태 위젯
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final Color? subtitleColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: iconColor ?? Colors.grey[400]),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: titleColor ?? Colors.grey[700],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: subtitleColor ?? Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// 액션 버튼 위젯
class ActionButtonWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;

  const ActionButtonWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isPrimary
        ? ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        : OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm + AppSpacing.xs,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );

    return Semantics(
      label: text,
      button: true,
      hint: 'タップして$textを実行します',
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(icon),
              label: Text(text),
              style: buttonStyle,
            )
          : OutlinedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon),
              label: Text(text),
              style: buttonStyle,
            ),
    );
  }
}

/// 정보 카드 위젯
class InfoCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const InfoCardWidget({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg + AppSpacing.xs),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: child,
    );
  }
}

/// 섹션 헤더 위젯
class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget? action;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (action != null) ...[const Spacer(), action!],
      ],
    );
  }
}
