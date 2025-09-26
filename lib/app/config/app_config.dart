import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Centralized env accessor
String _env(String key, [String fallback = '']) =>
    dotenv.env[key] ?? fallback; // Added

/// 앱 설정 관리 클래스
///
/// 환경별 설정값들과 환경 변수를 중앙에서 관리하고,
/// 런타임에 적절한 설정을 제공합니다.
///
/// 개발, 스테이징, 프로덕션 환경별로 다른 설정을 제공하며,
/// 앱의 모든 설정값을 중앙에서 관리합니다.
abstract class AppConfig {
  /// API 베이스 URL
  String get apiBaseUrl;

  /// 환경변수에서 API URL 가져오기
  static String get apiBaseUrlFromEnv =>
      _env('API_BASE_URL', 'http://localhost:3000'); // Changed

  /// 앱 환경 (development, staging, production)
  String get environment;

  /// 디버그 모드 여부
  bool get isDebugMode;

  /// 로깅 활성화 여부
  bool get enableLogging;

  /// 분석 서비스 활성화 여부
  bool get enableAnalytics;

  /// 크래시 리포팅 활성화 여부
  bool get enableCrashlytics;

  /// API 타임아웃 (밀리초)
  int get apiTimeoutMs;

  /// 이미지 캐시 최대 크기 (MB)
  int get maxImageCacheSizeMB;

  /// 오프라인 데이터 보존 기간 (일)
  int get offlineDataRetentionDays;

  /// 앱 버전 체크 주기 (시간)
  int get versionCheckIntervalHours;

  /// 푸시 알림 기본 활성화 여부
  bool get defaultNotificationEnabled;

  /// 위치 서비스 정확도 (미터)
  double get locationAccuracyThreshold;

  /// 백그라운드 동기화 주기 (분)
  int get backgroundSyncIntervalMinutes;

  /// 애니메이션 지속 시간 (밀리초)
  int get defaultAnimationDurationMs;

  /// 네트워크 재시도 횟수
  int get networkRetryCount;

  /// 데이터베이스 버전
  int get databaseVersion;

  /// LINE 채널 ID
  String get lineChannelId;

  /// LINE OAuth Client ID
  String get lineClientId;

  /// LINE OAuth Client Secret
  String get lineClientSecret;

  /// LINE OAuth Redirect URI
  String get lineRedirectUri;

  /// OpenAI API 키
  String get openaiApiKey;

  /// OpenAI AI 모델명
  String get openaiModel;

  /// 날씨 API 키
  String get weatherApiKey;

  /// Google Cloud Map Platform API 키
  String get googleMapsApiKey;

  /// Google Public API 키 (예: 일부 웹 SDK 등에서 사용)
  String get googlePublicApiKey; // Added

  /// YouTube API 키
  String get youtubeApiKey;

  /// Google Calendar API 키
  String get googleCalendarApiKey;

  // ----------------------
  // Firebase (.env 기반)
  // Note: Most Flutter apps also rely on firebase_options.dart for initialization,
  // but these keys are provided here for services that need raw keys at runtime.
  // ----------------------
  String get firebaseProjectId; // Added
  String get firebaseMessagingSenderId; // Added
  String get firebaseApiKeyAndroid; // Added
  String get firebaseApiKeyIos; // Added
  String get firebaseApiKeyWeb; // Added
  String get firebaseAppIdAndroid; // Added
  String get firebaseAppIdIos; // Added

  /// Firebase Auth 로그인 엔드포인트
  String get firebaseAuthLoginEndpoint => '/api/firebase-auth/login';

  /// 전체 Firebase Auth 로그인 URL
  String get firebaseAuthLoginUrl => apiBaseUrl + firebaseAuthLoginEndpoint;

  /// 환경 변수 로드 확인
  bool get isEnvLoaded => dotenv.isInitialized;

  /// 환경 변수 초기화
  Future<void> loadEnv() async {
    await dotenv.load();
  }

  /// Mock 모드 여부 (개발 환경에서만 true)
  bool get isMockMode => environment == 'development';

  /// 모든 필수 API 키가 설정되었는지 확인
  bool get areApiKeysConfigured {
    return googleMapsApiKey.isNotEmpty &&
        openaiApiKey.isNotEmpty &&
        weatherApiKey.isNotEmpty &&
        lineChannelId.isNotEmpty;
  }

