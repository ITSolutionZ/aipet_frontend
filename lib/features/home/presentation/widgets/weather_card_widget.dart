import 'package:aipet_frontend/features/home/data/services/openweathermap_service.dart';
import 'package:aipet_frontend/features/home/data/services/weather_advice_service.dart';
import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:aipet_frontend/shared/design/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 날씨 정보 카드 위젯
class WeatherCardWidget extends StatefulWidget {
  final WeatherEntity weather;

  const WeatherCardWidget({super.key, required this.weather});

  @override
  State<WeatherCardWidget> createState() => _WeatherCardWidgetState();
}

class _WeatherCardWidgetState extends State<WeatherCardWidget> {
  final WeatherAdviceService _adviceService = WeatherAdviceService();
  String? _dynamicAdvice;
  bool _adviceLoading = true;

  // WebView 관련
  late WebViewController _webViewController;
  late WebViewController _windWebViewController;
  late WebViewController _uvWebViewController;
  bool _iconLoaded = false;
  bool _windLoaded = false;
  bool _uvLoaded = false;

  @override
  void initState() {
    super.initState();

    // WebView 컨트롤러 초기화
    _initializeWebView();

    // 동적 어드바이스 생성
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateAdvice();
    });
  }

  /// WebView 초기화 및 SVG 직접 로드
  Future<void> _initializeWebView() async {
    final fileName = OpenWeatherMapService.getDetailedMeteoconIcon(
      widget.weather.weatherId,
      widget.weather.iconCode,
    );

    // 3개의 WebView 동시 로드
    await Future.wait([
      _loadSvgToWebView('weather', fileName),
      _loadSvgToWebView('wind', 'wind'),
      _loadSvgToWebView('uv', 'uv-index'),
    ]);
  }

  /// SVG를 WebView에 로드하는 헬퍼 메서드
  Future<void> _loadSvgToWebView(String type, String fileName) async {
    try {
      // SVG 파일을 직접 읽기
      final svgString = await rootBundle.loadString(
        'assets/meteocons/design/fill/animation-ready/$fileName.svg',
      );

      // HTML 스트링 생성
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

      // WebView 컨트롤러 생성
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..loadHtmlString(htmlContent);

      if (mounted) {
        setState(() {
          switch (type) {
            case 'weather':
              _webViewController = controller;
              _iconLoaded = true;
              break;
            case 'wind':
              _windWebViewController = controller;
              _windLoaded = true;
              break;
            case 'uv':
              _uvWebViewController = controller;
              _uvLoaded = true;
              break;
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load $type SVG: $e');
    }
  }

  /// OpenAI API를 통해 동적 어드바이스 생성
  Future<void> _generateAdvice() async {
    try {
      debugPrint('🤖 Starting weather advice generation...');

      final advice = await _adviceService
          .generateWalkingAdvice(widget.weather)
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              debugPrint('⏰ Weather advice generation timed out (3s)');
              throw Exception('Timeout');
            },
          );

      debugPrint('✅ Weather advice generated: $advice');

      if (mounted) {
        setState(() {
          _dynamicAdvice = advice;
          _adviceLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Weather advice generation failed: $e');

      if (mounted) {
        setState(() {
          _dynamicAdvice = _getDefaultAdvice();
          _adviceLoading = false;
        });
      }
    }
  }

  /// 기본 어드바이스 반환
  String _getDefaultAdvice() {
    switch (widget.weather.dogRiskLevel) {
      case WBGTRiskLevel.safe:
        return '今日は散歩日和です！楽しくお散歩しましょう🐕';
      case WBGTRiskLevel.caution:
        return '暑さに注意して水分補給を忘れずに散歩してください💧';
      case WBGTRiskLevel.alert:
        return '暑いので涼しい時間帯を選んで散歩しましょう🌤️';
      case WBGTRiskLevel.danger:
        return '熱中症の危険があります、短時間の散歩にしてください⚠️';
      case WBGTRiskLevel.extreme:
        return '非常に危険です、今日の散歩は控えましょう🚫';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 위험 상황 체크 및 모달 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.weather.isDangerous) {
        _showDangerModal(context);
      }
    });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 첫 번째+두 번째 줄: 날씨 아이콘이 2행 차지
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 날씨 아이콘 (2행 차지)
              _buildWeatherIcon(widget.weather.iconCode),
              const SizedBox(width: AppSpacing.sm),

              // 오른쪽 정보들 (2행)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 첫 번째 줄: 숫자 | 온도단위 | 바람 | UV | 특이사항(1개)
                    Row(
                      children: [
                        // 온도 숫자
                        Text(
                          '${widget.weather.temperature.round()}',
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                        // 특이사항 (1개만 표시: 파티클 우선, 없으면 습도)
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
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 세 번째 줄: 산책 뱃지 + 어드바이스
          Row(
            children: [
              _buildRiskIndicator(),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildCompactWalkingAdvice()),
            ],
          ),
        ],
      ),
    );
  }

  /// 날씨 아이콘 빌드 (WebView 애니메이션)
  Widget _buildWeatherIcon(String iconCode) {
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

  /// 날씨 조건에 따른 파티클 아이콘 경로 반환
  String? _getWeatherParticleIcon() {
    final weatherId = widget.weather.weatherId;

    // OpenWeatherMap weatherId 기반 파티클 선택
    if (weatherId >= 200 && weatherId < 300) {
      // 천둥번개
      return 'assets/meteocons/design/fill/animation-ready/lightning-bolt.svg';
    } else if (weatherId >= 300 && weatherId < 400) {
      // 이슬비
      return 'assets/meteocons/design/fill/animation-ready/raindrop.svg';
    } else if (weatherId >= 500 && weatherId < 600) {
      // 비
      if (weatherId >= 502) {
        // 폭우 (heavy rain)
        return 'assets/meteocons/design/fill/animation-ready/raindrops.svg';
      } else {
        // 보통 비
        return 'assets/meteocons/design/fill/animation-ready/raindrop.svg';
      }
    } else if (weatherId >= 600 && weatherId < 700) {
      // 눈
      return 'assets/meteocons/design/fill/animation-ready/snowflake.svg';
    } else if (weatherId >= 701 && weatherId < 800) {
      // 대기 현상 (안개, 연무, 먼지 등)
      if (weatherId == 701 || weatherId == 741) {
        // 안개
        return null; // 안개는 파티클 표시 안함
      } else if (weatherId >= 761 && weatherId <= 762) {
        // 먼지, 화산재
        return 'assets/meteocons/design/fill/animation-ready/smoke-particles.svg';
      }
    }

    return null; // 맑음이나 구름은 파티클 없음
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

  /// 특이사항 1개만 표시 (파티클 우선, 없으면 습도)
  Widget _buildSingleWeatherFeature() {
    final particleIcon = _getWeatherParticleIcon();

    if (particleIcon != null) {
      // 파티클이 있으면 파티클 표시
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
      // 파티클이 없으면 습도 표시
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

  /// 바람 아이콘만
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

  /// UV 아이콘만
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

  /// 위험도 지시기
  Widget _buildRiskIndicator() {
    final riskLevel = widget.weather.dogRiskLevel;
    String walkIcon;

    switch (riskLevel) {
      case WBGTRiskLevel.safe:
        walkIcon = 'assets/icons/walk_good.png';
        break;
      case WBGTRiskLevel.caution:
        walkIcon = 'assets/icons/walk_warning.png';
        break;
      case WBGTRiskLevel.alert:
        walkIcon = 'assets/icons/walk_warning.png';
        break;
      case WBGTRiskLevel.danger:
        walkIcon = 'assets/icons/walk_dont.png';
        break;
      case WBGTRiskLevel.extreme:
        walkIcon = 'assets/icons/walk_dont.png';
        break;
    }

    return SizedBox(
      width: 32,
      height: 32,
      child: Image.asset(walkIcon, fit: BoxFit.contain),
    );
  }

  /// 컴팩트한 산책 어드바이스 (산책 뱃지 옆)
  Widget _buildCompactWalkingAdvice() {
    final riskLevel = widget.weather.dogRiskLevel;
    Color recommendationColor;

    switch (riskLevel) {
      case WBGTRiskLevel.safe:
        recommendationColor = AppColors.pointGreen;
        break;
      case WBGTRiskLevel.caution:
        recommendationColor = Colors.yellow[700]!;
        break;
      case WBGTRiskLevel.alert:
        recommendationColor = Colors.orange;
        break;
      case WBGTRiskLevel.danger:
      case WBGTRiskLevel.extreme:
        recommendationColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: recommendationColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(
          color: recommendationColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: _adviceLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      recommendationColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '生成中...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: recommendationColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Text(
              _dynamicAdvice ?? widget.weather.dogWalkingRecommendation,
              style: AppTextStyles.bodySmall.copyWith(
                color: recommendationColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  /// 위험 상황 모달 표시
  void _showDangerModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: SvgPicture.asset(
                  'assets/meteocons/design/fill/animation-ready/barometer.svg',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '⚠️ 열사병 경고',
                style: AppTextStyles.h2.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'WBGT ${widget.weather.wbgt.toStringAsFixed(1)}°C\n${widget.weather.dogWalkingRecommendation}',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                  ),
                  child: const Text('確認'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
