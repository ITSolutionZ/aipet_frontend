import 'dart:ui';

import 'package:flutter/material.dart';

import 'banner_type.dart';

/// NotificationBanner: reusable glass-style banner for alerts
class NotificationBanner extends StatelessWidget {
  final String message;
  final BannerType type;
  final VoidCallback? onDismiss;
  final Widget? leading;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  const NotificationBanner({
    super.key,
    required this.message,
    this.type = BannerType.info,
    this.onDismiss,
    this.leading,
    this.margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
    this.borderRadius = 12,
  });

  Color _baseColor(BuildContext context) {
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
    final baseColor = _baseColor(context);

    return Container(
      margin: margin,
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
              children: [
                leading ?? Icon(_defaultIcon(), color: baseColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ),
                if (onDismiss != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDismiss,
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white.withAlpha(180),
                    ),
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
