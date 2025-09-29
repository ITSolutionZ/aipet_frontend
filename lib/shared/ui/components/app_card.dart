import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// ⚠️ DEPRECATED: 통합 Card 시스템
///
/// 🚨 이 831라인 메가 컴포넌트는 단일 책임 원칙 위반으로 인해 분리되었습니다.
///
/// 새로운 전용 컴포넌트를 사용하세요:
/// - InfoCard: `/shared/ui/components/cards/info_card.dart`
/// - MetricCard: `/shared/ui/components/cards/metric_card.dart`
/// - SelectionCard: `/shared/ui/components/cards/selection_card.dart`
/// - ButtonCard: `/shared/ui/components/cards/button_card.dart`
/// - SummaryCard: `/shared/ui/components/cards/summary_card.dart`
/// - ContainerCard: `/shared/ui/components/cards/container_card.dart`
///
/// 마이그레이션 가이드:
/// ```dart
/// // OLD (DEPRECATED)
/// AppCard.info(title: 'Title', subtitle: 'Subtitle')
///
/// // NEW (RECOMMENDED)
/// InfoCard.basic(child: Text('Content'))
/// ```
enum CardVariant {
  /// 정보 표시용 카드 (기존 InfoCard)
  info,

  /// 메트릭/통계 카드 (기존 MetricCard)
  metric,

  /// 선택 가능한 카드 (기존 SelectionCard)
  selection,

  /// 버튼 형태 카드 (기존 ButtonCard)
  button,

  /// 요약 정보 카드 (기존 CommonSummaryCard)
  summary,

  /// 일반 컨테이너 카드
  container,
}

enum CardSize {
  /// 작은 카드
  small,

  /// 중간 카드
  medium,

  /// 큰 카드
  large,

  /// 전체 너비
  expanded,
}

enum CardElevation {
  /// 그림자 없음
  none,

  /// 낮은 그림자
  low,

  /// 중간 그림자
  medium,

  /// 높은 그림자
  high,
}

