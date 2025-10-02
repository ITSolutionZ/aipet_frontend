import 'package:aipet_frontend/shared/testing/mock_config.dart';

/// 🎭 Mockito 환경 도우미
///
/// 프로덕션 배포 시 mockito/ 폴더와 함께 삭제됩니다.
class MockitoEnvironmentHelper {
  /// 현재 Mock 사용 여부 확인
  static bool get shouldUseMock => MockConfig.shouldUseMock;

  /// 현재 환경 정보
  static MockEnvironment get currentEnvironment => MockConfig.currentEnvironment;

  /// 환경 정보 디버그 출력
  static void logEnvironmentInfo() {}

  /// 개발자용 Mock 강제 활성화
  static void forceMockMode() {
    MockConfig.setUseMock(true);
  }

  /// 개발자용 Real API 강제 활성화
  static void forceRealMode() {
    MockConfig.setUseMock(false);
  }

  /// 테스트용 환경 리셋
  static void resetForTesting() {
    MockConfig.reset();
  }
}
