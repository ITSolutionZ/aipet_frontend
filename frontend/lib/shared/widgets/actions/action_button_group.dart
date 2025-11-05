import 'package:flutter/material.dart';

import '../../../shared/shared.dart';

/// 액션 버튼 그룹 컴포넌트
///
/// 일관된 스타일의 액션 버튼들을 그룹으로 관리합니다.
class ActionButtonGroup extends StatelessWidget {
  final List<ActionButtonData> buttons;
  final MainAxisAlignment alignment;
  final double? spacing;
  final Axis direction;

  const ActionButtonGroup({
    super.key,
    required this.buttons,
    this.alignment = MainAxisAlignment.spaceEvenly,
    this.spacing,
    this.direction = Axis.horizontal,
  });

  /// 세로 방향 버튼 그룹
  const ActionButtonGroup.vertical({
    super.key,
    required this.buttons,
    this.alignment = MainAxisAlignment.center,
    this.spacing,
  }) : direction = Axis.vertical;

  /// 가로 방향 버튼 그룹
  const ActionButtonGroup.horizontal({
    super.key,
    required this.buttons,
    this.alignment = MainAxisAlignment.spaceEvenly,
    this.spacing,
  }) : direction = Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.vertical) {
      return Column(
        mainAxisAlignment: alignment,
        children: _buildVerticalButtons(),
      );
    } else {
      return Row(
        mainAxisAlignment: alignment,
        children: _buildHorizontalButtons(),
      );
    }
  }

  List<Widget> _buildVerticalButtons() {
    final widgets = <Widget>[];
    for (int i = 0; i < buttons.length; i++) {
      if (i > 0) {
        widgets.add(SizedBox(height: spacing ?? AppSpacing.sm));
      }
      widgets.add(ActionButton(data: buttons[i]));
    }
    return widgets;
  }

  List<Widget> _buildHorizontalButtons() {
    final widgets = <Widget>[];
    for (int i = 0; i < buttons.length; i++) {
      if (i > 0) {
        widgets.add(SizedBox(width: spacing ?? AppSpacing.sm));
      }
      widgets.add(Expanded(child: ActionButton(data: buttons[i])));
    }
    return widgets;
  }
}

/// 액션 버튼 데이터 클래스
class ActionButtonData {
  final String text;
  final VoidCallback? onPressed;
  final ActionButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  const ActionButtonData({
    required this.text,
    this.onPressed,
    this.type = ActionButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.width,
    this.height,
  });

  /// Primary 버튼 생성
  ActionButtonData.primary({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
  }) : type = ActionButtonType.primary,
       backgroundColor = AppColors.primary,
       foregroundColor = Colors.white,
       borderColor = null;

  /// Secondary 버튼 생성
  ActionButtonData.secondary({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
  }) : type = ActionButtonType.secondary,
       backgroundColor = Colors.white,
       foregroundColor = AppColors.primary,
       borderColor = AppColors.primary;

  /// Outlined 버튼 생성
  ActionButtonData.outlined({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
  }) : type = ActionButtonType.outlined,
       backgroundColor = Colors.transparent,
       foregroundColor = AppColors.textSecondary,
       borderColor = AppColors.borderGray;

  /// Text 버튼 생성
  ActionButtonData.text({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.width,
    this.height,
  }) : type = ActionButtonType.text,
       backgroundColor = Colors.transparent,
       foregroundColor = AppColors.primary,
       borderColor = null;
}

/// 액션 버튼 타입
enum ActionButtonType { primary, secondary, outlined, text }

/// 개별 액션 버튼 위젯
class ActionButton extends StatelessWidget {
  final ActionButtonData data;

  const ActionButton({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDisabled =
        !data.enabled || data.isLoading || data.onPressed == null;

    switch (data.type) {
      case ActionButtonType.primary:
        return _buildElevatedButton(isDisabled);
      case ActionButtonType.secondary:
        return _buildFilledButton(isDisabled);
      case ActionButtonType.outlined:
        return _buildOutlinedButton(isDisabled);
      case ActionButtonType.text:
        return _buildTextButton(isDisabled);
    }
  }

  Widget _buildElevatedButton(bool isDisabled) {
    return SizedBox(
      width: data.width ?? double.infinity,
      height: data.height ?? 48,
      child: ElevatedButton.icon(
        onPressed: isDisabled ? null : data.onPressed,
        icon: _buildIcon(),
        label: _buildLabel(),
        style: ElevatedButton.styleFrom(
          backgroundColor: data.backgroundColor ?? AppColors.primary,
          foregroundColor: data.foregroundColor ?? Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          elevation: isDisabled ? 0 : 2,
        ),
      ),
    );
  }

  Widget _buildFilledButton(bool isDisabled) {
    return SizedBox(
      width: data.width ?? double.infinity,
      height: data.height ?? 48,
      child: FilledButton.icon(
        onPressed: isDisabled ? null : data.onPressed,
        icon: _buildIcon(),
        label: _buildLabel(),
        style: FilledButton.styleFrom(
          backgroundColor: data.backgroundColor ?? Colors.white,
          foregroundColor: data.foregroundColor ?? AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(bool isDisabled) {
    return SizedBox(
      width: data.width ?? double.infinity,
      height: data.height ?? 48,
      child: OutlinedButton.icon(
        onPressed: isDisabled ? null : data.onPressed,
        icon: _buildIcon(),
        label: _buildLabel(),
        style: OutlinedButton.styleFrom(
          backgroundColor: data.backgroundColor ?? Colors.transparent,
          foregroundColor: data.foregroundColor ?? AppColors.textSecondary,
          side: BorderSide(color: data.borderColor ?? AppColors.borderGray),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(bool isDisabled) {
    return SizedBox(
      width: data.width ?? double.infinity,
      height: data.height ?? 48,
      child: TextButton.icon(
        onPressed: isDisabled ? null : data.onPressed,
        icon: _buildIcon(),
        label: _buildLabel(),
        style: TextButton.styleFrom(
          backgroundColor: data.backgroundColor ?? Colors.transparent,
          foregroundColor: data.foregroundColor ?? AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (data.isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (data.icon != null) {
      return Icon(data.icon, size: 20);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLabel() {
    return Text(
      data.text,
      style: AppFonts.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: data.foregroundColor ?? Colors.white,
      ),
    );
  }
}
