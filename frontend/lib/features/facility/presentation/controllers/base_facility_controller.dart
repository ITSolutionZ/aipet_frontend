import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../shared/shared.dart';
import '../../../../app/services/unified_error_handler.dart';

/// 🎯 Facility 기능 전용 BaseController
///
/// 모든 Facility 관련 컨트롤러에서 공통으로 사용하는
/// 메시지 표시, 에러 처리, 로깅 기능을 제공합니다.
abstract class BaseFacilityController {
  final WidgetRef ref;
  final BuildContext context;

  BaseFacilityController(this.ref, this.context);

  /// 성공 메시지 표시
  /// ✅ Shared SnackBarService 사용
  void showSuccessMessage(String message) {
    if (context.mounted) {
      SnackBarService.showSuccess(context, message);
    }
  }

  /// 에러 메시지 표시
  /// ✅ Shared SnackBarService 사용
  void showErrorMessage(String message) {
    if (context.mounted) {
      SnackBarService.showError(context, message);
    }
  }

  /// 정보 메시지 표시
  /// ✅ Shared SnackBarService 사용
  void showInfoMessage(String message) {
    if (context.mounted) {
      SnackBarService.showInfo(context, message);
    }
  }

  /// 경고 메시지 표시
  /// ✅ Shared SnackBarService 사용
  void showWarningMessage(String message) {
    if (context.mounted) {
      SnackBarService.showWarning(context, message);
    }
  }

  /// 통합 에러 처리
  void handleError(dynamic error, [String? context]) {
    final errorContext = context ?? 'Facility Controller';
    UnifiedErrorHandler.handleUnifiedError(
      error,
      context: {'controller': errorContext},
    );
    showErrorMessage('エラーが発生しました: ${error.toString()}');
  }

  /// 성공 처리
  void handleSuccess(String message) {
    showSuccessMessage(message);
  }

  /// 로딩 상태 표시
  /// ✅ Shared SnackBarService 사용 (info로 대체)
  void showLoading(String message) {
    if (context.mounted) {
      SnackBarService.showInfo(
        context,
        message,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
