import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/entities/daily_health_record.dart';

/// 건강 상태 표시 위젯
class HealthStatusDisplayWidget extends StatelessWidget {
  final HealthStatus status;
  final double? temperature;
  final bool showTemperature;

  const HealthStatusDisplayWidget({
    super.key,
    required this.status,
    this.temperature,
    this.showTemperature = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: AppFonts.titleSmall.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showTemperature && temperature != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '体温: ${temperature!.toStringAsFixed(1)}°C',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case HealthStatus.excellent:
        return AppColors.success;
      case HealthStatus.good:
        return AppColors.pointBlue;
      case HealthStatus.fair:
        return AppColors.pointYellow;
      case HealthStatus.poor:
        return AppColors.pointOrange;
      case HealthStatus.critical:
        return AppColors.pointRed;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case HealthStatus.excellent:
        return Icons.favorite;
      case HealthStatus.good:
        return Icons.thumb_up;
      case HealthStatus.fair:
        return Icons.warning;
      case HealthStatus.poor:
        return Icons.priority_high;
      case HealthStatus.critical:
        return Icons.emergency;
    }
  }

  String _getStatusText() {
    switch (status) {
      case HealthStatus.excellent:
        return 'とても良い';
      case HealthStatus.good:
        return '良い';
      case HealthStatus.fair:
        return '普通';
      case HealthStatus.poor:
        return '注意必要';
      case HealthStatus.critical:
        return '緊急状況';
    }
  }
}
