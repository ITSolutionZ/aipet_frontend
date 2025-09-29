import 'package:aipet_frontend/app/config/app_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트 헬퍼 클래스
///
/// 모든 테스트에서 공통으로 사용되는 설정과 유틸리티를 제공합니다.
class TestHelper {
  /// 테스트용 환경변수 초기화
  static Future<void> initializeTestEnvironment() async {
    // 테스트 환경 설정으로 초기화
    AppConfig.initialize(TestConfig());

    // 환경변수가 이미 로드된 경우 스킵
    if (dotenv.isInitialized) {
      return;
    }

    try {
      // .env 파일 로드 시도
      await dotenv.load();
    } catch (e) {
      // .env 파일이 없는 경우 테스트용 환경변수 직접 설정
      dotenv.testLoad(
        fileInput: '''
# 테스트용 환경변수
OPENAI_API_KEY=test_openai_api_key_for_testing
GOOGLE_MAPS_API_KEY=test_google_maps_api_key_for_testing
WEATHER_API_KEY=test_weather_api_key_for_testing
LINE_CHANNEL_ID=test_line_channel_id_for_testing
''',
      );
    }
  }

  /// 테스트 환경 정리
  static void cleanupTestEnvironment() {
    // 필요시 테스트 환경 정리 로직 추가
  }
}

/// 테스트 설정 초기화
Future<void> setupTestEnvironment() async {
  await TestHelper.initializeTestEnvironment();
}

/// 테스트 정리
void teardownTestEnvironment() {
  TestHelper.cleanupTestEnvironment();
}