  /// 🛡️ API 키 설정 상태 확인 (보안 강화)
  ///
  /// 실제 키 값은 절대 로그에 출력하지 않으며, 존재 여부만 확인합니다.
  void logApiKeyStatus() {
    if (!kDebugMode) return; // 릴리즈 모드에서는 실행하지 않음

    if (isEnvLoaded) {
      debugPrint('🔑 API Key Status (키 값은 보안상 표시되지 않습니다):');
      debugPrint('  Google Maps: ${googleMapsApiKey.isNotEmpty ? '✅ 설정됨' : '❌ 미설정'}');
      debugPrint('  OpenAI: ${openaiApiKey.isNotEmpty ? '✅ 설정됨' : '❌ 미설정'}');
      debugPrint('  Weather: ${weatherApiKey.isNotEmpty ? '✅ 설정됨' : '❌ 미설정'}');
      debugPrint('  LINE: ${lineChannelId.isNotEmpty ? '✅ 설정됨' : '❌ 미설정'}');
      debugPrint('  YouTube: ${youtubeApiKey.isNotEmpty ? '✅ 설정됨' : '❌ 미설정'}');
      debugPrint('  Google Calendar: ${googleCalendarApiKey.isNotEmpty ? '✅ 설정됨' : '❌ 미설정'}');
    } else {
      debugPrint('❌ Environment variables not loaded');
    }
  }

  /// 특정 API 키가 유효한지 확인
  bool isApiKeyValid(String apiKey, String serviceName) {
    if (apiKey.isEmpty) {
      debugPrint('❌ $serviceName API 키가 설정되지 않았습니다.');
      return false;
    }

    if (apiKey.length < 10) {
      debugPrint('❌ $serviceName API 키가 너무 짧습니다.');
      return false;
    }

    return true;
  }

  /// Google Maps API 키 유효성 검사
  bool get isGoogleMapsApiKeyValid =>
      isApiKeyValid(googleMapsApiKey, 'Google Maps');

  /// 현재 설정된 앱 설정 인스턴스를 반환합니다.
  static AppConfig get current => _current;
  static AppConfig _current = DevelopmentConfig();

  /// 앱 설정을 초기화합니다.
  ///
  /// [config] 초기화할 설정 객체
  static void initialize(AppConfig config) {
    _current = config;
  }

  /// .env 를 먼저 로드하고 기본 설정(개발)을 초기화하는 헬퍼
  static Future<void> bootstrap({AppConfig? override}) async {
    // Added
    if (!dotenv.isInitialized) {
      await dotenv.load();
    }
    initialize(override ?? DevelopmentConfig());
  }
}

/// 개발 환경 설정
///
/// 개발 환경에서 사용되는 설정값들을 정의합니다.
/// 디버그 모드가 활성화되고 로깅이 상세하게 출력됩니다.
class DevelopmentConfig extends AppConfig {
  @override
  String get apiBaseUrl => AppConfig.apiBaseUrlFromEnv; // Changed

  @override
  String get environment => 'development';

  @override
  bool get isDebugMode => true;

  @override
  bool get enableLogging => true;

  @override
  bool get enableAnalytics => false;

  @override
  bool get enableCrashlytics => false;

  @override
  int get apiTimeoutMs => 30000;

  @override
  int get maxImageCacheSizeMB => 100;

  @override
  int get offlineDataRetentionDays => 7;

  @override
  int get versionCheckIntervalHours => 24;

  @override
  bool get defaultNotificationEnabled => true;

  @override
  double get locationAccuracyThreshold => 10.0;

  @override
  int get backgroundSyncIntervalMinutes => 15;

  @override
  int get defaultAnimationDurationMs => 300;

  @override
  int get networkRetryCount => 3;

  @override
  int get databaseVersion => 1;

  @override
  String get lineChannelId => _env('LINE_CHANNEL_ID'); // Changed

  @override
  String get lineClientId => _env('LINE_CLIENT_ID'); // Changed

  @override
  String get lineClientSecret => _env('LINE_CLIENT_SECRET'); // Changed

  @override
  String get lineRedirectUri => _env('LINE_REDIRECT_URI'); // Changed

  @override
  String get openaiApiKey => _env('OPENAI_API_KEY'); // Changed

  @override
  String get openaiModel => 'gpt-3.5-turbo';

  @override
  String get weatherApiKey => _env('WEATHER_API_KEY'); // Changed

  @override
  String get googleMapsApiKey => _env('GOOGLE_MAPS_API_KEY'); // Changed

  @override
  String get googlePublicApiKey => _env('GOOGLE_PUBLIC_API_KEY'); // Added

