import 'package:aipet_frontend/features/home/data/models/weather_model.dart';
import 'package:aipet_frontend/features/home/presentation/controllers/weather_controller.dart';
import 'package:aipet_frontend/shared/services/weather_icon_service.dart';
import 'package:aipet_frontend/shared/utils/weather_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 날씨 뷰모델
///
/// WeatherCard의 상태 관리와 비즈니스 로직을 담당
class WeatherViewModel extends ChangeNotifier {
  final WeatherController _controller;

  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _walkingAdvice;
  bool? _isDay;
  String? _iconName;

  WeatherViewModel(this._controller) {
    _initialize();
  }

  // Getters
  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get walkingAdvice => _walkingAdvice;
  bool? get isDay => _isDay;
  String? get iconName => _iconName;

  /// 초기화
  void _initialize() {
    _isDay = _controller.isDayTime();
    _checkCachedData();

    if (_weatherData == null) {
      loadWeatherData(forceRefresh: false);
    }
  }

  /// 캐시된 데이터 확인
  void _checkCachedData() {
    final cachedData = _controller.cachedWeatherData;
    if (cachedData != null) {
      debugPrint('🔄 컨트롤러에서 캐시된 날씨 데이터 사용');
      _weatherData = cachedData;
      _isLoading = false;
      _isDay = _controller.isDayTime();
      _iconName = WeatherIconService.getWeatherIconName(
        _weatherData!.weatherId,
        _isDay!,
      );
      notifyListeners();
    }
  }

  /// 날씨 데이터 로드
  Future<void> loadWeatherData({
    bool forceRefresh = false,
    bool userTriggered = false,
  }) async {
    // 사용자가 탭한 경우 강제 새로고침
    if (userTriggered) {
      debugPrint('👆 사용자 탭 감지 - 강제 새로고침 실행');
      forceRefresh = true;
    }

    // 강제 리프레시가 아니고 이미 데이터가 있으면 API 호출하지 않음
    if (!forceRefresh && _weatherData != null && !_isLoading) {
      debugPrint('🔄 캐시된 날씨 데이터 사용 (API 호출 생략)');
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _controller.getCurrentWeather(
      userTriggered: userTriggered,
    );

    _isLoading = false;

    if (result.isSuccess && result.dataOrNull != null) {
      _weatherData = result.dataOrNull;
      debugPrint(
        '🌡️ 날씨 데이터 받음: ${_weatherData!.location}, ${_weatherData!.temperature}°C, UV: ${_weatherData!.uvIndex}, Wind: ${_weatherData!.windSpeed}m/s',
      );

      // 현재 시간 다시 확인 (API 호출 시점의 정확한 시간 사용)
      _isDay = _controller.isDayTime();
      _iconName = WeatherIconService.getWeatherIconName(
        _weatherData!.weatherId,
        _isDay!,
      );

      // 산책 조언 생성
      await _generateWalkingAdvice();
    } else {
      debugPrint('❌ 날씨 데이터 로드 실패: ${result.errorOrNull}');
      _errorMessage = result.errorOrNull;
      _weatherData = null;
      _walkingAdvice = null;
    }

    notifyListeners();
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
      if (adviceResult.isSuccess) {
        _walkingAdvice = adviceResult.dataOrNull?.toString();
      }
    } catch (e) {
      debugPrint('散歩アドバイス生成失敗: $e');
      // 폴백 조언 사용
      _walkingAdvice = '今日も散歩を楽しもう';
    }

    notifyListeners();
  }

  /// UV 아이콘 이름 가져오기
  String getUvIndexIcon() {
    if (_weatherData == null) return 'uv-index';
    return WeatherUtils.getUvIndexIcon(_weatherData!.uvIndex);
  }

  /// 풍속 아이콘 이름 가져오기
  String getWindIcon() {
    if (_weatherData == null) return 'wind-beaufort-0';
    return WeatherUtils.getWindIcon(_weatherData!.windSpeed);
  }

  /// 온도 텍스트 가져오기
  String getTemperatureText() {
    if (_isLoading) return '--';
    if (_weatherData == null) return '--';
    return '${_weatherData!.temperature.round()}';
  }

  /// 위치 텍스트 가져오기
  String getLocationText() {
    if (_isLoading) return '東京都品川区';
    return _weatherData?.location ?? '東京都品川区';
  }

  /// 상태 텍스트 가져오기
  String getStatusText() {
    if (_isLoading) {
      return _weatherData != null ? '天気情報を更新中...' : '天気情報を読み込み中...';
    }

    if (_errorMessage != null) {
      return '天気情報を取得できません';
    }

    return _walkingAdvice ?? '散歩情報を生成中...';
  }

  /// 새로고침 (사용자 탭)
  Future<void> refresh() async {
    await loadWeatherData(userTriggered: true);
  }
}

/// WeatherViewModel Provider
final weatherViewModelProvider = ChangeNotifierProvider<WeatherViewModel>((
  ref,
) {
  final controller = WeatherController(ref as WidgetRef);
  return WeatherViewModel(controller);
});
