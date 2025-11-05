import 'package:aipet_frontend/shared/widgets/layout/card.dart';
import 'package:flutter/material.dart';

import '../../../application/auth_controller.dart';

/// トークン交換ステータスカード
///
/// トークン交換処理の進行状況を表示
class TokenExchangeStatusCard extends StatelessWidget {
  final TokenExchangeState state;

  const TokenExchangeStatusCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final status = _getExchangeStatus();

    return GlassCard.panel(
      gradient: status.gradient,
      child: Column(
        children: [
          if (state.isLoading)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(status.iconColor),
            )
          else
            Icon(status.icon, size: 48, color: status.iconColor),
          const SizedBox(height: 12),
          Text(
            status.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (status.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              status.subtitle!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  _ExchangeStatus _getExchangeStatus() {
    if (state.isLoading) {
      return _ExchangeStatus(
        icon: Icons.sync,
        title: 'トークン交換中...',
        subtitle: 'サーバーと通信中です',
        iconColor: Colors.orange.shade600,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.withAlpha(60), Colors.orange.withAlpha(30)],
        ),
      );
    } else if (state.isSuccess) {
      return _ExchangeStatus(
        icon: Icons.check_circle,
        title: 'トークン保存完了',
        subtitle: 'サーバーJWTが安全に保存されました',
        iconColor: Colors.green.shade600,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.withAlpha(60), Colors.green.withAlpha(30)],
        ),
      );
    } else if (state.errorMessage != null) {
      return _ExchangeStatus(
        icon: Icons.error,
        title: '失敗',
        subtitle: state.errorMessage,
        iconColor: Colors.red.shade600,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.withAlpha(60), Colors.red.withAlpha(30)],
        ),
      );
    } else {
      return _ExchangeStatus(
        icon: Icons.info,
        title: '準備完了',
        subtitle: 'Firebaseログイン後ボタンを押してください',
        iconColor: Colors.blue.shade600,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.withAlpha(40), Colors.blue.withAlpha(20)],
        ),
      );
    }
  }
}

class _ExchangeStatus {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final Gradient gradient;

  _ExchangeStatus({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.iconColor,
    required this.gradient,
  });
}
