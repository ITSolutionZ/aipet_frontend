import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
/// 향상된 에러 메시지 위젯
///
/// 다양한 에러 타입에 따른 시각적 피드백을 제공합니다.
class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    super.key,
    required this.message,
    this.type = ErrorType.error,
    this.onDismiss,
    this.showIcon = true,
  });

  /// 에러 메시지
  final String message;

  /// 에러 타입 (시각적 스타일 결정)
  final ErrorType type;

  /// 닫기 버튼 클릭 시 콜백
  final VoidCallback? onDismiss;

  /// 아이콘 표시 여부
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final theme = _getThemeByType(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: theme.backgroundColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(theme.icon, color: theme.backgroundColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              message,
              style: AppFonts.bodySmall.copyWith(
                color: theme.backgroundColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: theme.backgroundColor, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  /// 에러 타입에 따른 테마 반환
  _ErrorTheme _getThemeByType(ErrorType type) {
    switch (type) {
      case ErrorType.error:
        return const _ErrorTheme(
          backgroundColor: Colors.red,
          icon: Icons.error_outline,
        );
      case ErrorType.warning:
        return const _ErrorTheme(
          backgroundColor: Colors.orange,
          icon: Icons.warning_amber_outlined,
        );
      case ErrorType.info:
        return const _ErrorTheme(
          backgroundColor: Colors.blue,
          icon: Icons.info_outline,
        );
      case ErrorType.success:
        return const _ErrorTheme(
          backgroundColor: Colors.green,
          icon: Icons.check_circle_outline,
        );
    }
  }
}

/// 에러 타입 열거형
enum ErrorType { error, warning, info, success }

/// 에러 테마 클래스
class _ErrorTheme {
  const _ErrorTheme({required this.backgroundColor, required this.icon});

  final Color backgroundColor;
  final IconData icon;
}

/// 간단한 에러 메시지 (기존 호환성 유지)
class SimpleErrorMessage extends StatelessWidget {
  const SimpleErrorMessage({super.key, required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return ErrorMessage(
      message: message,
      type: ErrorType.error,
      onDismiss: onDismiss,
    );
  }
}

/// 성공 메시지
class SuccessMessage extends StatelessWidget {
  const SuccessMessage({super.key, required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return ErrorMessage(
      message: message,
      type: ErrorType.success,
      onDismiss: onDismiss,
    );
  }
}

/// 경고 메시지
class WarningMessage extends StatelessWidget {
  const WarningMessage({super.key, required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return ErrorMessage(
      message: message,
      type: ErrorType.warning,
      onDismiss: onDismiss,
    );
  }
}

/// 정보 메시지
class InfoMessage extends StatelessWidget {
  const InfoMessage({super.key, required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return ErrorMessage(
      message: message,
      type: ErrorType.info,
      onDismiss: onDismiss,
    );
  }
}
