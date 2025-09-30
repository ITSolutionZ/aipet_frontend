import 'package:aipet_frontend/features/home/data/services/weather_openai_service.dart';
import 'package:aipet_frontend/features/home/domain/entities/weather_entity.dart';
import 'package:flutter/foundation.dart';

/// 날씨 정보를 바탕으로 산책 어드바이스를 생성하는 서비스
class WeatherAdviceService {
  final WeatherOpenAIService _weatherOpenAIService;

  WeatherAdviceService({WeatherOpenAIService? weatherOpenAIService})
      : _weatherOpenAIService = weatherOpenAIService ?? WeatherOpenAIService();

  /// 날씨 정보를 바탕으로 반려견 산책 어드바이스 생성
  Future<String> generateWalkingAdvice(WeatherEntity weather) async {
    try {
      debugPrint('🌤️ WeatherAdviceService: Building prompt for weather advice');
      final prompt = _buildWeatherPrompt(weather);

      debugPrint('📡 WeatherAdviceService: Calling Weather OpenAI API...');
      final result = await _weatherOpenAIService.generateWeatherAdvice(prompt);

      if (result.isSuccess && result.dataOrNull != null) {
        final advice = result.dataOrNull!;
        debugPrint('✅ WeatherAdviceService: Weather OpenAI API success - $advice');
        return advice;
      } else {
        debugPrint('⚠️ WeatherAdviceService: Weather OpenAI API failed - ${result.message}');
        // API 실패 시 기본 어드바이스 반환
        return _getDefaultAdvice(weather);
      }
    } catch (e) {
      debugPrint('❌ WeatherAdviceService: Exception occurred - $e');
      // 에러 발생 시 기본 어드바이스 반환
      return _getDefaultAdvice(weather);
    }
  }

  /// 날씨 정보를 바탕으로 프롬프트 생성 (최적화된 간단 버전)
  String _buildWeatherPrompt(WeatherEntity weather) {
    final riskLevelText = _getRiskLevelText(weather.dogRiskLevel);

    return '''
반려견 산책 어드바이스를 일본어 한 줄로:
온도${weather.temperature.round()}°C, WBGT${weather.wbgt.toStringAsFixed(1)}°C, 위험도:$riskLevelText

예시: 안전→"今日は散歩日和🐕", 주의→"水分補給を忘れずに💧", 위험→"涼しい時間に短く⚠️"

답변:''';
  }

  /// 위험도 레벨을 텍스트로 변환
  String _getRiskLevelText(WBGTRiskLevel riskLevel) {
    switch (riskLevel) {
      case WBGTRiskLevel.safe:
        return '안전';
      case WBGTRiskLevel.caution:
        return '주의';
      case WBGTRiskLevel.alert:
        return '경계';
      case WBGTRiskLevel.danger:
        return '위험';
      case WBGTRiskLevel.extreme:
        return '매우위험';
    }
  }

  /// API 실패 시 기본 어드바이스 반환
  String _getDefaultAdvice(WeatherEntity weather) {
    switch (weather.dogRiskLevel) {
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
}