  @override
  String get youtubeApiKey => _env('YOUTUBE_API_KEY'); // Added

  @override
  String get googleCalendarApiKey => _env('GOOGLE_CALENDAR_API_KEY'); // Added

  // Firebase
  @override
  String get firebaseProjectId => _env('FIREBASE_PROJECT_ID'); // Added
  @override
  String get firebaseMessagingSenderId => _env('FIREBASE_MESSAGING_SENDER_ID'); // Added
  @override
  String get firebaseApiKeyAndroid => _env('FIREBASE_API_KEY_ANDROID'); // Added
  @override
  String get firebaseApiKeyIos => _env('FIREBASE_API_KEY_IOS'); // Added
  @override
  String get firebaseApiKeyWeb => _env('FIREBASE_API_KEY_WEB'); // Added
  @override
  String get firebaseAppIdAndroid => _env('FIREBASE_APP_ID_ANDROID'); // Added
  @override
  String get firebaseAppIdIos => _env('FIREBASE_APP_ID_IOS'); // Added
}

/// 스테이징 환경 설정
///
/// 스테이징 환경에서 사용되는 설정값들을 정의합니다.
/// 프로덕션과 유사하지만 디버깅이 가능합니다.
class StagingConfig extends AppConfig {
  @override
  String get apiBaseUrl => 'https://staging-api.aipet.com';

  @override
  String get environment => 'staging';

  @override
  bool get isDebugMode => false;

  @override
  bool get enableLogging => true;

  @override
  bool get enableAnalytics => true;

  @override
  bool get enableCrashlytics => false;

  @override
  int get apiTimeoutMs => 20000;

  @override
  int get maxImageCacheSizeMB => 200;

  @override
  int get offlineDataRetentionDays => 14;

  @override
  int get versionCheckIntervalHours => 12;

  @override
  bool get defaultNotificationEnabled => true;

  @override
  double get locationAccuracyThreshold => 5.0;

  @override
  int get backgroundSyncIntervalMinutes => 30;

  @override
  int get defaultAnimationDurationMs => 250;

  @override
  int get networkRetryCount => 2;

  @override
  int get databaseVersion => 1;

  @override
  String get lineChannelId => _env('LINE_CHANNEL_ID'); // Changed

  @override
  String get lineClientId => _env('LINE_CLIENT_ID'); // Changed

  @override
  String get lineClientSecret => _env('LINE_CLIENT_SECRET'); // Changed

  @override
  String get lineRedirectUri => _env('LINE_REDIRECT_URI'); // Changed

  @override
  String get openaiApiKey => _env('OPENAI_API_KEY'); // Changed

  @override
  String get openaiModel => 'gpt-4';

  @override
  String get weatherApiKey => _env('WEATHER_API_KEY'); // Changed

  @override
  String get googleMapsApiKey => _env('GOOGLE_MAPS_API_KEY'); // Changed

  @override
  String get googlePublicApiKey => _env('GOOGLE_PUBLIC_API_KEY'); // Added

  @override
  String get youtubeApiKey => _env('YOUTUBE_API_KEY'); // Added

  @override
  String get googleCalendarApiKey => _env('GOOGLE_CALENDAR_API_KEY'); // Added

  @override
  String get firebaseProjectId => _env('FIREBASE_PROJECT_ID'); // Added
  @override
  String get firebaseMessagingSenderId => _env('FIREBASE_MESSAGING_SENDER_ID'); // Added
  @override
  String get firebaseApiKeyAndroid => _env('FIREBASE_API_KEY_ANDROID'); // Added
  @override
  String get firebaseApiKeyIos => _env('FIREBASE_API_KEY_IOS'); // Added
  @override
  String get firebaseApiKeyWeb => _env('FIREBASE_API_KEY_WEB'); // Added
  @override
  String get firebaseAppIdAndroid => _env('FIREBASE_APP_ID_ANDROID'); // Added
  @override
  String get firebaseAppIdIos => _env('FIREBASE_APP_ID_IOS'); // Added
}

/// 프로덕션 환경 설정
///
/// 프로덕션 환경에서 사용되는 설정값들을 정의합니다.
/// 최적화된 성능과 보안을 제공합니다.
class ProductionConfig extends AppConfig {
  @override
  String get apiBaseUrl => 'https://api.aipet.com';

  @override
  String get environment => 'production';

  @override
  bool get isDebugMode => false;

  @override
  bool get enableLogging => false;

  @override
  bool get enableAnalytics => true;

