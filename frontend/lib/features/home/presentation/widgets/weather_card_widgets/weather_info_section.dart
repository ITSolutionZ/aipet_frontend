import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../../../../../shared/shared.dart';
import '../../../domain/domain.dart';


/// 날씨 정보 섹션 (온도, 위치, 바람, UV, 특이사항)
class WeatherInfoSection extends StatelessWidget {
  final WeatherEntity weather;

  const WeatherInfoSection({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    LoggerService.debug('🎨 WeatherInfoSection build');
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 첫 번째 줄: 온도 | 바람 | UV | 특이사항
          Row(
            children: [
              // 온도 숫자
              Text(
                '${weather.temperature.round()}',
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 2),
              // 온도 단위
              _buildSvgIcon(
                'assets/meteocons/design/fill/animation-ready/celsius.svg',
                30,
                30,
              ),
              const SizedBox(width: AppSpacing.sm),
              // 바람
              _buildWindIcon(),
              const SizedBox(width: AppSpacing.sm),
              // UV
              _buildUVIcon(),
              const SizedBox(width: AppSpacing.sm),
              // 특이사항 (파티클 or 습도)
              _buildSingleWeatherFeature(),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // 두 번째 줄: 장소명
          Text(
            weather.location,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// SVG 아이콘 빌더 (에러 핸들링 포함)
  Widget _buildSvgIcon(
    String assetPath,
    double width,
    double height, {
    Color? color,
  }) {
    try {
      return SizedBox(
        width: width,
        height: height,
        child: SvgPicture.asset(
          assetPath,
          fit: BoxFit.contain,
          // ignore: deprecated_member_use
          color: color,
        ),
      );
    } catch (e) {
      LoggerService.debug('❌ SVG 로드 실패: $assetPath - $e');
      return SizedBox(
        width: width,
        height: height,
        child: const Icon(Icons.error_outline, size: 16),
      );
    }
  }

  /// 바람 아이콘
  Widget _buildWindIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSvgIcon(
          'assets/meteocons/design/fill/animation-ready/wind.svg',
          28,
          28,
          color: AppColors.pointBlue,
        ),
        const SizedBox(height: 2),
        Text(
          weather.windSpeed.toStringAsFixed(1),
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// UV 아이콘
  Widget _buildUVIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSvgIcon(
          'assets/meteocons/design/fill/animation-ready/uv-index.svg',
          28,
          28,
          color: AppColors.pointYellow,
        ),
        const SizedBox(height: 2),
        Text(
          weather.uvIndex.toStringAsFixed(1),
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 특이사항 1개만 표시 (파티클 우선, 없으면 습도)
  Widget _buildSingleWeatherFeature() {
    final particleIcon = _getWeatherParticleIcon();

    if (particleIcon != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSvgIcon(particleIcon, 28, 28),
          const SizedBox(height: 2),
          Text(
            _getWeatherParticleLabel(),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSvgIcon(
            'assets/meteocons/design/fill/animation-ready/humidity.svg',
            28,
            28,
            color: AppColors.pointBlue,
          ),
          const SizedBox(height: 2),
          Text(
            '${weather.humidity}%',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  /// 날씨 조건에 따른 파티클 아이콘 경로 반환
  String? _getWeatherParticleIcon() {
    final weatherId = weather.weatherId;

    if (weatherId >= 200 && weatherId < 300) {
      return 'assets/meteocons/design/fill/animation-ready/lightning-bolt.svg';
    } else if (weatherId >= 300 && weatherId < 400) {
      return 'assets/meteocons/design/fill/animation-ready/raindrop.svg';
    } else if (weatherId >= 500 && weatherId < 600) {
      if (weatherId >= 502) {
        return 'assets/meteocons/design/fill/animation-ready/raindrops.svg';
      } else {
        return 'assets/meteocons/design/fill/animation-ready/raindrop.svg';
      }
    } else if (weatherId >= 600 && weatherId < 700) {
      return 'assets/meteocons/design/fill/animation-ready/snowflake.svg';
    } else if (weatherId >= 701 && weatherId < 800) {
      if (weatherId == 701 || weatherId == 741) {
        return null;
      } else if (weatherId >= 761 && weatherId <= 762) {
        return 'assets/meteocons/design/fill/animation-ready/smoke-particles.svg';
      }
    }

    return null;
  }

  /// 파티클 라벨 반환
  String _getWeatherParticleLabel() {
    final weatherId = weather.weatherId;

    if (weatherId >= 200 && weatherId < 300) {
      return '雷';
    } else if (weatherId >= 300 && weatherId < 400) {
      return '霧雨';
    } else if (weatherId >= 500 && weatherId < 600) {
      if (weatherId >= 502) {
        return '豪雨';
      } else {
        return '雨';
      }
    } else if (weatherId >= 600 && weatherId < 700) {
      return '雪';
    } else if (weatherId >= 761 && weatherId <= 762) {
      return '塵';
    }

    return '';
  }
}
