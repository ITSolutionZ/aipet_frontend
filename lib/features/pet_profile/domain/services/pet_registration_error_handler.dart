import 'package:flutter/material.dart';

/// Pet Profile - 펫 등록 관련 에러 처리 서비스
/// 사용자 친화적인 에러 메시지 제공 및 에러 상황 처리
class PetRegistrationErrorHandler {
  /// 에러를 사용자 친화적인 메시지로 변환
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) return '予期しないエラーが発生しました';

    // 문자열 에러 메시지 처리
    if (error is String) {
      return _getMessageForStringError(error);
    }

    // Exception 타입 에러 처리
    if (error is Exception) {
      return _getMessageForException(error);
    }

    // 기타 에러
    return 'システムエラーが発生しました。しばらく待ってから再度お試しください。';
  }

  /// 문자열 에러 메시지 변환
  static String _getMessageForStringError(String error) {
    final lowerError = error.toLowerCase();

    // 네트워크 관련 에러
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return 'ネットワーク接続を確認してください';
    }

    // 서버 에러
    if (lowerError.contains('server') || lowerError.contains('500')) {
      return 'サーバーで問題が発生しました。しばらく待ってから再度お試しください';
    }

    // 권한 에러
    if (lowerError.contains('permission') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('403')) {
      return '権限がありません。設定を確認してください';
    }

    // 데이터 검증 에러
    if (lowerError.contains('validation') || lowerError.contains('invalid')) {
      return '入力内容を確認してください';
    }

    // 파일 관련 에러
    if (lowerError.contains('file') || lowerError.contains('image')) {
      return '画像ファイルの処理中にエラーが発生しました';
    }

    // 기본 메시지
    return error;
  }

  /// Exception 타입 에러 메시지 변환
  static String _getMessageForException(Exception exception) {
    final message = exception.toString();

    if (message.contains('SocketException')) {
      return 'インターネット接続を確認してください';
    }

    if (message.contains('TimeoutException')) {
      return '接続がタイムアウトしました。再度お試しください';
    }

    if (message.contains('FormatException')) {
      return 'データ形式にエラーがあります';
    }

    if (message.contains('FileSystemException')) {
      return 'ファイルの処理中にエラーが発生しました';
    }

    return 'システムエラーが発生しました';
  }

  /// 에러 스낵바 표시
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
    String? customMessage,
  }) {
    if (!context.mounted) return;

    final message = customMessage ?? getUserFriendlyMessage(error);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: '閉じる',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 성공 스낵바 표시
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// 경고 다이얼로그 표시
  static Future<bool> showWarningDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '確認',
    String cancelText = 'キャンセル',
  }) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
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

  /// 에러 다이얼로그 표시
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required dynamic error,
    String? customMessage,
    String buttonText = '確認',
  }) async {
    if (!context.mounted) return;

    final message = customMessage ?? getUserFriendlyMessage(error);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600, size: 24),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  /// 입력 검증 에러 메시지 생성
  static String getValidationMessage({
    required String fieldName,
    required String validationType,
    int? minLength,
    int? maxLength,
    String? customMessage,
  }) {
    if (customMessage != null) return customMessage;

    switch (validationType) {
      case 'required':
        return '$fieldNameを入力してください';
      case 'minLength':
        return '$fieldNameは${minLength ?? 2}文字以上で入力してください';
      case 'maxLength':
        return '$fieldNameは${maxLength ?? 20}文字以内で入力してください';
      case 'format':
        return '正しい$fieldNameの形式で入力してください';
      case 'numeric':
        return '$fieldNameは数字で入力してください';
      default:
        return '$fieldNameの入力内容を確認してください';
    }
  }

  /// 로딩 상태 에러 처리
  static void handleLoadingError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
    String? customMessage,
  }) {
    showErrorSnackBar(context, error, customMessage: customMessage);

    if (onRetry != null) {
      // 재시도 버튼이 있는 경우 별도 처리 로직
      // 예: 재시도 다이얼로그 표시
    }
  }
}
