import 'package:flutter/material.dart';

/// 접근성을 개선한 버튼 위젯
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? label;
  final String? hint;
  final bool enabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.label,
    this.hint,
    this.enabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.primaryColor;
    final effectiveForegroundColor =
        foregroundColor ??
        (theme.primaryColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white);

    return Semantics(
      button: true,
      enabled: enabled && !isLoading,
      label: label ?? _getDefaultLabel(),
      hint: hint,
      child: ExcludeSemantics(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: enabled && !isLoading
                ? effectiveBackgroundColor
                : effectiveBackgroundColor.withValues(alpha: 0.5),
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
            border: border,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled && !isLoading ? onPressed : null,
              borderRadius: borderRadius ?? BorderRadius.circular(8.0),
              child: Container(
                padding:
                    padding ??
                    const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 20.0,
                          height: 20.0,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              effectiveForegroundColor,
                            ),
                          ),
                        )
                      : DefaultTextStyle(
                          style: TextStyle(
                            color: effectiveForegroundColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                          child: child,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDefaultLabel() {
    if (child is Text) {
      return (child as Text).data ?? '버튼';
    }
    return '버튼';
  }
}

/// 접근성을 개선한 아이콘 버튼 위젯
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String label;
  final String? hint;
  final bool enabled;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsetsGeometry? padding;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.hint,
    this.enabled = true,
    this.iconColor,
    this.backgroundColor,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.iconTheme.color;
    final effectiveBackgroundColor = backgroundColor ?? theme.cardColor;
    final effectiveSize = size ?? 48.0;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      child: ExcludeSemantics(
        child: Container(
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(
            color: enabled
                ? effectiveBackgroundColor
                : effectiveBackgroundColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(effectiveSize / 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              borderRadius: BorderRadius.circular(effectiveSize / 2),
              child: Container(
                padding: padding ?? EdgeInsets.all(effectiveSize * 0.25),
                child: Icon(
                  icon,
                  color: enabled
                      ? effectiveIconColor
                      : effectiveIconColor?.withValues(alpha: 0.5),
                  size: effectiveSize * 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 접근성을 개선한 토글 버튼 위젯
class AccessibleToggleButton extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? hint;
  final Widget? activeChild;
  final Widget? inactiveChild;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? width;
  final double? height;

  const AccessibleToggleButton({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.hint,
    this.activeChild,
    this.inactiveChild,
    this.activeColor,
    this.inactiveColor,
    this.width,
    this.height,
  });

  @override
  State<AccessibleToggleButton> createState() => _AccessibleToggleButtonState();
}

class _AccessibleToggleButtonState extends State<AccessibleToggleButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = widget.activeColor ?? theme.primaryColor;
    final effectiveInactiveColor = widget.inactiveColor ?? theme.disabledColor;

    return Semantics(
      button: true,
      enabled: widget.onChanged != null,
      label: '${widget.label}: ${widget.value ? '활성화' : '비활성화'}',
      hint: widget.hint,
      child: ExcludeSemantics(
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.value ? effectiveActiveColor : effectiveInactiveColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onChanged != null
                  ? () => widget.onChanged!(!widget.value)
                  : null,
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Center(
                  child: widget.value
                      ? (widget.activeChild ??
                            const Text(
                              '활성화',
                              style: TextStyle(color: Colors.white),
                            ))
                      : (widget.inactiveChild ??
                            const Text(
                              '비활성화',
                              style: TextStyle(color: Colors.white),
                            )),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
