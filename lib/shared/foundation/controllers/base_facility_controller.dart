import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/unified_error_handler.dart';

/// 🎯 Facility 기능 전용 BaseController
///
/// 모든 Facility 관련 컨트롤러에서 공통으로 사용하는
/// 메시지 표시, 에러 처리, 로깅 기능을 제공합니다.
abstract class BaseFacilityController {
  final WidgetRef ref;
  final BuildContext context;

  BaseFacilityController(this.ref, this.context);

  /// 성공 메시지 표시
  void showSuccessMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 에러 메시지 표시
  void showErrorMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// 정보 메시지 표시
  void showInfoMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 경고 메시지 표시
  void showWarningMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 통합 에러 처리
  void handleError(dynamic error, [String? context]) {
    final errorContext = context ?? 'Facility Controller';
    UnifiedErrorHandler.handleUnifiedError(error, context: {'controller': errorContext});
    showErrorMessage('エラーが発生しました: ${error.toString()}');
  }

  /// 성공 처리
  void handleSuccess(String message) {
    showSuccessMessage(message);
  }

  /// 로딩 상태 표시
  void showLoading(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(message),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
