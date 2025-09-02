import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/shared.dart';
import '../../data/models/weather_model.dart';
import '../controllers/weather_controller.dart';
import 'meteocons_icon.dart';

class WeatherCard extends ConsumerStatefulWidget {
  const WeatherCard({super.key});

  @override
  ConsumerState<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends ConsumerState<WeatherCard> {
  late WeatherController _controller;
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _walkingAdvice;
  bool? _isDay;
  String? _iconName;

  @override
  void initState() {
    super.initState();
    _controller = WeatherController(ref);
    _isDay = _controller.isDayTime();
    
    // 캐시된 데이터가 있는지 먼저 확인
    _checkCachedData();
    
    // 캐시된 데이터가 없거나 유효하지 않은 경우에만 API 호출
    if (_weatherData == null) {
      _loadWeatherData(forceRefresh: false);
    }
  }

  /// 캐시된 데이터 확인
  void _checkCachedData() {
    final cachedData = _controller.cachedWeatherData;
    if (cachedData != null) {
      debugPrint('🔄 컨트롤러에서 캐시된 날씨 데이터 사용');
      setState(() {
        _weatherData = cachedData;
        _isLoading = false;
        _isDay = _controller.isDayTime();
        _iconName = _getWeatherIconName(_weatherData!.weatherId, _isDay!);
      });
    }
  }

  Future<void> _loadWeatherData({bool forceRefresh = false, bool userTriggered = false}) async {
    // 강제 리프레시가 아니고 이미 데이터가 있으면 API 호출하지 않음
    if (!forceRefresh && _weatherData != null && !_isLoading) {
      debugPrint('🔄 캐시된 날씨 데이터 사용 (API 호출 생략)');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _controller.getCurrentWeather(userTriggered: userTriggered);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess && result.data != null) {
          _weatherData = result.data as WeatherData;
          debugPrint(
            '🌡️ 날씨 데이터 받음: ${_weatherData!.location}, ${_weatherData!.temperature}°C, UV: ${_weatherData!.uvIndex}, Wind: ${_weatherData!.windSpeed}m/s',
          );

          // 현재 시간 다시 확인 (API 호출 시점의 정확한 시간 사용)
          _isDay = _controller.isDayTime();
          _iconName = _getWeatherIconName(_weatherData!.weatherId, _isDay!);

          // 산책 조언 생성
          _generateWalkingAdvice();
        } else {
          debugPrint('❌ 날씨 데이터 로드 실패: ${result.message}');
          _errorMessage = result.message;
          _weatherData = null;
          _walkingAdvice = null;
        }
      });
    }
  }

  /// 산책 조언 생성
  Future<void> _generateWalkingAdvice() async {
    // 이미 조언이 있으면 생성하지 않음
    if (_walkingAdvice != null) {
      debugPrint('🔄 기존 산책 조언 사용 (생성 생략)');
      return;
    }

    try {
      final adviceResult = await _controller.generateWalkingAdvice();
      if (mounted && adviceResult.isSuccess) {
        setState(() {
          _walkingAdvice = adviceResult.data as String?;
        });
      }
    } catch (e) {
      debugPrint('散歩アドバイス生成失敗: $e');
      // 폴백 조언 사용
      if (mounted) {
        setState(() {
          _walkingAdvice = '今日も散歩を楽しもう';
        });
      }
    }
  }

  /// 날씨 아이콘 이름 가져오기 (실제 assets 파일명과 매핑)
  String _getWeatherIconName(int weatherId, bool isDay) {
    // 날씨 ID 기반 아이콘 매핑
    if (weatherId >= 200 && weatherId < 300) {
      return 'thunderstorm';
    } else if (weatherId >= 300 && weatherId < 600) {
      return 'rain'; // 실제로는 drizzle.svg, rain.svg 등이 있음
    } else if (weatherId >= 600 && weatherId < 700) {
      return 'snow';
    } else if (weatherId >= 700 && weatherId < 800) {
      return isDay ? 'fog-day' : 'fog-night';
    } else if (weatherId == 800) {
      return isDay ? 'clear-day' : 'clear-night';
    } else if (weatherId >= 801 && weatherId < 900) {
      return isDay ? 'partly-cloudy-day' : 'partly-cloudy-night';
    } else {
      return 'cloudy'; // not-available 대신 cloudy 사용
    }
  }

  /// UV 지수에 따른 MeteoconsIcon 이름 반환 (0~11 정확한 매칭)
  String _getUvIndexIcon(double uvIndex) {
    final uvLevel = uvIndex.round().clamp(0, 11);
    debugPrint('☀️ UV Index: $uvIndex -> uv-index-$uvLevel');
    return uvLevel == 0 ? 'uv-index' : 'uv-index-$uvLevel';
  }

  /// 풍속(m/s)을 Beaufort 스케일로 변환 (0-12)
  int _getBeaufortScale(double windSpeedMs) {
    if (windSpeedMs < 0.3) return 0; // 고요함
    if (windSpeedMs < 1.6) return 1; // 실바람
    if (windSpeedMs < 3.4) return 2; // 남실바람
    if (windSpeedMs < 5.5) return 3; // 산들바람
    if (windSpeedMs < 8.0) return 4; // 건들바람
    if (windSpeedMs < 10.8) return 5; // 흔들바람
    if (windSpeedMs < 13.9) return 6; // 된바람
    if (windSpeedMs < 17.2) return 7; // 센바람
    if (windSpeedMs < 20.8) return 8; // 큰바람
    if (windSpeedMs < 24.5) return 9; // 큰센바람
    if (windSpeedMs < 28.5) return 10; // 노대바람
    if (windSpeedMs < 32.7) return 11; // 왕바람
    return 12; // 태풍
  }

  /// Beaufort 스케일에 따른 wind 아이콘 이름 반환
  String _getWindIcon(double windSpeedMs) {
    final beaufortScale = _getBeaufortScale(windSpeedMs);
    debugPrint(
      '💨 Wind Speed: ${windSpeedMs}m/s -> Beaufort Scale: $beaufortScale -> wind-beaufort-$beaufortScale',
    );
    return 'wind-beaufort-$beaufortScale';
  }

  @override
  Widget build(BuildContext context) {
    // 아이콘 이름 디버그 로그
    if (_weatherData != null && !_isLoading) {
      final uvIconName = _getUvIndexIcon(_weatherData!.uvIndex);
      final windIconName = _getWindIcon(_weatherData!.windSpeed);
      debugPrint('🎯 Weather Card 아이콘 이름:');
      debugPrint('  UV: ${_weatherData!.uvIndex} -> $uvIconName');
      debugPrint('  Wind: ${_weatherData!.windSpeed}m/s -> $windIconName');
    }

    return GestureDetector(
      onTap: _isLoading ? null : () => _loadWeatherData(userTriggered: true), // 사용자 탭으로 요청
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.pointBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          children: [
            // 왼쪽: 온도와 위치 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _isLoading
                            ? '--'
                            : _weatherData != null
                            ? '${_weatherData!.temperature.round()}'
                            : '--',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.pointBlue,
                        ),
                      ),
                      const MeteoconsIcon(name: 'celsius', size: 36),
                      const SizedBox(width: 6),
                      // UV 지수 표시 (아이콘만)
                      MeteoconsIcon(
                        name: _isLoading || _weatherData == null
                            ? 'uv-index'
                            : _getUvIndexIcon(_weatherData!.uvIndex),
                        size: 36,
                      ),
                      const SizedBox(width: 6),
                      // 풍속 표시 (Beaufort 스케일 아이콘)
                      MeteoconsIcon(
                        name: _isLoading || _weatherData == null
                            ? 'wind-beaufort-0'
                            : _getWindIcon(_weatherData!.windSpeed),
                        size: 36,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _isLoading
                        ? '読み込み中...'
                        : _weatherData?.location ?? '東京都品川区',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _isLoading
                        ? '天気情報を読み込み中...'
                        : _errorMessage != null
                        ? '天気情報を取得できません'
                        : _walkingAdvice ?? '散歩情報を生成中...',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.pointGray,
                      fontSize: 13,
                    ),
                    softWrap: true,
                  ),
                ],
              ),
            ),

            // 오른쪽: 날씨 아이콘
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.pointOffWhite.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(45),
              ),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : MeteoconsIcon(name: _iconName ?? 'clear-day', size: 70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MeteoconsIcon은 별도 파일로 분리됨
