import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 체온 표시 카드 위젯
class TemperatureDisplayCard extends StatelessWidget {
  final DailyHealthRecord healthRecord;

  const TemperatureDisplayCard({super.key, required this.healthRecord});

  @override
  Widget build(BuildContext context) {
    final temperature = healthRecord.temperature;
    final isNormal =
        temperature != null && temperature >= 37.0 && temperature <= 39.5;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              const Icon(Icons.thermostat, color: AppColors.pointRed, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '体温',
                style: AppFonts.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _buildStatusIndicator(isNormal),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (temperature != null) ...[
                      Text(
                        '${temperature.toStringAsFixed(1)}°C',
                        style: AppFonts.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _getTemperatureStatus(temperature),
                        style: AppFonts.bodyMedium.copyWith(
                          color: _getTemperatureColor(temperature),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '未記録',
                        style: AppFonts.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '体温を記録してください',
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildHealthIcons(isNormal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isNormal) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isNormal
            ? AppColors.pointGreen.withOpacity(0.1)
            : AppColors.pointRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        isNormal ? '正常' : '要注意',
        style: AppFonts.bodySmall.copyWith(
          color: isNormal ? AppColors.pointGreen : AppColors.pointRed,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHealthIcons(bool isNormal) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNormal
                    ? AppColors.pointGreen.withOpacity(0.1)
                    : AppColors.pointRed.withOpacity(0.1),
              ),
              child: Icon(
                Icons.sentiment_satisfied,
                color: isNormal ? AppColors.pointGreen : AppColors.pointRed,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNormal
                    ? AppColors.pointGreen.withOpacity(0.1)
                    : AppColors.pointRed.withOpacity(0.1),
              ),
              child: Icon(
                Icons.pets,
                color: isNormal ? AppColors.pointGreen : AppColors.pointRed,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNormal
                    ? AppColors.pointRed
                    : AppColors.pointRed.withOpacity(0.3),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getTemperatureStatus(double temperature) {
    if (temperature < 37.0) {
      return '低体温';
    } else if (temperature <= 39.5) {
      return '正常';
    } else {
      return '発熱';
    }
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 37.0) {
      return AppColors.pointBlue;
    } else if (temperature <= 39.5) {
      return AppColors.pointGreen;
    } else {
      return AppColors.pointRed;
    }
  }
}
