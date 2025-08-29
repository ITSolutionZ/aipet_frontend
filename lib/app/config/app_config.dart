/// 앱 설정 관리 클래스
///
/// 환경별 설정값들을 중앙에서 관리하고,
/// 런타임에 적절한 설정을 제공합니다.
///
/// 개발, 스테이징, 프로덕션 환경별로 다른 설정을 제공하며,
/// 앱의 모든 설정값을 중앙에서 관리합니다.
abstract class AppConfig {
  /// API 베이스 URL
  String get apiBaseUrl;

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

  /// OpenAI API 키
  String get openaiApiKey;

  /// 날씨 API 키
  String get weatherApiKey;

  /// Google Cloud Map Platform API 키
  String get googleMapsApiKey;

  /// 현재 설정된 앱 설정 인스턴스를 반환합니다.
  static AppConfig get current => _current;
  static AppConfig _current = DevelopmentConfig();

  /// 앱 설정을 초기화합니다.
  ///
  /// [config] 초기화할 설정 객체
  static void initialize(AppConfig config) {
    _current = config;
  }
}

/// 개발 환경 설정
///
/// 개발 환경에서 사용되는 설정값들을 정의합니다.
/// 디버그 모드가 활성화되고 로깅이 상세하게 출력됩니다.
class DevelopmentConfig extends AppConfig {
  @override
  String get apiBaseUrl => 'https://dev-api.aipet.com';

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
  int get apiTimeoutMs => 10000;

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
  int get backgroundSyncIntervalMinutes => 30;

  @override
  int get defaultAnimationDurationMs => 300;

  @override
  int get networkRetryCount => 3;

  @override
  int get databaseVersion => 1;

  @override
  String get lineChannelId => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드

  @override
  String get openaiApiKey => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드

  @override
  String get weatherApiKey => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드

  @override
  String get googleMapsApiKey => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드
}

/// 스테이징 환경 설정
///
/// 스테이징 환경에서 사용되는 설정값들을 정의합니다.
/// 프로덕션과 유사하지만 디버깅 기능이 일부 활성화됩니다.
class StagingConfig extends AppConfig {
  @override
  String get apiBaseUrl => 'https://staging-api.aipet.com';

  @override
  String get environment => 'staging';

  @override
  bool get isDebugMode => true;

  @override
  bool get enableLogging => true;

  @override
  bool get enableAnalytics => true;

  @override
  bool get enableCrashlytics => true;

  @override
  int get apiTimeoutMs => 15000;

  @override
  int get maxImageCacheSizeMB => 150;

  @override
  int get offlineDataRetentionDays => 14;

  @override
  int get versionCheckIntervalHours => 12;

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
  String get lineChannelId => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드

  @override
  String get openaiApiKey => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드

  @override
  String get weatherApiKey => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드

  @override
  String get googleMapsApiKey => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드
}

/// 프로덕션 환경 설정
///
/// 프로덕션 환경에서 사용되는 설정값들을 정의합니다.
/// 성능과 보안을 최우선으로 하는 설정이 적용됩니다.
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
  int get apiTimeoutMs => 20000;

  @override
  int get maxImageCacheSizeMB => 200;

  @override
  int get offlineDataRetentionDays => 30;

  @override
  int get versionCheckIntervalHours => 6;

  @override
  bool get defaultNotificationEnabled => true;

  @override
  double get locationAccuracyThreshold => 5.0;

  @override
  int get backgroundSyncIntervalMinutes => 10;

  @override
  int get defaultAnimationDurationMs => 250;

  @override
  int get networkRetryCount => 5;

  @override
  int get databaseVersion => 1;

  @override
  String get lineChannelId => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드

  @override
  String get openaiApiKey => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드

  @override
  String get weatherApiKey => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드

  @override
  String get googleMapsApiKey => ''; // Mock 환경에서는 빈 문자열, 추후 백엔드 연동 시 .env에서 로드
}
