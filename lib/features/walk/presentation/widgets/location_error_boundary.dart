import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

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
    // ✅ Shared 모듈 사용: 에러 메시지 생성
    final errorMessage = _getLocationErrorMessage(error);
    final userAction = _getUserActionSuggestion(error);
    final severity = _getErrorSeverity(error);

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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMessage, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pointBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.pointBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.pointBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userAction,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.pointBlue,
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
              CommonButton(
                text: 'キャンセル',
                onPressed: () => Navigator.of(context).pop(),
                type: ButtonType.secondary,
                size: ButtonSize.small,
              ),
            if (onSettings != null && _shouldShowSettingsButton(error))
              CommonButton(
                text: '設定を開く',
                onPressed: () {
                  Navigator.of(context).pop();
                  onSettings();
                },
                type: ButtonType.primary,
                size: ButtonSize.small,
              ),
            if (onRetry != null && severity != WalkErrorSeverity.critical)
              CommonButton(
                text: '再試行',
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                type: ButtonType.primary,
                size: ButtonSize.small,
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
    // ✅ Shared 모듈 사용
    final errorMessage = _getLocationErrorMessage(error);
    final severity = _getErrorSeverity(error);

    if (severity == WalkErrorSeverity.critical) {
      // 치명적 에러는 다이얼로그로 표시
      showLocationErrorDialog(context, error, onRetry: onRetry);
      return;
    }

    if (severity == WalkErrorSeverity.high) {
      SnackBarService.showError(
        context,
        errorMessage,
        duration: const Duration(seconds: 8),
        action: onRetry != null
            ? SnackBarAction(
                label: '再試行',
                textColor: AppColors.pureWhite,
                onPressed: onRetry,
              )
            : null,
      );
    } else {
      SnackBarService.showWarning(
        context,
        errorMessage,
        duration: const Duration(seconds: 5),
        action: onRetry != null
            ? SnackBarAction(
                label: '再試行',
                textColor: AppColors.pureWhite,
                onPressed: onRetry,
              )
            : null,
      );
    }
  }

  /// 위치 에러 인라인 위젯
  static Widget buildLocationErrorWidget(
    dynamic error, {
    VoidCallback? onRetry,
    VoidCallback? onSettings,
  }) {
    // ✅ Shared 모듈 사용
    final errorMessage = _getLocationErrorMessage(error);
    final userAction = _getUserActionSuggestion(error);
    final severity = _getErrorSeverity(error);

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
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  // ===================================================================
  // ✅ Walk feature 특화 에러 메시지 헬퍼 (Shared ErrorHandlingService 기반)
  // ===================================================================

  /// 위치 관련 에러 메시지 생성
  static String _getLocationErrorMessage(dynamic error) {
    if (error is LocationServiceDisabledException) {
      return '位置サービスが無効になっています。設定で有効にしてください。';
    } else if (error is PermissionDeniedException) {
      return '位置情報の権限が拒否されました。設定で権限を許可してください。';
    } else if (error.toString().contains('Location permission denied')) {
      return '位置情報の権限が必要です。設定で権限を許可してください。';
    } else if (error.toString().contains(
      'Location permission permanently denied',
    )) {
      return '位置情報の権限が永続的に拒否されています。設定アプリで権限を許可してください。';
    } else if (error.toString().contains('Location service disabled')) {
      return '位置サービスが無効になっています。設定で有効にしてください。';
    } else {
      // 기본 에러 메시지
      return '位置情報の取得に失敗しました: ${error.toString()}';
    }
  }

  /// 사용자 액션 제안 메시지 생성
  static String _getUserActionSuggestion(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission')) {
      return '設定アプリで位置情報の権限を確認してください。';
    } else if (errorString.contains('location service')) {
      return '設定で位置サービスを有効にしてください。';
    } else if (errorString.contains('network')) {
      return 'Wi-Fiまたはモバイル通信の接続を確認してください。';
    } else if (errorString.contains('battery')) {
      return 'デバイスを充電することをお勧めします。';
    } else if (errorString.contains('storage')) {
      return 'ストレージ容量を確保してください。';
    } else {
      return 'アプリを再起動するか、しばらく時間をおいてから再試行してください。';
    }
  }

  /// 에러 심각도 판별
  static WalkErrorSeverity _getErrorSeverity(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permanently denied') ||
        errorString.contains('location service disabled')) {
      return WalkErrorSeverity.critical;
    } else if (errorString.contains('permission denied') ||
        errorString.contains('network') ||
        errorString.contains('api_key')) {
      return WalkErrorSeverity.high;
    } else if (errorString.contains('timeout') ||
        errorString.contains('storage') ||
        errorString.contains('battery')) {
      return WalkErrorSeverity.medium;
    } else {
      return WalkErrorSeverity.low;
    }
  }
}

/// 에러 심각도 레벨 (Walk feature 전용)
enum WalkErrorSeverity {
  low, // 낮음: 일반적인 에러, 재시도 가능
  medium, // 중간: 사용자 개입 필요할 수 있음
  high, // 높음: 기능 제한됨, 사용자 액션 필요
  critical, // 치명적: 핵심 기능 불가, 즉시 해결 필요
}
