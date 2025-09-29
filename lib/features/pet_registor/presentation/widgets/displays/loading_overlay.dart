import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 로딩 오버레이 위젯
/// 전체 화면을 덮는 반투명 로딩 인디케이터
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: const const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.pointPink,
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        message!,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 인라인 로딩 인디케이터
/// 특정 영역에 표시되는 작은 로딩 스피너
class InlineLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const InlineLoadingIndicator({
    super.key,
    this.message,
    this.size = 20.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.pointPink,
            ),
          ),
        ),
        if (message != null) ...[
          const const SizedBox(width: 8),
          Text(
            message!,
            style: AppFonts.bodySmall.copyWith(
              color: AppColors.pointGray,
            ),
          ),
        ],
      ],
    );
  }
}

/// 버튼 로딩 상태 위젯
/// 버튼 내부에 로딩 스피너 표시
class ButtonLoadingState extends StatelessWidget {
  final bool isLoading;
  final String text;
  final String? loadingText;
  final VoidCallback? onPressed;
  final bool isEnabled;

  const ButtonLoadingState({
    super.key,
    required this.isLoading,
    required this.text,
    this.loadingText,
    this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (isLoading || !isEnabled) ? null : onPressed,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                if (loadingText != null) ...[
                  const const SizedBox(width: 8),
                  Text(loadingText!),
                ],
              ],
            )
          : Text(text),
    );
  }
}
