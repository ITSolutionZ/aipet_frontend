import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';

/// 전역 SnackBar 관리 서비스
///
/// 앱 전체에서 일관된 SnackBar UI/UX를 제공하며,
/// 80+개의 중복된 ScaffoldMessenger 호출을 통합합니다.
class SnackBarService {
  static const Duration _defaultDuration = Duration(seconds: 4);
  static const Duration _shortDuration = Duration(seconds: 2);
  static const Duration _longDuration = Duration(seconds: 6);

  /// 성공 메시지 표시
  ///
  /// 녹색 배경으로 성공적인 작업 완료를 알립니다.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.pointGreen,
      icon: Icons.check_circle,
      duration: duration ?? _defaultDuration,
      action: action,
    );
  }

  /// 오류 메시지 표시
  ///
  /// 빨간색 배경으로 오류 상황을 알립니다.
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.pointPink,
      icon: Icons.error,
      duration: duration ?? _longDuration,
      action: action,
    );
  }

  /// 정보 메시지 표시
  ///
  /// 파란색 배경으로 일반적인 정보를 알립니다.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.pointBlue,
      icon: Icons.info,
      duration: duration ?? _defaultDuration,
      action: action,
    );
  }

  /// 경고 메시지 표시
  ///
  /// 주황색 배경으로 주의사항을 알립니다.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.pointBrown,
      icon: Icons.warning,
      duration: duration ?? _defaultDuration,
      action: action,
    );
  }

  /// 로딩 완료 메시지 표시
  ///
  /// 짧은 시간 동안 간단한 완료 메시지를 표시합니다.
  static void showQuick(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    IconData? icon,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: backgroundColor ?? AppColors.pointDark,
      icon: icon ?? Icons.done,
      duration: _shortDuration,
    );
  }

  /// 사용자 정의 SnackBar 표시
  ///
  /// 완전히 커스터마이징된 스낵바를 표시합니다.
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Color? textColor,
    Duration? duration,
    SnackBarAction? action,
    SnackBarBehavior? behavior,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      textColor: textColor,
      duration: duration ?? _defaultDuration,
      action: action,
      behavior: behavior,
    );
  }

  /// 내부 SnackBar 표시 로직
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Color? textColor,
    Duration? duration,
    SnackBarAction? action,
    SnackBarBehavior? behavior,
  }) {
    // 기존 SnackBar가 있다면 제거
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor ?? AppColors.pointOffWhite, size: 20),
            const const const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              message,
              style: AppFonts.bodyMedium.copyWith(
                color: textColor ?? AppColors.pointOffWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration ?? _defaultDuration,
      behavior: behavior ?? SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      margin: const const const EdgeInsets.all(AppSpacing.md),
      action: action,
      elevation: 6,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 네트워크 오류 전용 메시지
  ///
  /// 네트워크 관련 오류에 대한 표준 메시지와 재시도 옵션을 제공합니다.
  static void showNetworkError(
    BuildContext context, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final message = customMessage ?? '네트워크 연결을 확인해주세요';

    _showSnackBar(
      context,
      message: message,
      backgroundColor: AppColors.pointPink,
      icon: Icons.wifi_off,
      duration: _longDuration,
      action: onRetry != null
          ? SnackBarAction(
              label: '재시도',
              textColor: AppColors.pointOffWhite,
              onPressed: onRetry,
            )
          : null,
    );
  }

  /// 저장 완료 메시지
  ///
  /// 데이터 저장 성공 시 사용하는 표준 메시지입니다.
  static void showSaved(BuildContext context, {String? itemName}) {
    final message = itemName != null ? '$itemName이(가) 저장되었습니다' : '저장되었습니다';
    showSuccess(context, message, duration: _shortDuration);
  }

  /// 삭제 완료 메시지
  ///
  /// 데이터 삭제 성공 시 사용하는 표준 메시지입니다.
  static void showDeleted(BuildContext context, {String? itemName}) {
    final message = itemName != null ? '$itemName이(가) 삭제되었습니다' : '삭제되었습니다';
    showSuccess(context, message, duration: _shortDuration);
  }

  /// 업데이트 완료 메시지
  ///
  /// 데이터 업데이트 성공 시 사용하는 표준 메시지입니다.
  static void showUpdated(BuildContext context, {String? itemName}) {
    final message = itemName != null ? '$itemName이(가) 업데이트되었습니다' : '업데이트되었습니다';
    showSuccess(context, message, duration: _shortDuration);
  }

  /// 권한 요청 메시지
  ///
  /// 권한이 필요한 기능 사용 시 표시하는 메시지입니다.
  static void showPermissionRequired(
    BuildContext context,
    String permission, {
    VoidCallback? onSettings,
  }) {
    _showSnackBar(
      context,
      message: '$permission 권한이 필요합니다',
      backgroundColor: AppColors.pointBrown,
      icon: Icons.lock,
      duration: _longDuration,
      action: onSettings != null
          ? SnackBarAction(
              label: '설정',
              textColor: AppColors.pointOffWhite,
              onPressed: onSettings,
            )
          : null,
    );
  }

  /// 개발자용 디버그 메시지
  ///
  /// 디버그 모드에서만 표시되는 개발자용 메시지입니다.
  static void showDebug(BuildContext context, String message) {
    assert(() {
      _showSnackBar(
        context,
        message: '[DEBUG] $message',
        backgroundColor: Colors.purple,
        icon: Icons.bug_report,
        duration: _shortDuration,
      );
      return true;
    }());
  }
}
