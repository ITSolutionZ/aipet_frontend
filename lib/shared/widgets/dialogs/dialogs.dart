// Dialogs
export 'app_lock_dialog.dart';

// TODO: Create individual dialog files when needed
// export 'package:aipet_frontend/shared/widgets/dialogs/confirmation_dialog.dart';
// export 'package:aipet_frontend/shared/widgets/dialogs/info_dialog.dart';
// export 'package:aipet_frontend/shared/widgets/dialogs/loading_dialog.dart';

/// 다이얼로그 유틸리티 클래스
class DialogUtils {
  DialogUtils._();

  /// 확인 다이얼로그 표시
  static Future<bool?> showConfirmation({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    // Implementation will be added when needed
    return Future.value(false);
  }

  /// 정보 다이얼로그 표시
  static Future<void> showInfo({
    required String title,
    required String message,
    String? buttonText,
  }) {
    // Implementation will be added when needed
    return Future.value();
  }

  /// 로딩 다이얼로그 표시
  static Future<void> showLoading({String? message}) {
    // Implementation will be added when needed
    return Future.value();
  }
}
