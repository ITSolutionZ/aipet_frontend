import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../shared/shared.dart';
import '../../data/models/weather_model.dart';
import '../controllers/weather_controller.dart';

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
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _controller.getCurrentWeather();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess && result.data != null) {
          _weatherData = result.data as WeatherData;
          debugPrint(
            '🌡️ 날씨 데이터 받음: ${_weatherData!.location}, ${_weatherData!.temperature}°C',
          );

          // 현재 시간 다시 확인 (API 호출 시점의 정확한 시간 사용)
          _isDay = _controller.isDayTime();
          _iconName = _controller.getWeatherIconName(
            _weatherData!.weatherId,
            isDay: _isDay!,
          );

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

  /// UV 지수에 따른 MeteoconsIcon 이름 반환 (1~11 정확한 매칭)
  String _getUvIndexIcon(double uvIndex) {
    final uvLevel = uvIndex.round().clamp(1, 11);
    return 'uv-index-$uvLevel';
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
    return 'wind-beaufort-$beaufortScale';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _loadWeatherData,
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
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.pointGray,
                    ),
                  ),
                ],
              ),
            ),

            // 오른쪽: 날씨 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.pointOffWhite.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : MeteoconsIcon(name: _iconName ?? 'clear-day', size: 100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MeteoconsIcon extends ConsumerStatefulWidget {
  const MeteoconsIcon({super.key, required this.name, this.size = 32});

  final String name;
  final double size;

  @override
  ConsumerState<MeteoconsIcon> createState() => _MeteoconsIconState();
}

class _MeteoconsIconState extends ConsumerState<MeteoconsIcon> {
  late final WebViewController controller;
  late final WeatherController _weatherController;
  String? svgContent;

  @override
  void initState() {
    super.initState();
    _weatherController = WeatherController(ref);
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent);
    _loadSvgAndCreateHtml();
  }

  Future<void> _loadSvgAndCreateHtml() async {
    try {
      final result = await _weatherController.loadWeatherIcon(widget.name);

      if (result.isSuccess) {
        final svgString = result.data as String;
        final html = _weatherController.generateWeatherIconHtml(
          svgString,
          widget.size,
        );

        await controller.loadHtmlString(html, baseUrl: 'about:blank');
        if (mounted) {
          setState(() {
            svgContent = svgString;
          });
        }
      } else {
        _loadFallbackHtml();
      }
    } catch (e) {
      debugPrint('Failed to load SVG: $e');
      _loadFallbackHtml();
    }
  }

  void _loadFallbackHtml() {
    final fallbackHtml = _weatherController.generateFallbackHtml(widget.name);
    controller.loadHtmlString(fallbackHtml, baseUrl: 'about:blank');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: WebViewWidget(controller: controller),
    );
  }
}
