import 'dart:ui';

import 'package:flutter/material.dart';

import 'banner_type.dart';

/// GlassSnackbar: bottom floating notification with glass style and optional action button
class GlassSnackbar extends StatelessWidget {
  final String message;
  final Duration duration;
  final BannerType type;
  final Widget? leading;
  final double borderRadius;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClose;
  final VoidCallback? onDismissed;

  const GlassSnackbar({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.type = BannerType.info,
    this.leading,
    this.borderRadius = 12,
    this.actionLabel,
    this.onAction,
    this.onClose,
    this.onDismissed,
  });

  Color _baseColor() {
    switch (type) {
      case BannerType.success:
        return Colors.greenAccent;
      case BannerType.warning:
        return Colors.amberAccent;
      case BannerType.error:
        return Colors.redAccent;
      case BannerType.info:
        return Colors.blueAccent;
    }
  }

  IconData _defaultIcon() {
    switch (type) {
      case BannerType.success:
        return Icons.check_circle;
      case BannerType.warning:
        return Icons.warning;
      case BannerType.error:
        return Icons.error;
      case BannerType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _baseColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [baseColor.withAlpha(40), baseColor.withAlpha(20)],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: baseColor.withAlpha(80), width: 1),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                leading ?? Icon(_defaultIcon(), color: baseColor, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(foregroundColor: baseColor),
                    child: Text(
                      actionLabel!,
                      style: TextStyle(
                        color: baseColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (onClose != null) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onClose,
                    child: Icon(Icons.close, color: baseColor, size: 18),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassSnackbarWidget extends StatefulWidget {
  final GlassSnackbar snackbar;
  final OverlayEntry overlayEntry;

  const GlassSnackbarWidget({
    super.key,
    required this.snackbar,
    required this.overlayEntry,
  });

  @override
  State<GlassSnackbarWidget> createState() => _GlassSnackbarWidgetState();
}

class _GlassSnackbarWidgetState extends State<GlassSnackbarWidget>
    with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Start hidden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _visible = true;
      });
    });
    if (widget.snackbar.duration > Duration.zero) {
      Future.delayed(widget.snackbar.duration, () {
        _dismiss();
      });
    }
  }

  Future<void> _dismiss() async {
    if (!_visible) return;
    setState(() {
      _visible = false;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    widget.overlayEntry.remove();
    widget.snackbar.onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final snackbar = widget.snackbar;

    final snackbarWithClose = snackbar.onClose == null
        ? snackbar
        : GlassSnackbar(
            key: snackbar.key,
            message: snackbar.message,
            duration: snackbar.duration,
            type: snackbar.type,
            leading: snackbar.leading,
            borderRadius: snackbar.borderRadius,
            actionLabel: snackbar.actionLabel,
            onAction: snackbar.onAction,
            onClose: () {
              snackbar.onClose?.call();
              _dismiss();
            },
            onDismissed: snackbar.onDismissed,
          );

    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: snackbarWithClose,
          ),
        ),
      ),
    );
  }
}

/// Helper to show GlassSnackbar using Overlay
void showGlassSnackbar(BuildContext context, GlassSnackbar snackbar) {
  late OverlayEntry overlay;
  overlay = OverlayEntry(
    builder: (ctx) =>
        GlassSnackbarWidget(snackbar: snackbar, overlayEntry: overlay),
  );

  Overlay.of(context).insert(overlay);
}
