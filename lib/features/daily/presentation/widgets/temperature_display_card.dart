import 'package:aipet_frontend/features/daily/domain/entities/daily_health_record.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 체온 표시 카드 위젯
class TemperatureDisplayCard extends StatelessWidget {
  final DailyHealthRecord healthRecord;
  final String petType;

  const TemperatureDisplayCard({
    super.key,
    required this.healthRecord,
    required this.petType,
  });

  @override
  Widget build(BuildContext context) {
    final temperature = healthRecord.temperature;
    final tempRange = _getTemperatureRange(petType);
    final isNormal =
        temperature != null &&
        temperature >= tempRange.min &&
        temperature <= tempRange.max;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
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
      child: Row(
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
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: temperature != null
                ? Text(
                    '${temperature.toStringAsFixed(1)}°C',
                    style: AppFonts.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )
                : Text(
                    '未記録',
                    style: AppFonts.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          _buildHealthIcons(isNormal),
        ],
      ),
    );
  }

  Widget _buildHealthIcons(bool isNormal) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isNormal
            ? AppColors.pointGreen.withValues(alpha: 0.1)
            : AppColors.pointRed.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isNormal ? Icons.favorite : Icons.favorite_border,
        color: isNormal ? AppColors.pointGreen : AppColors.pointRed,
        size: 24,
      ),
    );
  }

  /// 동물별 정상 체온 범위 반환
  _TemperatureRange _getTemperatureRange(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return _TemperatureRange(min: 37.5, max: 39.2);
      case 'cat':
        return _TemperatureRange(min: 38.0, max: 39.2);
      case 'rabbit':
        return _TemperatureRange(min: 38.5, max: 40.0);
      case 'hamster':
        return _TemperatureRange(min: 36.5, max: 38.0);
      case 'bird':
        return _TemperatureRange(min: 40.0, max: 42.0);
      case 'turtle':
        return _TemperatureRange(min: 25.0, max: 30.0);
      default:
        return _TemperatureRange(min: 37.0, max: 39.5);
    }
  }
}

/// 체온 범위 클래스
class _TemperatureRange {
  final double min;
  final double max;

  _TemperatureRange({required this.min, required this.max});
}
