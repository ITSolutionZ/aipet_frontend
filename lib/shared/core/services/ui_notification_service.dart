import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';

import 'logger_service.dart';

/// 통합 UI 알림 서비스
///
/// 앱 전체에서 일관된 알림 UI와 동작을 제공합니다.
/// SnackBar, Dialog, Toast 등의 알림을 중앙화하여 관리합니다.
class UINotificationService {
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// ScaffoldMessenger Key getter (main.dart에서 사용)
  static GlobalKey<ScaffoldMessengerState> get scaffoldMessengerKey =>
      _scaffoldMessengerKey;

  /// 성공 메시지 표시
  static void showSuccess(String message, {Duration? duration}) {
    LoggerService.userAction(
      'Notification.Success',
      context: {'message': message},
    );

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppFonts.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pointGreen,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        margin: const const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  /// 에러 메시지 표시
  static void showError(String message, {Duration? duration}) {
    LoggerService.userAction(
      'Notification.Error',
      context: {'message': message},
    );

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppFonts.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pointPink,
        duration: duration ?? const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        margin: const const EdgeInsets.all(AppSpacing.md),
        action: SnackBarAction(
          label: '닫기',
          textColor: Colors.white,
          onPressed: () {
            _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 경고 메시지 표시
  static void showWarning(String message, {Duration? duration}) {
    LoggerService.userAction(
      'Notification.Warning',
      context: {'message': message},
    );

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppFonts.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        margin: const const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  /// 정보 메시지 표시
  static void showInfo(String message, {Duration? duration}) {
    LoggerService.userAction(
      'Notification.Info',
      context: {'message': message},
    );

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppFonts.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pointBlue,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        margin: const const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  /// 로딩 메시지 표시
  static void showLoading(String message) {
    LoggerService.userAction(
      'Notification.Loading',
      context: {'message': message},
    );

    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppFonts.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.pointDark,
        duration: const Duration(seconds: 10), // 로딩은 길게
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        margin: const const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  /// 현재 SnackBar 숨기기
  static void hide() {
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  }

  /// 모든 SnackBar 제거
  static void clearAll() {
    _scaffoldMessengerKey.currentState?.clearSnackBars();
  }

  /// 확인 다이얼로그 표시
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    Color? confirmColor,
  }) async {
    LoggerService.userAction(
      'Notification.ConfirmDialog',
      context: {'title': title, 'message': message},
    );

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          title: Text(
            title,
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                confirmText,
                style: AppFonts.bodyMedium.copyWith(
                  color: confirmColor ?? AppColors.pointBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 단순 알림 다이얼로그 표시
  static Future<void> showAlertDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = '확인',
  }) async {
    LoggerService.userAction(
      'Notification.AlertDialog',
      context: {'title': title, 'message': message},
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          title: Text(
            title,
            style: AppFonts.titleMedium.copyWith(
              color: AppColors.pointDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: AppFonts.bodyMedium.copyWith(color: AppColors.pointDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                buttonText,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 레거시 SnackBar 코드 마이그레이션을 위한 확장
extension LegacySnackBarMigration on ScaffoldMessengerState {
  /// 기존 showSnackBar 호출을 UINotificationService로 리다이렉트
  @Deprecated('Use UINotificationService.showSuccess/showError instead')
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  showMigratedSnackBar(SnackBar snackBar) {
    // 기존 코드와의 호환성을 위해 유지하되, 로그 남기기
    LoggerService.warning(
      'Legacy SnackBar usage detected. Consider migrating to UINotificationService.',
    );
    return showSnackBar(snackBar);
  }
}
