import 'package:aipet_frontend/features/home/data/services/openweathermap_service.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 날씨 아이콘 위젯 (WebView 애니메이션)
///
/// WebView 최적화:
/// - RepaintBoundary로 불필요한 리페인트 방지
/// - 메모리 누수 방지
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
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// WebView 초기화 및 SVG 직접 로드
  Future<void> _initializeWebView() async {
    if (_disposed) return;

    final fileName = OpenWeatherMapService.getDetailedMeteoconIcon(
      widget.weatherId,
      widget.iconCode,
    );

    await _loadSvgToWebView(fileName);
  }

  /// SVG를 WebView에 로드
  Future<void> _loadSvgToWebView(String fileName) async {
    if (_disposed) return;

    try {
      final svgString = await rootBundle.loadString(
        'assets/meteocons/design/fill/animation-ready/$fileName.svg',
      );

      final htmlContent =
          '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
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
              overflow: hidden;
            }
            svg {
              width: 100%;
              height: 100%;
              max-width: 100%;
              max-height: 100%;
            }
          </style>
        </head>
        <body>
          $svgString
          <script>
            // 애니메이션 프레임 레이트 제한 (30 FPS)
            let lastFrameTime = 0;
            const frameInterval = 1000 / 30;

            if (typeof requestAnimationFrame !== 'undefined') {
              const originalRAF = requestAnimationFrame;
              requestAnimationFrame = function(callback) {
                return originalRAF((currentTime) => {
                  const elapsed = currentTime - lastFrameTime;
                  if (elapsed >= frameInterval) {
                    lastFrameTime = currentTime;
                    try {
                      callback(currentTime);
                    } catch (e) {
                      // 에러 무시
                    }
                  }
                });
              };
            }
          </script>
        </body>
        </html>
      ''';

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..enableZoom(false)
        ..setNavigationDelegate(
          NavigationDelegate(
            onWebResourceError: (error) {
              // 에러 로그 최소화
            },
          ),
        )
        ..loadHtmlString(htmlContent);

      if (mounted && !_disposed) {
        setState(() {
          _webViewController = controller;
          _iconLoaded = true;
        });
      }
    } catch (e) {
      if (mounted && !_disposed) {
        setState(() {
          _iconLoaded = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
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
      ),
    );
  }
}
