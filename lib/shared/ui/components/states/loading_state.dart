import 'package:aipet_frontend/shared/design/tokens/tokens.dart';
import 'package:flutter/material.dart';

/// ⏳ 로딩 상태 위젯
///
/// 다양한 로딩 상태를 표시하는 공통 UI 컴포넌트
class LoadingState extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool showMessage;
  final Widget? customIndicator;

  const LoadingState({
    super.key,
    this.message,
    this.size,
    this.color,
    this.padding,
    this.showMessage = true,
    this.customIndicator,
  });

  /// 기본 로딩 상태 팩토리
  factory LoadingState.basic({String? message, double size = 40}) {
    return LoadingState(
      message: message,
      size: size,
      padding: const EdgeInsets.all(AppSpacing.xl),
    );
  }

  /// 작은 로딩 인디케이터 팩토리
  factory LoadingState.small({String? message, Color? color}) {
    return LoadingState(
      message: message,
      size: 24,
      color: color,
      showMessage: message != null,
      padding: const EdgeInsets.all(AppSpacing.md),
    );
  }

  /// 큰 로딩 인디케이터 팩토리
  factory LoadingState.large({String? message, Color? color}) {
    return LoadingState(
      message: message,
      size: 60,
      color: color,
      padding: const EdgeInsets.all(AppSpacing.xl),
    );
  }

  /// 전체 화면 로딩 팩토리
  factory LoadingState.fullScreen({String message = '読み込み中...'}) {
    return LoadingState(
      message: message,
      size: 50,
      padding: const EdgeInsets.all(AppSpacing.xl),
    );
  }

  /// 인라인 로딩 팩토리 (리스트나 카드 내부용)
  factory LoadingState.inline({String? message, double size = 20}) {
    return LoadingState(
      message: message,
      size: size,
      showMessage: false,
      padding: const EdgeInsets.all(AppSpacing.sm),
    );
  }

  /// 커스텀 인디케이터가 있는 로딩 팩토리
  factory LoadingState.custom({
    required Widget indicator,
    String? message,
    EdgeInsetsGeometry? padding,
  }) {
    return LoadingState(
      customIndicator: indicator,
      message: message,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIndicator(),
            if (showMessage && message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    if (customIndicator != null) {
      return customIndicator!;
    }

    return SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: CircularProgressIndicator(
        strokeWidth: _getStrokeWidth(),
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.pointBrown,
        ),
      ),
    );
  }

  double _getStrokeWidth() {
    final indicatorSize = size ?? 40;
    if (indicatorSize <= 24) return 2.0;
    if (indicatorSize <= 40) return 3.0;
    return 4.0;
  }
}
