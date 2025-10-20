import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../domain/domain.dart';

/// 건강 상태 카드 위젯
class HealthStatusCard extends StatelessWidget {
  final DailyHealthRecord healthRecord;

  const HealthStatusCard({super.key, required this.healthRecord});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.pointRed, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '健康状態',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildHealthStatusIndicator(),
          if (healthRecord.symptoms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildSymptomsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildHealthStatusIndicator() {
    final status = healthRecord.overallHealth;
    final statusData = _getHealthStatusData(status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: statusData.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: statusData.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Icon(statusData.icon, color: statusData.color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusData.text,
                  style: AppFonts.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusData.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  statusData.description,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '記録された症状',
          style: AppFonts.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: healthRecord.symptoms.map((symptom) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.pointOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Text(
                symptom,
                style: AppFonts.bodySmall.copyWith(
                  color: AppColors.pointOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  _HealthStatusData _getHealthStatusData(HealthStatus status) {
    switch (status) {
      case HealthStatus.excellent:
        return _HealthStatusData(
          text: 'とても良い',
          description: '非常に健康な状態です',
          icon: Icons.sentiment_very_satisfied,
          color: AppColors.pointGreen,
        );
      case HealthStatus.good:
        return _HealthStatusData(
          text: '良い',
          description: '健康な状態です',
          icon: Icons.sentiment_satisfied,
          color: AppColors.pointGreen,
        );
      case HealthStatus.fair:
        return _HealthStatusData(
          text: '普通',
          description: '特に問題はありません',
          icon: Icons.sentiment_neutral,
          color: AppColors.pointGreen,
        );
      case HealthStatus.poor:
        return _HealthStatusData(
          text: '悪い',
          description: '注意が必要です',
          icon: Icons.sentiment_dissatisfied,
          color: AppColors.pointOrange,
        );
      case HealthStatus.critical:
        return _HealthStatusData(
          text: '危険',
          description: 'すぐに獣医師に相談してください',
          icon: Icons.sentiment_very_dissatisfied,
          color: AppColors.pointRed,
        );
    }
  }
}

class _HealthStatusData {
  final String text;
  final String description;
  final IconData icon;
  final Color color;

  _HealthStatusData({
    required this.text,
    required this.description,
    required this.icon,
    required this.color,
  });
}
