import 'package:flutter/material.dart';

/// 섹션 헤더 위젯
class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const const const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      titleStyle ??
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (subtitle != null) ...[
                  const const const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style:
                        subtitleStyle ??
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[const const const SizedBox(width: 16), action!],
        ],
      ),
    );
  }
}
