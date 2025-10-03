import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 로딩 상태 위젯
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final String? subMessage;

  const LoadingStateWidget({super.key, this.message, this.subMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message ?? 'データを読み込み中です',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.blue[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 에러 상태 위젯
class ErrorStateWidget extends StatelessWidget {
  final Object error;
  final String? message;
  final String? subMessage;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.message,
    this.subMessage,
    this.onRetry,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[600]),
            const SizedBox(height: AppSpacing.md),
            Text(
              message ?? 'データの読み込みに失敗しました',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.red[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subMessage ?? 'ネットワーク接続を確認して、もう一度お試しください',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                label: 'データ再読み込みボタン',
                button: true,
                hint: 'タップしてデータを再読み込みします',
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryButtonText ?? '再試行'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
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

/// 간단한 로딩 위젯 (작은 크기)
class SimpleLoadingWidget extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const SimpleLoadingWidget({
    super.key,
    this.size = 20,
    this.strokeWidth = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
