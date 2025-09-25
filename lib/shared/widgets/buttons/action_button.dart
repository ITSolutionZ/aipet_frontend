import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 범용 액션 버튼 위젯
/// 다양한 상황에서 재사용 가능한 버튼 컴포넌트
class ActionButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final ActionButtonVariant variant;

  const ActionButton({
    super.key,
    required this.isEnabled,
    this.onPressed,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.variant = ActionButtonVariant.primary,
  });

  /// 주요 액션 버튼 (Primary)
  const ActionButton.primary({
    super.key,
    required this.isEnabled,
    this.onPressed,
    required this.text,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    bool? enabled,
  }) : backgroundColor = null,
       foregroundColor = null,
       disabledBackgroundColor = null,
       disabledForegroundColor = null,
       variant = ActionButtonVariant.primary;

  /// 보조 액션 버튼 (Secondary)
  const ActionButton.secondary({
    super.key,
    required this.isEnabled,
    this.onPressed,
    required this.text,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    bool? enabled,
  }) : backgroundColor = null,
       foregroundColor = null,
       disabledBackgroundColor = null,
       disabledForegroundColor = null,
       variant = ActionButtonVariant.secondary;

  /// 아웃라인 버튼 (Outlined)
  const ActionButton.outlined({
    super.key,
    required this.isEnabled,
    this.onPressed,
    required this.text,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    bool? enabled,
  }) : backgroundColor = null,
       foregroundColor = null,
       disabledBackgroundColor = null,
       disabledForegroundColor = null,
       variant = ActionButtonVariant.outlined;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? double.infinity;
    final effectiveHeight = height ?? 48.0;
    final effectivePadding =
        padding ??
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        );
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppRadius.medium);

    final colors = _getColors();
    final currentBackgroundColor = isEnabled
        ? colors.backgroundColor
        : colors.disabledBackgroundColor;
    final currentForegroundColor = isEnabled
        ? colors.foregroundColor
        : colors.disabledForegroundColor;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: currentBackgroundColor,
          foregroundColor: currentForegroundColor,
          padding: effectivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: effectiveBorderRadius,
            side: variant == ActionButtonVariant.outlined
                ? BorderSide(
                    color: isEnabled
                        ? AppColors.pointBrown
                        : AppColors.pointGray,
                    width: 1,
                  )
                : BorderSide.none,
          ),
          elevation: variant == ActionButtonVariant.outlined ? 0 : 2,
          shadowColor: AppColors.pointBrown.withValues(alpha: 0.3),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    currentForegroundColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: AppFonts.titleMedium.copyWith(
                        color: currentForegroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _ButtonColors _getColors() {
    switch (variant) {
      case ActionButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: backgroundColor ?? AppColors.pointBrown,
          foregroundColor: foregroundColor ?? AppColors.pureWhite,
          disabledBackgroundColor:
              disabledBackgroundColor ??
              AppColors.pointPink.withValues(alpha: 0.3),
          disabledForegroundColor:
              disabledForegroundColor ?? AppColors.pointGray,
        );
      case ActionButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor:
              backgroundColor ?? AppColors.pointPink.withValues(alpha: 0.1),
          foregroundColor: foregroundColor ?? AppColors.pointBrown,
          disabledBackgroundColor:
              disabledBackgroundColor ??
              AppColors.pointGray.withValues(alpha: 0.1),
          disabledForegroundColor:
              disabledForegroundColor ?? AppColors.pointGray,
        );
      case ActionButtonVariant.outlined:
        return _ButtonColors(
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: foregroundColor ?? AppColors.pointBrown,
          disabledBackgroundColor:
              disabledBackgroundColor ?? Colors.transparent,
          disabledForegroundColor:
              disabledForegroundColor ?? AppColors.pointGray,
        );
    }
  }
}

enum ActionButtonVariant { primary, secondary, outlined }

class _ButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color disabledBackgroundColor;
  final Color disabledForegroundColor;

  const _ButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.disabledBackgroundColor,
    required this.disabledForegroundColor,
  });
}
