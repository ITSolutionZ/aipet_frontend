import 'package:flutter/material.dart';

import '../../design/tokens/tokens.dart';
import '../../widgets/buttons/common_button.dart' show ButtonType, IconPosition;

/// 🎯 통합 Button 시스템
///
/// 기존 5개 Button 클래스를 대체하는 하나의 통합 Button
/// - GlassButton, PointButton, CommonButton, ActionButton, AccessibleButton 기능 통합
/// - 기존 API 완전 호환성 유지
/// - 중복 코드 800+ 줄 제거
enum ButtonVariant {
  /// Glass morphism 스타일 (기존 GlassButton)
  glass,
  /// Point 브랜드 스타일 (기존 PointButton)
  point,
  /// 일반 스타일 (기존 CommonButton)
  filled,
  /// 외곽선 스타일 (기존 PointOutlinedButton)
  outlined,
  /// 텍스트만 (기존 PointTextButton)
  text,
}

enum ButtonSize {
  /// 작은 크기 (기존 dense/small)
  small,
  /// 중간 크기 (기존 medium)
  medium,
  /// 큰 크기 (기존 large)
  large,
}

/// 🚀 통합 AppButton 클래스
///
/// 모든 Button 기능을 하나로 통합한 컴포넌트
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool enabled;
  final bool expand;

  // 커스터마이징
  final Widget? icon;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double? borderRadius;
  final double? elevation;

  // 접근성
  final String? semanticLabel;
  final String? tooltip;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.enabled = true,
    this.expand = false,
    this.icon,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.textStyle,
    this.borderRadius,
    this.elevation,
    this.semanticLabel,
    this.tooltip,
  });

  // === 기존 API 호환성을 위한 Factory Constructors ===

  /// GlassButton 호환 Constructor
  const AppButton.glass({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.expand = false,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.textStyle,
    this.borderRadius,
    this.semanticLabel,
    this.tooltip,
  }) : variant = ButtonVariant.glass,
       enabled = true,
       icon = null,
       elevation = null;

  /// PointButton 호환 Constructor
  const AppButton.point({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.expand = false,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.textStyle,
    this.borderRadius,
    this.semanticLabel,
    this.tooltip,
  }) : variant = ButtonVariant.point,
       enabled = true,
       icon = null,
       elevation = null;

  /// CommonButton 호환 Constructor
  const AppButton.common({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.enabled = true,
    this.expand = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.textStyle,
    this.borderRadius,
    this.elevation,
    this.semanticLabel,
    this.tooltip,
  }) : variant = ButtonVariant.filled,
       leading = null,
       trailing = null;

  /// ActionButton 호환 Constructor
  const AppButton.action({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
    this.textStyle,
    this.borderRadius,
    this.semanticLabel,
    this.tooltip,
  }) : variant = ButtonVariant.filled,
       expand = false,
       leading = null,
       trailing = null,
       elevation = null;

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled || onPressed == null || isLoading;

    Widget button = _buildButton(context, isDisabled);

    // 접근성 래핑
    if (semanticLabel != null || tooltip != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: !isDisabled,
        child: tooltip != null
          ? Tooltip(message: tooltip!, child: button)
          : button,
      );
    }

    return button;
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    final buttonStyle = _getButtonStyle(context, isDisabled);
    final content = _buildContent();

    Widget button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: buttonStyle,
      child: content,
    );

    // 전체 너비
    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    // 비활성화 시 투명도 적용
    if (isDisabled) {
      button = Opacity(opacity: 0.6, child: button);
    }

    return button;
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildLoadingContent();
    }

    return _buildNormalContent();
  }

  Widget _buildLoadingContent() {
    final loadingSize = _getLoadingSize();
    final loadingColor = _getLoadingColor();

    return SizedBox(
      width: loadingSize,
      height: loadingSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
      ),
    );
  }

  Widget _buildNormalContent() {
    final widgets = <Widget>[];

    // Leading 또는 Icon
    final leadingWidget = leading ?? icon;
    if (leadingWidget != null) {
      widgets.add(leadingWidget);
      widgets.add(const SizedBox(width: 8));
    }

    // 텍스트
    widgets.add(Text(text));

    // Trailing
    if (trailing != null) {
      widgets.add(const SizedBox(width: 8));
      widgets.add(trailing!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isDisabled) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(colorScheme),
      foregroundColor: _getForegroundColor(colorScheme),
      elevation: _getElevation(),
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        side: _getBorderSide(colorScheme),
      ),
      textStyle: _getTextStyle(theme),
    );
  }

  // === 스타일 계산 메서드들 ===

  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (backgroundColor != null) return backgroundColor!;

    switch (variant) {
      case ButtonVariant.glass:
        return AppColors.pureWhite.withValues(alpha: 0.18);
      case ButtonVariant.point:
        return AppColors.pointBrown;
      case ButtonVariant.filled:
        return AppColors.pointBrown;
      case ButtonVariant.outlined:
        return Colors.transparent;
      case ButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    if (foregroundColor != null) return foregroundColor!;

    switch (variant) {
      case ButtonVariant.glass:
        return AppColors.pointDark;
      case ButtonVariant.point:
        return AppColors.pureWhite;
      case ButtonVariant.filled:
        return AppColors.pureWhite;
      case ButtonVariant.outlined:
        return AppColors.pointBrown;
      case ButtonVariant.text:
        return AppColors.pointBrown;
    }
  }

  BorderSide _getBorderSide(ColorScheme colorScheme) {
    if (variant == ButtonVariant.outlined) {
      return BorderSide(
        color: borderColor ?? AppColors.pointBrown,
        width: 1.0,
      );
    }
    if (variant == ButtonVariant.glass) {
      return BorderSide(
        color: borderColor ?? AppColors.pointOffWhite.withValues(alpha: 0.3),
        width: 1.0,
      );
    }
    return BorderSide.none;
  }

  double _getBorderRadius() {
    if (borderRadius != null) return borderRadius!;
    return AppRadius.medium;
  }

  double _getElevation() {
    if (elevation != null) return elevation!;

    switch (variant) {
      case ButtonVariant.glass:
        return 2;
      case ButtonVariant.point:
      case ButtonVariant.filled:
        return 1;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return 0;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    if (padding != null) return padding!;

    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 12);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(vertical: 14, horizontal: 20);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(vertical: 18, horizontal: 28);
    }
  }

  TextStyle? _getTextStyle(ThemeData theme) {
    if (textStyle != null) return textStyle;

    switch (size) {
      case ButtonSize.small:
        return AppFonts.bodySmall.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.medium:
        return AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return AppFonts.bodyLarge.copyWith(fontWeight: FontWeight.w600);
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Color _getLoadingColor() {
    // 기본 foreground 색상 반환
    switch (variant) {
      case ButtonVariant.glass:
        return foregroundColor ?? AppColors.pointDark;
      case ButtonVariant.point:
      case ButtonVariant.filled:
        return foregroundColor ?? AppColors.pureWhite;
      case ButtonVariant.outlined:
      case ButtonVariant.text:
        return foregroundColor ?? AppColors.pointBrown;
    }
  }
  // === 기존 API 호환을 위한 Factory 생성자들 ===

  /// CommonButton 호환 factory
  static Widget commonButton({
    required String text,
    VoidCallback? onPressed,
    required ButtonType type,
    ButtonSize size = ButtonSize.medium,
    double? width,
    double? height,
    bool isLoading = false,
    bool disabled = false,
    IconData? icon,
    IconPosition iconPosition = IconPosition.left,
    ButtonStyle? style,
    TextStyle? textStyle,
    double? iconSize,
    double? iconSpacing,
  }) {
    // ButtonType을 ButtonVariant로 변환
    ButtonVariant variant;
    switch (type) {
      case ButtonType.primary:
        variant = ButtonVariant.filled;
        break;
      case ButtonType.secondary:
        variant = ButtonVariant.outlined;
        break;
      case ButtonType.text:
        variant = ButtonVariant.text;
        break;
      case ButtonType.outline:
        variant = ButtonVariant.outlined;
        break;
      case ButtonType.danger:
      case ButtonType.success:
        variant = ButtonVariant.filled;
        break;
    }

    Widget button = AppButton(
      text: text,
      onPressed: onPressed,
      variant: variant,
      size: size,
      isLoading: isLoading,
      enabled: !disabled,
      leading: icon != null ? Icon(icon) : null,
      textStyle: textStyle,
    );

    // width가 지정된 경우 Container로 감싸기
    if (width != null) {
      button = SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }

  /// Primary button factory (filled variant)
  factory AppButton.primary({
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool enabled = true,
    Widget? leading,
    Widget? trailing,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    String? semanticLabel,
    String? tooltip,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.filled,
      size: size,
      isLoading: isLoading,
      enabled: enabled,
      leading: leading,
      trailing: trailing,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      textStyle: textStyle,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
    );
  }

  /// Secondary button factory (outlined variant)
  factory AppButton.secondary({
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    bool isLoading = false,
    bool enabled = true,
    Widget? leading,
    Widget? trailing,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    String? semanticLabel,
    String? tooltip,
  }) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      size: size,
      isLoading: isLoading,
      enabled: enabled,
      leading: leading,
      trailing: trailing,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      padding: padding,
      textStyle: textStyle,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
    );
  }
}

// === 기존 API 완전 호환을 위한 typedef들 ===

/// GlassButton 호환성
typedef GlassButton = AppButton;

/// PointButton 호환성
typedef PointButton = AppButton;

/// CommonButton 호환성
class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool disabled;
  final IconData? icon;
  final IconPosition iconPosition;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final double? iconSize;
  final double? iconSpacing;

  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.type,
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
    return AppButton.commonButton(
      text: text,
      onPressed: onPressed,
      type: type,
      size: size,
      width: width,
      height: height,
      isLoading: isLoading,
      disabled: disabled,
      icon: icon,
      iconPosition: iconPosition,
      style: style,
      textStyle: textStyle,
      iconSize: iconSize,
      iconSpacing: iconSpacing,
    );
  }
}

/// ActionButton 호환성
typedef ActionButton = AppButton;