/// 🚀 통합 AppCard 클래스
///
/// 모든 Card 기능을 하나로 통합한 컴포넌트
class AppCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final CardSize size;
  final CardElevation elevation;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isLoading;
  final bool isEnabled;

  // 스타일링
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? selectedColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  // 헤더 정보 (info, metric, summary 카드용)
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final Widget? leading;
  final Widget? trailing;
  final Color? iconColor;

  // 메트릭 카드용
  final String? value;
  final String? unit;
  final String? change;
  final bool? isPositiveChange;

  // 접근성
  final String? semanticLabel;
  final String? tooltip;

  const AppCard({
    super.key,
    required this.child,
    this.variant = CardVariant.container,
    this.size = CardSize.medium,
    this.elevation = CardElevation.low,
    this.onTap,
    this.isSelected = false,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.borderColor,
    this.selectedColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.iconColor,
    this.value,
    this.unit,
    this.change,
    this.isPositiveChange,
    this.semanticLabel,
    this.tooltip,
  });

  // === 기존 API 호환성을 위한 Factory Constructors ===

  /// InfoCard 호환 Constructor
  const AppCard.info({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.semanticLabel,
    this.tooltip,
  }) : variant = CardVariant.info,
       size = CardSize.medium,
       elevation = CardElevation.low,
       child = const SizedBox.shrink(),
       isSelected = false,
       isLoading = false,
       isEnabled = true,
       selectedColor = null,
       width = null,
       height = null,
       constraints = null,
       leading = null,
       value = null,
       unit = null,
       change = null,
       isPositiveChange = null;

  /// MetricCard 호환 Constructor
  const AppCard.metric({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.change,
    this.isPositiveChange,
    this.icon,
    this.iconColor,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.semanticLabel,
    this.tooltip,
  }) : variant = CardVariant.metric,
       size = CardSize.medium,
       elevation = CardElevation.low,
       child = const SizedBox.shrink(),
       subtitle = null,
       isSelected = false,
       isLoading = false,
       isEnabled = true,
       selectedColor = null,
       width = null,
       height = null,
       constraints = null,
       leading = null,
       trailing = null;

  /// SelectionCard 호환 Constructor
  const AppCard.selection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.semanticLabel,
    this.tooltip,
  }) : variant = CardVariant.selection,
       size = CardSize.medium,
       elevation = CardElevation.low,
       isLoading = false,
       isEnabled = true,
       width = null,
       height = null,
       constraints = null,
       leading = null,
       trailing = null,
       value = null,
       unit = null,
       change = null,
       isPositiveChange = null;

  /// ButtonCard 호환 Constructor
  const AppCard.button({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.semanticLabel,
    this.tooltip,
  }) : variant = CardVariant.button,
       size = CardSize.medium,
       elevation = CardElevation.medium,
       child = const SizedBox.shrink(),
       isSelected = false,
       isLoading = false,
       isEnabled = true,
       selectedColor = null,
       width = null,
       height = null,
       constraints = null,
       leading = null,
       trailing = null,
       value = null,
       unit = null,
       change = null,
       isPositiveChange = null;

  /// SummaryCard 호환 Constructor
  const AppCard.summary({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.leading,
    this.trailing,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.semanticLabel,
    this.tooltip,
  }) : variant = CardVariant.summary,
       size = CardSize.medium,
       elevation = CardElevation.low,
       child = const SizedBox.shrink(),
       isSelected = false,
       isEnabled = true,
       selectedColor = null,
       width = null,
       height = null,
       constraints = null,
       change = null,
       isPositiveChange = null;

  @override
  Widget build(BuildContext context) {
    Widget card = _buildCard(context);

    // 접근성 래핑
    if (semanticLabel != null || tooltip != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        enabled: isEnabled,
        selected: isSelected,
        child: tooltip != null ? Tooltip(message: tooltip!, child: card) : card,
      );
    }

    // 마진 적용
    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }

  Widget _buildCard(BuildContext context) {
    final cardDecoration = _getCardDecoration(context);
    final cardPadding = _getCardPadding();
    final cardContent = _buildCardContent(context);
    final cardConstraints = _getCardConstraints();

    Widget card = Container(
      width: width,
      height: height,
      constraints: cardConstraints,
      decoration: cardDecoration,
      padding: cardPadding,
      child: cardContent,
    );

    // 인터랙션 처리
    if (onTap != null && isEnabled) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: card,
        ),
      );
    }

    // 비활성화 처리
    if (!isEnabled) {
      card = Opacity(opacity: 0.6, child: card);
    }

    return card;
  }

  Widget _buildCardContent(BuildContext context) {
    if (isLoading) {
      return _buildLoadingContent();
    }

    switch (variant) {
      case CardVariant.info:
        return _buildInfoContent();
      case CardVariant.metric:
        return _buildMetricContent();
      case CardVariant.selection:
        return _buildSelectionContent();
      case CardVariant.button:
        return _buildButtonContent();
      case CardVariant.summary:
        return _buildSummaryContent();
      case CardVariant.container:
        return child;
    }
  }

  Widget _buildLoadingContent() {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            iconColor ?? AppColors.pointBrown,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoContent() {
    return Row(
      children: [
        if (icon != null) ...[
          _buildIconContainer(),
          const const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }

  Widget _buildMetricContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              _buildIconContainer(),
              const const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Text(
                title ?? '',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value ?? '',
              style: AppFonts.headlineMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (unit != null) ...[
              const const SizedBox(width: 4),
              Text(
                unit!,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointDark.withValues(alpha: 0.6),
                ),
              ),
            ],
            const Spacer(),
            if (change != null) _buildChangeIndicator(),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionContent() {
    if (title != null || subtitle != null || icon != null) {
      return _buildInfoContent();
    }
    return child;
  }

  Widget _buildButtonContent() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const const SizedBox(width: AppSpacing.sm)],
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const const SizedBox(width: AppSpacing.md),
        ],
        if (icon != null) ...[
          _buildIconContainer(),
          const const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (value != null) ...[
          const const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value!,
                style: AppFonts.titleLarge.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unit != null)
                Text(
                  unit!,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ],
        if (trailing != null) ...[
          const const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }

  Widget _buildIconContainer() {
    if (icon == null) return const SizedBox.shrink();

    return Container(
      padding: const const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.pointBrown).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: IconTheme(
        data: IconThemeData(color: iconColor ?? AppColors.pointBrown, size: 24),
        child: icon!,
      ),
    );
  }

  Widget _buildChangeIndicator() {
    if (change == null) return const SizedBox.shrink();

    final isPositive = isPositiveChange ?? true;
    final color = isPositive ? Colors.green : Colors.red;
    final iconData = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, size: 16, color: color),
        const const SizedBox(width: 2),
        Text(
          change!,
          style: AppFonts.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // === 스타일 계산 메서드들 ===

  BoxDecoration _getCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: _getBackgroundColor(),
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: _getBorder(),
      boxShadow: _getBoxShadow(),
    );
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    if (isSelected) {
      return (selectedColor ?? AppColors.pointBrown).withValues(alpha: 0.1);
    }

    switch (variant) {
      case CardVariant.button:
        return AppColors.pureWhite;
      case CardVariant.selection:
        return AppColors.pureWhite;
      default:
        return AppColors.pureWhite;
    }
  }

  Border? _getBorder() {
    Color borderColorValue;

    if (isSelected) {
      borderColorValue = selectedColor ?? AppColors.pointBrown;
    } else if (borderColor != null) {
      borderColorValue = borderColor!;
    } else {
      borderColorValue = AppColors.pointDark.withValues(alpha: 0.1);
    }

    return Border.all(color: borderColorValue, width: isSelected ? 2 : 1);
  }

  List<BoxShadow> _getBoxShadow() {
    switch (elevation) {
      case CardElevation.none:
        return [];
      case CardElevation.low:
        return [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case CardElevation.medium:
        return [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      case CardElevation.high:
        return [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ];
    }
  }

  double _getBorderRadius() {
    if (borderRadius != null) return borderRadius!;
    return AppRadius.medium;
  }

  EdgeInsetsGeometry _getCardPadding() {
    if (padding != null) return padding!;

    switch (size) {
      case CardSize.small:
        return const const EdgeInsets.all(AppSpacing.sm);
      case CardSize.medium:
        return const const EdgeInsets.all(AppSpacing.md);
      case CardSize.large:
        return const const EdgeInsets.all(AppSpacing.lg);
      case CardSize.expanded:
        return const const EdgeInsets.all(AppSpacing.md);
    }
  }

  BoxConstraints? _getCardConstraints() {
    if (constraints != null) return constraints;

    switch (size) {
      case CardSize.small:
        return const BoxConstraints(minHeight: 60);
      case CardSize.medium:
        return const BoxConstraints(minHeight: 80);
      case CardSize.large:
        return const BoxConstraints(minHeight: 120);
      case CardSize.expanded:
        return const BoxConstraints(minWidth: double.infinity);
    }
  }
}

// === 기존 API 완전 호환을 위한 typedef들 ===

/// InfoCard 호환성
typedef InfoCard = AppCard;

/// MetricCard 호환성
typedef MetricCard = AppCard;

/// SelectionCard 호환성
typedef SelectionCard = AppCard;

/// CommonCard 호환성
typedef CommonCard = AppCard;

/// ButtonCard 호환성
typedef ButtonCard = AppCard;

/// CommonSummaryCard 호환성
class CommonSummaryCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? value;
  final String? unit;
  final IconData? icon;
  final Color? iconColor;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final String? semanticLabel;
  final String? tooltip;
  // 호환성을 위한 추가 파라미터들
  final String? mainValue;
  final String? secondaryValue;

  const CommonSummaryCard({
    super.key,
    this.title,
    this.subtitle,
    this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.leading,
    this.trailing,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.semanticLabel,
    this.tooltip,
    this.mainValue,
    this.secondaryValue,
  });

  @override
  Widget build(BuildContext context) {
    // mainValue를 value로, secondaryValue를 subtitle로 매핑
    final effectiveTitle = title ?? '';
    final effectiveValue = value ?? mainValue;
    final effectiveSubtitle = subtitle ?? secondaryValue;
    final effectiveIcon = icon != null ? Icon(icon, color: iconColor) : null;

    return AppCard.summary(
      title: effectiveTitle,
      subtitle: effectiveSubtitle,
      value: effectiveValue,
      unit: unit,
      icon: effectiveIcon,
      iconColor: iconColor,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      isLoading: isLoading,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
    );
  }
}
