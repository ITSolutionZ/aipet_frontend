import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:flutter/material.dart';

class HealthStatusCard extends StatelessWidget {
  final DailyHealthRecord record;

  const HealthStatusCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final status = record.overallHealth;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case HealthStatus.excellent:
        statusColor = Colors.green[600]!;
        statusIcon = Icons.sentiment_very_satisfied;
        break;
      case HealthStatus.good:
        statusColor = Colors.green[500]!;
        statusIcon = Icons.sentiment_satisfied;
        break;
      case HealthStatus.fair:
        statusColor = Colors.orange[500]!;
        statusIcon = Icons.sentiment_neutral;
        break;
      case HealthStatus.poor:
        statusColor = Colors.orange[600]!;
        statusIcon = Icons.sentiment_dissatisfied;
        break;
      case HealthStatus.critical:
        statusColor = Colors.red[600]!;
        statusIcon = Icons.sentiment_very_dissatisfied;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: statusColor, size: 24),
              const SizedBox(width: 8),
              Text(
                '全体的な健康状態',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusDescription(status),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '追加メモ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.notes!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusDescription(HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
        return '非常に健康な状態です';
      case HealthStatus.good:
        return '健康な状態です';
      case HealthStatus.fair:
        return '普段より少し良くないです';
      case HealthStatus.poor:
        return 'コンディションが良くないです';
      case HealthStatus.critical:
        return 'すぐに病院受診が必要です';
    }
  }
}
