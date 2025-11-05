import 'package:flutter/material.dart';

import '../../../../../shared/widgets/layout/card.dart';

/// トークンアクションボタン
///
/// トークン交換、リフレッシュ、リセットボタンを提供
class TokenExchangeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const TokenExchangeButton({
    super.key,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: isLoading ? null : onPressed,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isLoading
            ? [Colors.grey.withAlpha(40), Colors.grey.withAlpha(20)]
            : [Colors.blue.withAlpha(80), Colors.blue.withAlpha(40)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '交換中...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Firebase → Server トークン交換',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
        ),
      ),
    );
  }
}

/// トークンリフレッシュボタン
class TokenRefreshButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TokenRefreshButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onPressed,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.cyan.withAlpha(40), Colors.cyan.withAlpha(20)],
      ),
      borderColor: Colors.cyan.shade300,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.cyan.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'トークンステータス更新',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.cyan.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// トークンリセットボタン
class TokenResetButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TokenResetButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GlassCard.dense(
      onTap: onPressed,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.grey.withAlpha(30), Colors.grey.withAlpha(15)],
      ),
      borderColor: Colors.grey.shade400,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            '再試行',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
