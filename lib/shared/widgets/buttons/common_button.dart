import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 공통 버튼 위젯
///
/// 모든 feature에서 공통으로 사용되는 버튼 패턴을 제공합니다.
class CommonButton extends StatelessWidget {
  /// 버튼 텍스트
  final String text;

  /// 버튼 클릭 콜백
  final VoidCallback? onPressed;

  /// 버튼 타입
  final ButtonType type;

  /// 버튼 크기
  final ButtonSize size;

  /// 버튼 너비
  final double? width;

  /// 버튼 높이
  final double? height;

  /// 로딩 중 여부
  final bool isLoading;

  /// 비활성화 여부
  final bool disabled;

  /// 아이콘
  final IconData? icon;

  /// 아이콘 위치
  final IconPosition iconPosition;

  /// 버튼 스타일
  final ButtonStyle? style;

  /// 텍스트 스타일
  final TextStyle? textStyle;

  /// 아이콘 크기
  final double? iconSize;

  /// 아이콘과 텍스트 간격
  final double? iconSpacing;

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.width,
    this.height,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.style,
    this.textStyle,
    this.iconSize,
    this.iconSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !disabled && !isLoading;

    return SizedBox(
      width: width,
      height: height ?? _getButtonHeight(),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: _getButtonStyle(isEnabled),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return _buildLoadingContent();
    }

    if (icon != null) {
      return _buildIconContent();
    }

    return _buildTextContent();
  }

  Widget _buildLoadingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
          ),
        ),
        if (text.isNotEmpty) ...[
          SizedBox(width: _getIconSpacing()),
          Text(text, style: _getTextStyle()),
        ],
      ],
    );
  }

  Widget _buildIconContent() {
    final iconWidget = Icon(icon, size: _getIconSize(), color: _getTextColor());

    final textWidget = Text(text, style: _getTextStyle());

    if (iconPosition == IconPosition.left) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          SizedBox(width: _getIconSpacing()),
          textWidget,
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          textWidget,
          SizedBox(width: _getIconSpacing()),
          iconWidget,
        ],
      );
    }
  }

  Widget _buildTextContent() {
    return Text(text, style: _getTextStyle());
  }

  ButtonStyle _getButtonStyle(bool isEnabled) {
    if (style != null) {
      return style!;
    }

    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(isEnabled),
      foregroundColor: _getTextColor(),
      elevation: _getElevation(),
      shadowColor: _getShadowColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        side: _getBorderSide(isEnabled),
      ),
      padding: _getPadding(),
    );
  }

  Color _getBackgroundColor(bool isEnabled) {
    if (!isEnabled) {
      return AppColors.pointOffWhite.withValues(alpha: 0.1);
    }

    switch (type) {
      case ButtonType.primary:
        return AppColors.pointBrown;
      case ButtonType.secondary:
        return AppColors.pointOffWhite.withValues(alpha: 0.1);
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
      case ButtonType.danger:
        return AppColors.pointPink;
      case ButtonType.success:
        return AppColors.pointGreen;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.pointOffWhite;
      case ButtonType.secondary:
        return AppColors.pointDark;
      case ButtonType.outline:
        return AppColors.pointBrown;
      case ButtonType.text:
        return AppColors.pointBrown;
      case ButtonType.danger:
        return AppColors.pointOffWhite;
      case ButtonType.success:
        return AppColors.pointOffWhite;
    }
  }

  double _getElevation() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.danger:
      case ButtonType.success:
        return 2;
      case ButtonType.secondary:
        return 1;
      case ButtonType.outline:
      case ButtonType.text:
        return 0;
    }
  }

  Color? _getShadowColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.danger:
      case ButtonType.success:
        return AppColors.pointBrown.withValues(alpha: 0.3);
      case ButtonType.secondary:
        return AppColors.pointOffWhite.withValues(alpha: 0.2);
      case ButtonType.outline:
      case ButtonType.text:
        return null;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ButtonSize.small:
        return AppRadius.small;
      case ButtonSize.medium:
        return AppRadius.medium;
      case ButtonSize.large:
        return AppRadius.large;
    }
  }

  BorderSide _getBorderSide(bool isEnabled) {
    if (!isEnabled) {
      return BorderSide(
        color: AppColors.pointOffWhite.withValues(alpha: 0.1),
        width: 1,
      );
    }

    switch (type) {
      case ButtonType.outline:
        return const BorderSide(color: AppColors.pointBrown, width: 1);
      case ButtonType.text:
        return BorderSide.none;
      default:
        return BorderSide.none;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        );
    }
  }

  double _getButtonHeight() {
    switch (size) {
      case ButtonSize.small:
        return 32;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 48;
    }
  }

  double _getIconSize() {
    return iconSize ?? (size == ButtonSize.small ? 16 : 20);
  }

  double _getIconSpacing() {
    return iconSpacing ?? AppSpacing.xs;
  }

  TextStyle _getTextStyle() {
    if (textStyle != null) {
      return textStyle!;
    }

    switch (size) {
      case ButtonSize.small:
        return AppFonts.bodySmall.copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.w500,
        );
      case ButtonSize.medium:
        return AppFonts.bodyMedium.copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.w500,
        );
      case ButtonSize.large:
        return AppFonts.bodyLarge.copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.w600,
        );
    }
  }
}

/// 버튼 타입 열거형
enum ButtonType {
  primary, // 주요 버튼
  secondary, // 보조 버튼
  outline, // 외곽선 버튼
  text, // 텍스트 버튼
  danger, // 위험 버튼
  success, // 성공 버튼
}

/// 버튼 크기 열거형
enum ButtonSize {
  small, // 작은 버튼
  medium, // 중간 버튼
  large, // 큰 버튼
}

/// 아이콘 위치 열거형
enum IconPosition {
  left, // 왼쪽
  right, // 오른쪽
}
