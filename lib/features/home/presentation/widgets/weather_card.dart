import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../shared/shared.dart';
import '../controllers/weather_controller.dart';

class WeatherCard extends ConsumerStatefulWidget {
  const WeatherCard({
    super.key,
    this.temp = 19,
    this.location = '東京 品川区',
    this.weatherId = 500,
  });
  
  final int temp;
  final String location;
  final int weatherId;

  @override
  ConsumerState<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends ConsumerState<WeatherCard> {
  late WeatherController _controller;
  String? _message;
  bool? _isDay;
  String? _iconName;

  @override
  void initState() {
    super.initState();
    _controller = WeatherController(ref);
    _isDay = _controller.isDayTime();
    _message = _controller.generateWeatherMessage(widget.temp);
    _iconName = _controller.getWeatherIconName(widget.weatherId, isDay: _isDay!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      '${widget.temp}',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.pointBlue,
                      ),
                    ),
                    const MeteoconsIcon(name: 'celsius', size: 48),
                    const SizedBox(width: 12),
                    const MeteoconsIcon(name: 'uv-index', size: 48),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.location,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.pointGray,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _message ?? '天気情報を読み込み中...',
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
            child: Center(child: MeteoconsIcon(name: _iconName ?? 'clear-day', size: 100)),
          ),
        ],
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
        final html = _weatherController.generateWeatherIconHtml(svgString, widget.size);

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
