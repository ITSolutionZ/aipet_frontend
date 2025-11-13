import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 관련 상수들
class EnvironmentConstants {
  EnvironmentConstants._();

  // ========== API Keys ==========

  /// Google Maps API 키
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY']?.isNotEmpty == true
      ? dotenv.env['GOOGLE_MAPS_API_KEY']!
      : dotenv.env['GOOGLE_PUBLIC_API_KEY'] ?? '';

  /// Weather API 키
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';

  /// OpenAI API 키
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  /// LINE Channel ID
  static String get lineChannelId => dotenv.env['LINE_CHANNEL_ID'] ?? '';

  // ========== API Base URLs ==========

  /// Development API Base URL
  /// Android 에뮬레이터: http://10.0.2.2:3000
  /// iOS 시뮬레이터/실제 기기: http://localhost:3000
  static String get devApiBaseUrl {
    final envUrl = dotenv.env['DEV_API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      // Android 에뮬레이터 자동 감지 및 변환
      if (defaultTargetPlatform == TargetPlatform.android &&
          envUrl.contains('localhost')) {
        return envUrl.replaceAll('localhost', '10.0.2.2');
      }
      return envUrl;
    }
    // 기본값: 플랫폼에 따라 자동 선택
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3000'
        : 'http://localhost:3000';
  }

  /// Staging API Base URL
  static String get stagingApiBaseUrl =>
      dotenv.env['STAGING_API_BASE_URL'] ?? 'https://staging-api.aipet.com';

  /// Production API Base URL
  static String get prodApiBaseUrl =>
      dotenv.env['PROD_API_BASE_URL'] ?? 'https://api.aipet.com';

  /// Current environment API Base URL
  static String get apiBaseUrl {
    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    switch (environment) {
      case 'production':
        return prodApiBaseUrl;
      case 'staging':
        return stagingApiBaseUrl;
      case 'development':
      default:
        return devApiBaseUrl;
    }
  }

  // ========== 환경 변수 초기화 ==========

  /// 환경 변수 로드
  static Future<void> loadEnvironment() async {
    await dotenv.load(fileName: '.env');
  }

  // ========== 검증 메서드 ==========

  /// 필수 환경 변수가 모두 설정되어 있는지 확인
  static bool get areAllEnvironmentVariablesSet {
    return googleMapsApiKey.isNotEmpty &&
        weatherApiKey.isNotEmpty &&
        openAiApiKey.isNotEmpty &&
        lineChannelId.isNotEmpty;
  }

  /// 누락된 환경 변수 목록 반환
  static List<String> get missingEnvironmentVariables {
    final missing = <String>[];

    if (googleMapsApiKey.isEmpty) {
      missing.add('GOOGLE_MAPS_API_KEY or GOOGLE_PUBLIC_API_KEY');
    }
    if (weatherApiKey.isEmpty) missing.add('WEATHER_API_KEY');
    if (openAiApiKey.isEmpty) missing.add('OPENAI_API_KEY');
    if (lineChannelId.isEmpty) missing.add('LINE_CHANNEL_ID');

    return missing;
  }
}
