import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// 📝 Empty State 위젯
///
/// 데이터가 없을 때 보여주는 공통 UI 컴포넌트
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final IconData? iconData;
  final String? imagePath;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? spacing;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconData,
    this.imagePath,
    this.action,
    this.padding,
    this.titleColor,
    this.subtitleColor,
    this.spacing,
  });

  /// 기본 Empty State 팩토리
  factory EmptyState.basic({
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? action,
  }) {
    return EmptyState(
      title: title,
      subtitle: subtitle,
      iconData: icon ?? Icons.inbox_outlined,
      action: action,
      padding: const EdgeInsets.all(AppSpacing.xl),
    );
  }

  /// 검색 결과 없음 Empty State 팩토리
  factory EmptyState.search({
    String title = '検索結果がありません',
    String? subtitle = '別のキーワードで検索してみてください',
    Widget? action,
  }) {
    return EmptyState(
      title: title,
      subtitle: subtitle,
      iconData: Icons.search_off_outlined,
      action: action,
      padding: const EdgeInsets.all(AppSpacing.xl),
    );
  }

  /// 네트워크 오류 Empty State 팩토리
  factory EmptyState.networkError({
    String title = 'ネットワークエラー',
    String? subtitle = 'インターネット接続を確認してください',
    Widget? action,
  }) {
    return EmptyState(
      title: title,
      subtitle: subtitle,
      iconData: Icons.wifi_off_outlined,
      action: action,
      padding: const EdgeInsets.all(AppSpacing.xl),
    );
  }

  /// 데이터 없음 Empty State 팩토리
  factory EmptyState.noData({
    String title = 'データがありません',
    String? subtitle,
    IconData? icon,
    Widget? action,
  }) {
    return EmptyState(
      title: title,
      subtitle: subtitle,
      iconData: icon ?? Icons.folder_open_outlined,
      action: action,
      padding: const EdgeInsets.all(AppSpacing.xl),
    );
  }

  /// 커스텀 이미지가 있는 Empty State 팩토리
  factory EmptyState.withImage({
    required String title,
    required String imagePath,
    String? subtitle,
    Widget? action,
  }) {
    return EmptyState(
      title: title,
      subtitle: subtitle,
      imagePath: imagePath,
      action: action,
      padding: const EdgeInsets.all(AppSpacing.xl),
    );
  }

  /// 액션 버튼이 있는 Empty State 팩토리
  factory EmptyState.withAction({
    required String title,
    required Widget action,
    String? subtitle,
    IconData? icon,
  }) {
    return EmptyState(
      title: title,
      subtitle: subtitle,
      iconData: icon ?? Icons.add_circle_outline,
      action: action,
      padding: const EdgeInsets.all(AppSpacing.xl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppFonts.titleLarge.copyWith(
                color: titleColor ?? AppColors.pointDark,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                subtitle!,
                style: AppFonts.bodyMedium.copyWith(color: subtitleColor ?? AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: AppSpacing.xl), action!],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (icon != null) {
      return icon!;
    }

    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        height: 120,
        width: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
      );
    }

    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.pointGray.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData ?? Icons.inbox_outlined,
        size: 60,
        color: AppColors.pointGray.withValues(alpha: 0.6),
      ),
    );
  }
}