  @override
  bool get enableCrashlytics => true;

  @override
  int get apiTimeoutMs => 15000;

  @override
  int get maxImageCacheSizeMB => 500;

  @override
  int get offlineDataRetentionDays => 30;

  @override
  int get versionCheckIntervalHours => 6;

  @override
  bool get defaultNotificationEnabled => true;

  @override
  double get locationAccuracyThreshold => 3.0;

  @override
  int get backgroundSyncIntervalMinutes => 60;

  @override
  int get defaultAnimationDurationMs => 200;

  @override
  int get networkRetryCount => 1;

  @override
  int get databaseVersion => 1;

  @override
  String get lineChannelId => _env('LINE_CHANNEL_ID'); // Changed

  @override
  String get lineClientId => _env('LINE_CLIENT_ID'); // Changed

  @override
  String get lineClientSecret => _env('LINE_CLIENT_SECRET'); // Changed

  @override
  String get lineRedirectUri => _env('LINE_REDIRECT_URI'); // Changed

  @override
  String get openaiApiKey => _env('OPENAI_API_KEY'); // Changed

  @override
  String get openaiModel => 'gpt-4';

  @override
  String get weatherApiKey => _env('WEATHER_API_KEY'); // Changed

  @override
  String get googleMapsApiKey => _env('GOOGLE_MAPS_API_KEY'); // Changed

  @override
  String get googlePublicApiKey => _env('GOOGLE_PUBLIC_API_KEY'); // Added

  @override
  String get youtubeApiKey => _env('YOUTUBE_API_KEY'); // Added

  @override
  String get googleCalendarApiKey => _env('GOOGLE_CALENDAR_API_KEY'); // Added

  @override
  String get firebaseProjectId => _env('FIREBASE_PROJECT_ID'); // Added
  @override
  String get firebaseMessagingSenderId => _env('FIREBASE_MESSAGING_SENDER_ID'); // Added
  @override
  String get firebaseApiKeyAndroid => _env('FIREBASE_API_KEY_ANDROID'); // Added
  @override
  String get firebaseApiKeyIos => _env('FIREBASE_API_KEY_IOS'); // Added
  @override
  String get firebaseApiKeyWeb => _env('FIREBASE_API_KEY_WEB'); // Added
  @override
  String get firebaseAppIdAndroid => _env('FIREBASE_APP_ID_ANDROID'); // Added
  @override
  String get firebaseAppIdIos => _env('FIREBASE_APP_ID_IOS'); // Added
}

/// 테스트 환경 설정
///
/// 테스트 환경에서 사용되는 설정값들을 정의합니다.
/// 빠른 응답과 테스트용 데이터를 제공합니다.
class TestConfig extends AppConfig {
  @override
  String get apiBaseUrl => 'https://test-api.aipet.com';

  @override
  String get environment => 'test';

  @override
  bool get isDebugMode => true;

  @override
  bool get enableLogging => true;

  @override
  bool get enableAnalytics => false;

  @override
  bool get enableCrashlytics => false;

  @override
  int get apiTimeoutMs => 5000;

  @override
  int get maxImageCacheSizeMB => 50;

  @override
  int get offlineDataRetentionDays => 1;

  @override
  int get versionCheckIntervalHours => 1;

  @override
  bool get defaultNotificationEnabled => false;

  @override
  double get locationAccuracyThreshold => 20.0;

  @override
  int get backgroundSyncIntervalMinutes => 5;

  @override
  int get defaultAnimationDurationMs => 100;

  @override
  int get networkRetryCount => 1;

  @override
  int get databaseVersion => 1;

  @override
  String get lineChannelId => '';

  @override
  String get lineClientId => '';

  @override
  String get lineClientSecret => '';

  @override
  String get lineRedirectUri => '';

  @override
  String get openaiApiKey => '';

  @override
  String get openaiModel => 'gpt-3.5-turbo';

  @override
  String get weatherApiKey => '';

  @override
  String get googleMapsApiKey => '';

  @override
  String get googlePublicApiKey => '';

  @override
  String get youtubeApiKey => '';

  @override
  String get googleCalendarApiKey => '';

  @override
  String get firebaseProjectId => '';
  @override
  String get firebaseMessagingSenderId => '';
  @override
  String get firebaseApiKeyAndroid => '';
  @override
  String get firebaseApiKeyIos => '';
  @override
  String get firebaseApiKeyWeb => '';
  @override
  String get firebaseAppIdAndroid => '';
  @override
  String get firebaseAppIdIos => '';
}
