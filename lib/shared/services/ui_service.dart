import 'package:flutter/material.dart';

import 'error_service.dart';

/// UI 관련 기능을 제공하는 서비스 (Static methods로 context 의존성 제거)
class UiService {
  UiService._();

  /// 에러 메시지를 스낵바로 표시
  static void showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 성공 메시지를 스낵바로 표시
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 경고 메시지를 스낵바로 표시
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 정보 메시지를 스낵바로 표시
  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 에러 심각도별 메시지 표시
  static void showErrorWithSeverity(
    BuildContext context,
    dynamic error,
    ErrorSeverity severity, {
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    final errorService = ErrorService();
    final message = errorService.getUserFriendlyMessage(error);

    Color backgroundColor;
    Duration duration;

    switch (severity) {
      case ErrorSeverity.low:
        backgroundColor = Colors.orange;
        duration = const Duration(seconds: 2);
        break;
      case ErrorSeverity.medium:
        backgroundColor = Colors.orange;
        duration = const Duration(seconds: 3);
        break;
      case ErrorSeverity.high:
        backgroundColor = Colors.red;
        duration = const Duration(seconds: 4);
        break;
      case ErrorSeverity.critical:
        backgroundColor = Colors.red[900]!;
        duration = const Duration(seconds: 5);
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: severity == ErrorSeverity.critical && onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// 확인 다이얼로그 표시
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// 로딩 다이얼로그 표시
  static void showLoadingDialog(BuildContext context, String message) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  /// 로딩 다이얼로그 닫기
  static void hideLoadingDialog(BuildContext context) {
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
