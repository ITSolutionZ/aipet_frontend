import 'package:flutter/material.dart';


import '../../../../shared/shared.dart';
import '../../domain/domain.dart';
import 'weather_card_widgets/weather_card_widgets.dart';


/// 날씨 정보 카드 위젯
class WeatherCardWidget extends StatelessWidget {
  final WeatherEntity weather;

  const WeatherCardWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // 디버그: 날씨 데이터 확인
    LoggerService.debug('🌤️ WeatherCardWidget build:');
    LoggerService.debug('  - location: ${weather.location}');
    LoggerService.debug('  - temperature: ${weather.temperature}');
    LoggerService.debug('  - description: ${weather.description}');

    // 위험 상황 체크 및 모달 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (weather.isDangerous) {
        WeatherDangerModal.show(context, weather);
      }
    });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(
          color: AppColors.pointBrown.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날씨 아이콘과 정보 섹션
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeatherIconWidget(
                weatherId: weather.weatherId,
                iconCode: weather.iconCode,
              ),
              const SizedBox(width: AppSpacing.sm),
              WeatherInfoSection(weather: weather),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 위험도 및 어드바이스
          WeatherRiskIndicator(weather: weather),
        ],
      ),
    );
  }
}
