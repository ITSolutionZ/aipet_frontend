import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class ConfirmationDialogComponent extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;
  final Color? iconColor;
  final Color? confirmButtonColor;
  final Color? confirmTextColor;

  const ConfirmationDialogComponent({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = '確認',
    this.cancelText = 'キャンセル',
    this.onCancel,
    this.icon,
    this.iconColor,
    this.confirmButtonColor,
    this.confirmTextColor,
  });

  const ConfirmationDialogComponent.delete({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = '削除',
    this.cancelText = 'キャンセル',
  }) : icon = Icons.delete_outline,
       iconColor = AppColors.pointPink,
       confirmButtonColor = AppColors.pointPink,
       confirmTextColor = Colors.white;

  const ConfirmationDialogComponent.clear({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'クリア',
    this.cancelText = 'キャンセル',
  }) : icon = Icons.clear_all,
       iconColor = AppColors.pointGray,
       confirmButtonColor = AppColors.pointGray,
       confirmTextColor = Colors.white;

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = '確認',
    String cancelText = 'キャンセル',
    IconData? icon,
    Color? iconColor,
    Color? confirmButtonColor,
    Color? confirmTextColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialogComponent(
        title: title,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        confirmButtonColor: confirmButtonColor,
        confirmTextColor: confirmTextColor,
      ),
    );
  }

  static Future<bool?> showDelete({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialogComponent.delete(
        title: title,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  static Future<bool?> showClear({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialogComponent.clear(
        title: title,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor ?? AppColors.pointDark, size: 24),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              title,
              style: AppFonts.titleMedium.copyWith(
                color: AppColors.pointDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(
            cancelText,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.pointGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor ?? AppColors.pointBlue,
            foregroundColor: confirmTextColor ?? Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
          ),
          child: Text(
            confirmText,
            style: AppFonts.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
