import 'package:flutter/material.dart';

import '../../design/design.dart';
import '../../utils/loading_state.dart';

/// 표준화된 로딩 위젯
class LoadingWidget extends StatelessWidget {
  final LoadingState loadingState;
  final Widget? child;
  final Widget? loadingChild;
  final Widget? errorChild;
  final VoidCallback? onRetry;
  final bool showLoadingOverlay;

  const LoadingWidget({
    super.key,
    required this.loadingState,
    this.child,
    this.loadingChild,
    this.errorChild,
    this.onRetry,
    this.showLoadingOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    // 에러 상태
    if (loadingState.hasError) {
      return errorChild ?? _buildErrorWidget();
    }

    // 로딩 상태
    if (loadingState.isLoading) {
      if (showLoadingOverlay && child != null) {
        return Stack(children: [child!, _buildLoadingOverlay()]);
      }
      return loadingChild ?? _buildLoadingWidget();
    }

    // 성공 상태
    return child ?? const SizedBox.shrink();
  }

  /// 기본 로딩 위젯
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pointBrown),
          ),
          if (loadingState.loadingMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              loadingState.loadingMessage!,
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// 로딩 오버레이
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.pointBrown),
              ),
              if (loadingState.loadingMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  loadingState.loadingMessage!,
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
    );
  }

  /// 기본 에러 위젯
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.pointPink,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '오류가 발생했습니다',
              style: AppTextStyles.h2.copyWith(color: AppColors.pointDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              loadingState.error ?? '알 수 없는 오류가 발생했습니다.',
              style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pointBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: Text(
                  '다시 시도',
                  style: AppFonts.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 로딩 상태를 감시하는 위젯
class LoadingStateBuilder extends StatelessWidget {
  final LoadingState loadingState;
  final Widget Function(BuildContext context, LoadingState state) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final VoidCallback? onRetry;

  const LoadingStateBuilder({
    super.key,
    required this.loadingState,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      loadingState: loadingState,
      loadingChild: loadingWidget,
      errorChild: errorWidget,
      onRetry: onRetry,
      child: builder(context, loadingState),
    );
  }
}

/// 간단한 로딩 인디케이터
class SimpleLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const SimpleLoadingIndicator({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.pointBrown,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              message!,
              style: AppFonts.bodySmall.copyWith(color: AppColors.pointGray),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// 버튼 로딩 인디케이터
class ButtonLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const ButtonLoadingIndicator({
    super.key,
    this.message,
    this.size = 16.0,
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
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.white),
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            message!,
            style: AppFonts.bodySmall.copyWith(color: color ?? Colors.white),
          ),
        ],
      ],
    );
  }
}
