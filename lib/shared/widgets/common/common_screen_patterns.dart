import 'package:aipet_frontend/shared/core/constants/app_constants.dart';
import 'package:aipet_frontend/shared/core/constants/app_texts.dart';
import 'package:flutter/material.dart';

/// 공통 화면 패턴들을 제공하는 위젯들
class CommonScreenPatterns {
  CommonScreenPatterns._();

  /// 기본 Scaffold 패턴
  static Widget buildStandardScreen({
    required String title,
    required Widget body,
    List<Widget>? actions,
    Widget? floatingActionButton,
    String? floatingActionButtonLabel,
    VoidCallback? onFloatingActionButtonPressed,
    Color? backgroundColor,
    bool showBackButton = true,
    PreferredSizeWidget? appBar,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      appBar:
          appBar ??
          _buildStandardAppBar(title: title, actions: actions, showBackButton: showBackButton),
      body: body,
      floatingActionButton:
          floatingActionButton ??
          _buildStandardFAB(
            label: floatingActionButtonLabel,
            onPressed: onFloatingActionButtonPressed,
          ),
    );
  }

  /// 기본 AppBar 생성
  static PreferredSizeWidget _buildStandardAppBar({
    required String title,
    List<Widget>? actions,
    bool showBackButton = true,
  }) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      automaticallyImplyLeading: showBackButton,
      actions: actions,
    );
  }

  /// 기본 FloatingActionButton 생성
  static Widget? _buildStandardFAB({String? label, VoidCallback? onPressed}) {
    if (onPressed == null) return null;

    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(label),
      );
    } else {
      return FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      );
    }
  }

  /// 스크롤 가능한 컨텐츠 패턴
  static Widget buildScrollableContent({
    required List<Widget> children,
    EdgeInsets? padding,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return SingleChildScrollView(
      padding: padding ?? const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(crossAxisAlignment: crossAxisAlignment, children: children),
    );
  }

  /// 카드 리스트 패턴
  static Widget buildCardList({
    required List<Widget> cards,
    EdgeInsets? padding,
    double spacing = AppConstants.spacingLG,
  }) {
    return SingleChildScrollView(
      padding: padding ?? const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        children: cards
            .expand((card) => [card, SizedBox(height: spacing)])
            .take(cards.length * 2 - 1)
            .toList(),
      ),
    );
  }
}

/// 공통 카드 위젯 패턴
class CommonCardPatterns {
  CommonCardPatterns._();

  /// 기본 카드 위젯
  static Widget buildCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? elevation,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    final card = Card(
      elevation: elevation ?? AppConstants.defaultCardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      color: backgroundColor,
      margin: margin,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppConstants.spacingMD),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: card,
      );
    }

    return card;
  }

  /// 아이콘 + 텍스트 카드
  static Widget buildIconTextCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    return buildCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? Colors.blue, size: AppConstants.defaultIconSize),
          const SizedBox(width: AppConstants.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  /// 선택 가능한 카드
  static Widget buildSelectableCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isSelected,
    Color? selectedColor,
    Color? unselectedColor,
    VoidCallback? onTap,
  }) {
    final color = isSelected ? (selectedColor ?? Colors.blue) : (unselectedColor ?? Colors.grey);

    return buildCard(
      onTap: onTap,
      backgroundColor: isSelected ? color.withValues(alpha: 0.1) : null,
      child: Column(
        children: [
          Icon(icon, color: color, size: AppConstants.defaultIconSize * 1.5),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 공통 다이얼로그 패턴
class CommonDialogPatterns {
  CommonDialogPatterns._();

  /// 기본 다이얼로그
  static Future<T?> showStandardDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: content,
        actions:
            actions ??
            [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppTexts.cancel),
              ),
            ],
      ),
    );
  }

  /// 확인 다이얼로그
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return showStandardDialog<bool>(
      context: context,
      title: title,
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText ?? AppTexts.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText ?? AppTexts.confirm),
        ),
      ],
    );
  }

  /// 폼 다이얼로그
  static Future<T?> showFormDialog<T>({
    required BuildContext context,
    required String title,
    required Widget form,
    List<Widget>? actions,
  }) {
    return showStandardDialog<T>(
      context: context,
      title: title,
      content: SizedBox(width: double.maxFinite, child: form),
      actions: actions,
    );
  }

  /// 로딩 다이얼로그
  static Future<void> showLoadingDialog({required BuildContext context, String? message}) {
    return showStandardDialog<void>(
      context: context,
      title: '',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[const SizedBox(height: AppConstants.spacingMD), Text(message)],
        ],
      ),
      actions: [],
    );
  }
}

/// 공통 리스트 패턴
class CommonListPatterns {
  CommonListPatterns._();

  /// 기본 리스트 아이템
  static Widget buildListItem({
    required Widget leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    EdgeInsets? padding,
  }) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      contentPadding: padding,
    );
  }

  /// 아이콘 + 텍스트 리스트 아이템
  static Widget buildIconTextListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return buildListItem(
      leading: Icon(icon, color: iconColor ?? Colors.blue, size: AppConstants.defaultIconSize),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// 빈 상태 위젯
  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: AppConstants.spacingLG), action],
        ],
      ),
    );
  }

  /// 로딩 상태 위젯
  static Widget buildLoadingState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[const SizedBox(height: AppConstants.spacingMD), Text(message)],
        ],
      ),
    );
  }

  /// 에러 상태 위젯
  static Widget buildErrorState({required String message, VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppConstants.spacingLG),
            ElevatedButton(onPressed: onRetry, child: const Text(AppTexts.retry)),
          ],
        ],
      ),
    );
  }
}
