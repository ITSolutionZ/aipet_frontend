import '../constants/environment_constants.dart';

enum ApiEnvironment { development, staging, production }

class ApiConfig {
  static const String apiVersion = 'v1';

  static ApiEnvironment get currentEnvironment {
    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    switch (environment) {
      case 'production':
        return ApiEnvironment.production;
      case 'staging':
        return ApiEnvironment.staging;
      case 'development':
      default:
        return ApiEnvironment.development;
    }
  }

  static String get baseUrl {
    switch (currentEnvironment) {
      case ApiEnvironment.development:
        return EnvironmentConstants.devApiBaseUrl;
      case ApiEnvironment.staging:
        return EnvironmentConstants.stagingApiBaseUrl;
      case ApiEnvironment.production:
        return EnvironmentConstants.prodApiBaseUrl;
    }
  }

  /// 백엔드 API URL (버전 포함)
  static String get fullApiUrl => '$baseUrl/api/$apiVersion';

  static bool get isProduction =>
      currentEnvironment == ApiEnvironment.production;
  static bool get isDevelopment =>
      currentEnvironment == ApiEnvironment.development;
  static bool get isStaging => currentEnvironment == ApiEnvironment.staging;

  static Duration get defaultTimeout {
    switch (currentEnvironment) {
      case ApiEnvironment.development:
        return const Duration(seconds: 60); // 개발 환경에서는 디버깅을 위해 더 긴 시간
      case ApiEnvironment.staging:
        return const Duration(seconds: 45);
      case ApiEnvironment.production:
        return const Duration(seconds: 30);
    }
  }

  static int get maxRetryAttempts {
    switch (currentEnvironment) {
      case ApiEnvironment.development:
        return 5; // 개발 환경에서는 더 많은 재시도
      case ApiEnvironment.staging:
        return 3;
      case ApiEnvironment.production:
        return 2; // 프로덕션에서는 빠른 실패
    }
  }

  static Duration get retryDelay {
    switch (currentEnvironment) {
      case ApiEnvironment.development:
        return const Duration(seconds: 2);
      case ApiEnvironment.staging:
        return const Duration(seconds: 1);
      case ApiEnvironment.production:
        return const Duration(milliseconds: 500);
    }
  }

  static bool get enableLogging {
    switch (currentEnvironment) {
      case ApiEnvironment.development:
        return true;
      case ApiEnvironment.staging:
        return true;
      case ApiEnvironment.production:
        return false; // 프로덕션에서는 로깅 비활성화
    }
  }

  static Map<String, String> get defaultHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Version': apiVersion,
      'X-Client-Platform': 'flutter',
    };

    if (!isProduction) {
      headers['X-Environment'] = currentEnvironment.name;
    }

    return headers;
  }

  static void printCurrentConfig() {
    if (isDevelopment) {
      print('🔧 API Configuration:');
      print('   Environment: ${currentEnvironment.name}');
      print('   Base URL: $baseUrl');
      print('   Full API URL: $fullApiUrl');
      print('   Timeout: ${defaultTimeout.inSeconds}s');
      print('   Max Retries: $maxRetryAttempts');
      print('   Retry Delay: ${retryDelay.inMilliseconds}ms');
      print('   Logging: $enableLogging');
    }
  }
}
