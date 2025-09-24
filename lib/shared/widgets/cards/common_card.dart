import 'package:aipet_frontend/shared/ui/components/cards/cards.dart';
import 'package:flutter/material.dart';

/// ⚠️ DEPRECATED: 기존 API 호환성을 위해 유지됨
/// 새로운 코드에서는 전문화된 카드 컴포넌트를 직접 사용하세요.
///
/// 마이그레이션 예시:
/// ```dart
/// // Before (DEPRECATED)
/// InfoCard(title: "제목", subtitle: "부제목", icon: Icons.info)
///
/// // After (RECOMMENDED)
/// InfoCard.basic(child: Text("내용"))
/// MetricCard.simple(title: "제목", value: "값")
/// ButtonCard.primary(title: "버튼", onTap: () {})
/// ```

@Deprecated('Use specialized card components instead')
abstract class CommonCard extends StatelessWidget {
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final double? elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isDisabled;
  final bool isSelected;
  final String? semanticLabel;

  const CommonCard({
    super.key,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.elevation,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.isLoading = false,
    this.isDisabled = false,
    this.isSelected = false,
    this.semanticLabel,
  });

  /// 카드 내용을 빌드하는 추상 메서드
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return ContainerCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      elevation: elevation ?? 2,
      isEnabled: !isDisabled,
      semanticLabel: semanticLabel,
      child: buildContent(context),
    );
  }
}

@Deprecated('Use InfoCard.basic() instead')
class LegacyInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final String? semanticLabel;

  const LegacyInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: iconColor ?? Colors.blue,
                  size: 24,
                ),
                child: icon!,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

@Deprecated('Use MetricCard.simple() or MetricCard.withChange() instead')
class LegacyMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String? change;
  final bool? isPositiveChange;
  final Widget? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const LegacyMetricCard({
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

  @override
  Widget build(BuildContext context) {
    if (change != null) {
      return MetricCard.withChange(
        title: title,
        value: value,
        change: change!,
        isPositiveChange: isPositiveChange ?? true,
        unit: unit,
        icon: icon,
        iconColor: iconColor,
        onTap: onTap,
        semanticLabel: semanticLabel,
      );
    } else {
      return MetricCard.simple(
        title: title,
        value: value,
        unit: unit,
        icon: icon,
        onTap: onTap,
        semanticLabel: semanticLabel,
      );
    }
  }
}

@Deprecated('Use ButtonCard.primary() or ButtonCard.secondary() instead')
class LegacyButtonCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final bool isEnabled;
  final String? semanticLabel;

  const LegacyButtonCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.onTap,
    this.isEnabled = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonCard.primary(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      isEnabled: isEnabled,
      semanticLabel: semanticLabel,
    );
  }
}