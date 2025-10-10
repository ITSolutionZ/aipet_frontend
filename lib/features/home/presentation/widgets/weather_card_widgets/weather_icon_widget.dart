import 'package:aipet_frontend/features/home/data/services/openweathermap_service.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 날씨 아이콘 위젯 (WebView 애니메이션)
class WeatherIconWidget extends StatefulWidget {
  final int weatherId;
  final String iconCode;

  const WeatherIconWidget({
    super.key,
    required this.weatherId,
    required this.iconCode,
  });

  @override
  State<WeatherIconWidget> createState() => _WeatherIconWidgetState();
}

class _WeatherIconWidgetState extends State<WeatherIconWidget> {
  late WebViewController _webViewController;
  bool _iconLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  /// WebView 초기화 및 SVG 직접 로드
  Future<void> _initializeWebView() async {
    final fileName = OpenWeatherMapService.getDetailedMeteoconIcon(
      widget.weatherId,
      widget.iconCode,
    );

    await _loadSvgToWebView(fileName);
  }

  /// SVG를 WebView에 로드
  Future<void> _loadSvgToWebView(String fileName) async {
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
          _webViewController = controller;
          _iconLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load weather SVG: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _iconLoaded
            ? WebViewWidget(controller: _webViewController)
            : Container(
                color: Colors.grey[100],
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.pointBrown,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
