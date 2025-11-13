import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:webview_flutter/webview_flutter.dart';  // iOS 시뮬레이터 호환성 문제로 임시 비활성화

/// 날씨 아이콘 WebView 캐싱 서비스
///
/// 앱 시작시 미리 날씨 아이콘들을 로드하여 캐싱하고,
/// 필요할 때 즉시 사용할 수 있도록 하는 서비스
class WeatherIconCacheService {
  static final WeatherIconCacheService _instance =
      WeatherIconCacheService._internal();
  factory WeatherIconCacheService() => _instance;
  WeatherIconCacheService._internal();

  // 캐시된 WebView 컨트롤러들 (임시 비활성화)
  final Map<String, dynamic> _cachedControllers = {};
  bool _isInitialized = false;

  /// 캐시 초기화 여부 확인
  bool get isInitialized => _isInitialized;

  /// 날씨 아이콘들을 미리 로드하여 캐싱
  Future<void> preloadWeatherIcons() async {
    if (_isInitialized) return;

    try {
      // 기본 날씨 아이콘들
      final iconFiles = [
        'wind',
        'uv-index',
        'clear-day',
        'clear-night',
        'partly-cloudy-day',
        'partly-cloudy-night',
        'cloudy',
        'overcast',
        'rain',
        'snow',
        'thunderstorms',
      ];

      for (final fileName in iconFiles) {
        await _loadAndCacheIcon(fileName);
      }

      _isInitialized = true;
      debugPrint('🎨 Weather icons preloaded successfully');
    } catch (e) {
      debugPrint('❌ Failed to preload weather icons: $e');
    }
  }

  /// 특정 아이콘을 로드하여 캐싱
  Future<void> _loadAndCacheIcon(String fileName) async {
    try {
      final svgString = await rootBundle.loadString(
        'assets/meteocons/design/fill/animation-ready/$fileName.svg',
      );

      // ignore: unused_local_variable
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

      // WebView 임시 비활성화
      debugPrint('⚠️ WebView가 비활성화되어 아이콘을 로드하지 않습니다: $fileName');
    } catch (e) {
      debugPrint('❌ Failed to load weather icon $fileName: $e');
    }
  }

  /// 캐시된 컨트롤러 가져오기 (임시 비활성화)
  dynamic getCachedController(String fileName) {
    debugPrint('⚠️ WebView 기능이 비활성화되었습니다: $fileName');
    return null;
  }

  /// 캐시 정리
  void clearCache() {
    _cachedControllers.clear();
    _isInitialized = false;
    debugPrint('🗑️ Weather icon cache cleared');
  }
}
