import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/walk_error_handler.dart';

/// 위치 서비스 에러 경계 위젯
class LocationErrorBoundary extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final String? customErrorMessage;

  const LocationErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.customErrorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }

  /// 위치 에러 다이얼로그 표시
  static Future<void> showLocationErrorDialog(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    VoidCallback? onSettings,
  }) async {
    final errorMessage = WalkErrorHandler.getLocationErrorMessage(error);
    final userAction = WalkErrorHandler.getUserActionSuggestion(error);
    final severity = WalkErrorHandler.getErrorSeverity(error);

    await showDialog<void>(
      context: context,
      barrierDismissible: severity != WalkErrorSeverity.critical,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            _getErrorIcon(severity),
            color: _getErrorColor(severity),
            size: 48,
          ),
          title: Text(
            _getErrorTitle(severity),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userAction,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            if (severity != WalkErrorSeverity.critical)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
            if (onSettings != null && _shouldShowSettingsButton(error))
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onSettings();
                },
                child: const Text('設定を開く'),
              ),
            if (onRetry != null && severity != WalkErrorSeverity.critical)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('再試行'),
              ),
          ],
        );
      },
    );
  }

  /// 위치 에러 스낵바 표시
  static void showLocationErrorSnackBar(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    final errorMessage = WalkErrorHandler.getLocationErrorMessage(error);
    final severity = WalkErrorHandler.getErrorSeverity(error);

    if (severity == WalkErrorSeverity.critical) {
      // 치명적 에러는 다이얼로그로 표시
      showLocationErrorDialog(context, error, onRetry: onRetry);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(severity),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(severity),
        duration: Duration(
          seconds: severity == WalkErrorSeverity.high ? 8 : 5,
        ),
        action: onRetry != null
            ? SnackBarAction(
                label: '再試行',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// 위치 에러 인라인 위젯
  static Widget buildLocationErrorWidget(
    dynamic error, {
    VoidCallback? onRetry,
    VoidCallback? onSettings,
  }) {
    final errorMessage = WalkErrorHandler.getLocationErrorMessage(error);
    final userAction = WalkErrorHandler.getUserActionSuggestion(error);
    final severity = WalkErrorHandler.getErrorSeverity(error);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getErrorColor(severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getErrorColor(severity).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getErrorIcon(severity),
            color: _getErrorColor(severity),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _getErrorTitle(severity),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getErrorColor(severity),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            userAction,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onSettings != null && _shouldShowSettingsButton(error))
                ElevatedButton.icon(
                  onPressed: onSettings,
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('設定'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getErrorColor(severity),
                    foregroundColor: Colors.white,
                  ),
                ),
              if (onRetry != null && onSettings != null)
                const SizedBox(width: 12),
              if (onRetry != null && severity != WalkErrorSeverity.critical)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('再試行'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _getErrorIcon(WalkErrorSeverity severity) {
    switch (severity) {
      case WalkErrorSeverity.critical:
        return Icons.error;
      case WalkErrorSeverity.high:
        return Icons.warning;
      case WalkErrorSeverity.medium:
        return Icons.info;
      case WalkErrorSeverity.low:
        return Icons.info_outline;
    }
  }

  static Color _getErrorColor(WalkErrorSeverity severity) {
    switch (severity) {
      case WalkErrorSeverity.critical:
        return Colors.red;
      case WalkErrorSeverity.high:
        return Colors.orange;
      case WalkErrorSeverity.medium:
        return Colors.amber;
      case WalkErrorSeverity.low:
        return Colors.blue;
    }
  }

  static String _getErrorTitle(WalkErrorSeverity severity) {
    switch (severity) {
      case WalkErrorSeverity.critical:
        return '位置情報が利用できません';
      case WalkErrorSeverity.high:
        return '位置情報の問題';
      case WalkErrorSeverity.medium:
        return '位置情報の警告';
      case WalkErrorSeverity.low:
        return '位置情報の通知';
    }
  }

  static bool _shouldShowSettingsButton(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('permission') ||
           errorString.contains('location service');
  }
}