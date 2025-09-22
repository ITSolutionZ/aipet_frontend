import 'package:flutter/material.dart';

import '../../../design/tokens/tokens.dart';

/// ✅ 선택 가능한 카드
///
/// 옵션 선택 UI에 특화된 카드 컴포넌트
class SelectionCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final Color? iconColor;
  final bool isSelected;
  final Color? selectedColor;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const SelectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.isSelected = false,
    this.selectedColor,
    this.onTap,
    this.semanticLabel,
  });

  /// 옵션 선택 카드 팩토리
  factory SelectionCard.option({
    required String title,
    String? subtitle,
    Widget? icon,
    Color? iconColor,
    bool isSelected = false,
    Color? selectedColor,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return SelectionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      isSelected: isSelected,
      selectedColor: selectedColor,
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: const SizedBox.shrink(),
    );
  }

  /// 라디오 버튼 스타일 카드 팩토리
  factory SelectionCard.radio({
    required String title,
    String? subtitle,
    bool isSelected = false,
    Color? selectedColor,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return SelectionCard(
      title: title,
      subtitle: subtitle,
      isSelected: isSelected,
      selectedColor: selectedColor,
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: const SizedBox.shrink(),
    );
  }

  /// 체크박스 스타일 카드 팩토리
  factory SelectionCard.checkbox({
    required String title,
    String? subtitle,
    Widget? icon,
    bool isSelected = false,
    Color? selectedColor,
    VoidCallback? onTap,
    String? semanticLabel,
  }) {
    return SelectionCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      isSelected: isSelected,
      selectedColor: selectedColor,
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: _getBorderColor(),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pointDark.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildContent(),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: card,
      );
    }

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        selected: isSelected,
        child: card,
      );
    }

    return card;
  }

  Widget _buildContent() {
    if (title != null || subtitle != null || icon != null) {
      return Row(
        children: [
          if (icon != null) ...[
            _buildIconContainer(),
            const SizedBox(width: AppSpacing.md),
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
          if (isSelected) _buildSelectionIndicator(),
        ],
      );
    }
    return child;
  }

  Widget _buildIconContainer() {
    if (icon == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.pointBrown).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: IconTheme(
        data: IconThemeData(
          color: iconColor ?? AppColors.pointBrown,
          size: 24,
        ),
        child: icon!,
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: selectedColor ?? AppColors.pointBrown,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return (selectedColor ?? AppColors.pointBrown).withValues(alpha: 0.1);
    }
    return AppColors.pureWhite;
  }

  Color _getBorderColor() {
    if (isSelected) {
      return selectedColor ?? AppColors.pointBrown;
    }
    return AppColors.pointDark.withValues(alpha: 0.1);
  }
}