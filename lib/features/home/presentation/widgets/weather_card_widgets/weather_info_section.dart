import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 날씨 정보 섹션 (온도, 위치, 바람, UV, 특이사항)
class WeatherInfoSection extends StatefulWidget {
  final WeatherEntity weather;

  const WeatherInfoSection({super.key, required this.weather});

  @override
  State<WeatherInfoSection> createState() => _WeatherInfoSectionState();
}

class _WeatherInfoSectionState extends State<WeatherInfoSection> {
  late WebViewController _windWebViewController;
  late WebViewController _uvWebViewController;
  bool _windLoaded = false;
  bool _uvLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeWebViews();
  }

  /// WebView 초기화
  Future<void> _initializeWebViews() async {
    await Future.wait([
      _loadSvgToWebView('wind', 'wind'),
      _loadSvgToWebView('uv', 'uv-index'),
    ]);
  }

  /// SVG를 WebView에 로드
  Future<void> _loadSvgToWebView(String type, String fileName) async {
    try {
      final svgString = await rootBundle.loadString(
        'assets/meteocons/design/fill/animation-ready/$fileName.svg',
      );

      final htmlContent =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            html, body {
              margin: 0;
              padding: 0;
              width: 100%;
              height: 100%;
              display: flex;
              align-items: center;
              justify-content: center;
              background: transparent;
            }
            svg {
              width: 100%;
              height: 100%;
            }
          </style>
        </head>
        <body>
          $svgString
        </body>
        </html>
      ''';

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..loadHtmlString(htmlContent);

      if (mounted) {
        setState(() {
          if (type == 'wind') {
            _windWebViewController = controller;
            _windLoaded = true;
          } else if (type == 'uv') {
            _uvWebViewController = controller;
            _uvLoaded = true;
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load $type SVG: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                '${widget.weather.temperature.round()}',
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 2),
              // 온도 단위
              SizedBox(
                width: 30,
                height: 30,
                child: SvgPicture.asset(
                  'assets/meteocons/design/fill/animation-ready/celsius.svg',
                ),
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
            widget.weather.location,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 바람 아이콘
  Widget _buildWindIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: _windLoaded
              ? WebViewWidget(controller: _windWebViewController)
              : const SizedBox(),
        ),
        const SizedBox(height: 2),
        Text(
          widget.weather.windSpeed.toStringAsFixed(1),
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
        SizedBox(
          width: 28,
          height: 28,
          child: _uvLoaded
              ? WebViewWidget(controller: _uvWebViewController)
              : const SizedBox(),
        ),
        const SizedBox(height: 2),
        Text(
          widget.weather.uvIndex.toStringAsFixed(1),
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
          SizedBox(
            width: 28,
            height: 28,
            child: SvgPicture.asset(particleIcon, fit: BoxFit.contain),
          ),
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
          SizedBox(
            width: 28,
            height: 28,
            child: SvgPicture.asset(
              'assets/meteocons/design/fill/animation-ready/humidity.svg',
              fit: BoxFit.contain,
              // ignore: deprecated_member_use
              color: AppColors.pointBlue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${widget.weather.humidity}%',
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
    final weatherId = widget.weather.weatherId;

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
    final weatherId = widget.weather.weatherId;

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
