import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 전체 SVG 캐싱 서비스
///
/// 앱 전체에서 사용되는 모든 SVG 파일을 캐싱하여
/// WebView 생성 비용을 줄이고 성능을 향상시킵니다.
class SvgCacheService {
  // 싱글톤 패턴
  static final SvgCacheService _instance = SvgCacheService._internal();
  factory SvgCacheService() => _instance;
  SvgCacheService._internal();

  final Map<String, WebViewController> _svgCache = {};
  bool _initialized = false;

  // 미리 로드할 SVG 파일 목록
  final List<String> _preloadSvgFiles = const [
    // 날씨 아이콘 (OpenWeatherMap 기준)
    'clear-day',
    'clear-night',
    'partly-cloudy-day',
    'partly-cloudy-night',
    'cloudy-day',
    'cloudy-night',
    'overcast-day',
    'overcast-night',
    'rain',
    'partly-cloudy-day-rain',
    'partly-cloudy-night-rain',
    'snow',
    'sleet',
    'partly-cloudy-day-snow',
    'thunderstorms-day',
    'thunderstorms-night',
    'thunderstorms-day-rain',
    'thunderstorms-rain',
    'fog-day',
    'fog-night',
    'haze-day',
    'dust-day',

    // 고정 아이콘
    'wind',
    'uv-index',
    'humidity',
    'celsius',

    // 기타 자주 사용되는 아이콘들
    'lightning-bolt',
    'raindrop',
    'raindrops',
    'snowflake',
    'smoke-particles',
  ];

  /// 모든 SVG 파일을 미리 로드하여 캐싱
  Future<void> preloadAllSvgs() async {
    if (_initialized) {
      debugPrint('🎨 SvgCacheService already initialized.');
      return;
    }

    final startTime = DateTime.now();
    debugPrint('🎨 Preloading all SVG files...');

    try {
      final futures = _preloadSvgFiles.map((fileName) async {
        try {
          final controller = await _createWebViewController(fileName);
          _svgCache[fileName] = controller;
          debugPrint('  ✓ Cached: $fileName');
        } catch (e) {
          debugPrint('  ❌ Failed to cache $fileName: $e');
        }
      }).toList();

      await Future.wait(futures);

      _initialized = true;
      final duration = DateTime.now().difference(startTime);
      debugPrint(
        '✅ SVG files preloaded: ${_svgCache.length} files in ${duration.inMilliseconds}ms',
      );
    } catch (e) {
      debugPrint('❌ Failed to preload SVG files: $e');
    }
  }

  /// 캐시된 WebViewController 가져오기
  WebViewController? getCachedController(String fileName) {
    return _svgCache[fileName];
  }

  /// 동적으로 SVG 로드 (캐시에 없을 때)
  Future<WebViewController?> loadSvg(String fileName) async {
    // 이미 캐시에 있으면 반환
    if (_svgCache.containsKey(fileName)) {
      return _svgCache[fileName];
    }

    try {
      final controller = await _createWebViewController(fileName);
      _svgCache[fileName] = controller;
      debugPrint('🎨 Dynamically loaded SVG: $fileName');
      return controller;
    } catch (e) {
      debugPrint('❌ Failed to load SVG: $fileName - $e');
      return null;
    }
  }

  /// 새로운 WebViewController 생성
  Future<WebViewController> _createWebViewController(String fileName) async {
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
          onWebResourceError: (error) => {
            // 에러 로그 최소화
          },
        ),
      )
      ..loadHtmlString(htmlContent);

    return controller;
  }

  /// 캐시 상태 확인
  bool get isInitialized => _initialized;
  int get cacheSize => _svgCache.length;

  /// 특정 SVG가 캐시되어 있는지 확인
  bool isCached(String fileName) => _svgCache.containsKey(fileName);

  /// 캐시 초기화 (개발용)
  void clearCache() {
    _svgCache.clear();
    _initialized = false;
    debugPrint('🔄 SvgCacheService: Cache cleared');
  }
}
