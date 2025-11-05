import 'package:aipet_frontend/shared/widgets/layout/card.dart';
import 'package:flutter/material.dart';

/// トークンステータスカード
///
/// トークンの有効期限と状態を表示
class TokenStatusCard extends StatelessWidget {
  final DateTime? tokenExpiry;
  final bool isExpired;
  final bool isExpiringSoon;

  const TokenStatusCard({
    super.key,
    required this.tokenExpiry,
    required this.isExpired,
    required this.isExpiringSoon,
  });

  @override
  Widget build(BuildContext context) {
    final status = _getTokenStatus();

    return GlassCard(
      gradient: status.gradient,
      child: Row(
        children: [
          Icon(status.icon, size: 32, color: status.iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _TokenStatus _getTokenStatus() {
    if (tokenExpiry == null) {
      return _TokenStatus(
        icon: Icons.help_outline,
        title: 'トークンなし',
        subtitle: 'まだトークンが保存されていません',
        iconColor: Colors.grey.shade600,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.withAlpha(40), Colors.grey.withAlpha(20)],
        ),
      );
    } else if (isExpired) {
      return _TokenStatus(
        icon: Icons.timer_off,
        title: 'トークン期限切れ',
        subtitle: 'トークンが期限切れです。再度交換してください',
        iconColor: Colors.red.shade600,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.withAlpha(60), Colors.red.withAlpha(30)],
        ),
      );
    } else if (isExpiringSoon) {
      return _TokenStatus(
        icon: Icons.warning,
        title: 'トークン期限間近',
        subtitle: '5分以内にトークンが期限切れになります',
        iconColor: Colors.orange.shade600,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.withAlpha(60), Colors.orange.withAlpha(30)],
        ),
      );
    } else {
      return _TokenStatus(
        icon: Icons.check_circle,
        title: 'トークン有効',
        subtitle: '有効期限: ${_formatExpiry(tokenExpiry!)}',
        iconColor: Colors.green.shade600,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.withAlpha(60), Colors.green.withAlpha(30)],
        ),
      );
    }
  }

  String _formatExpiry(DateTime expiry) {
    final now = DateTime.now();
    final difference = expiry.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}日後';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間後';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分後';
    } else {
      return 'まもなく期限切れ';
    }
  }
}

class _TokenStatus {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Gradient gradient;

  _TokenStatus({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.gradient,
  });
}
