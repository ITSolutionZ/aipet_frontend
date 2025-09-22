import '../../../../testing/mock_config.dart';

/// 🎭 Mockito 환경 도우미
///
/// 프로덕션 배포 시 mockito/ 폴더와 함께 삭제됩니다.
class MockitoEnvironmentHelper {
  /// 현재 Mock 사용 여부 확인
  static bool get shouldUseMock => MockConfig.shouldUseMock;

  /// 현재 환경 정보
  static MockEnvironment get currentEnvironment =>
      MockConfig.currentEnvironment;

  /// 환경 정보 디버그 출력
  static void logEnvironmentInfo() {
    // REMOVED_SECURITY_RISK: print('🎭 Mockito Environment Info:');
    // REMOVED_SECURITY_RISK: print('   Environment: ${currentEnvironment.name}');
    // REMOVED_SECURITY_RISK: print('   Use Mock: $shouldUseMock');
    // REMOVED_SECURITY_RISK: print('   Build Mode: ${_getBuildMode()}');
  }

  /// 빌드 모드 확인
  static String _getBuildMode() {
    bool kDebugMode = false;
    bool kProfileMode = false;
    bool kReleaseMode = false;

    assert(() {
      kDebugMode = true;
      return true;
    }());

    if (kDebugMode) return 'Debug';

    assert(() {
      kProfileMode = true;
      return true;
    }());

    if (kProfileMode) return 'Profile';

    kReleaseMode = true;
    return 'Release';
  }

  /// 개발자용 Mock 강제 활성화
  static void forceMockMode() {
    MockConfig.setUseMock(true);
    // REMOVED_SECURITY_RISK: print('🎭 Mockito: Mock mode forced ON');
  }

  /// 개발자용 Real API 강제 활성화
  static void forceRealMode() {
    MockConfig.setUseMock(false);
    // REMOVED_SECURITY_RISK: print('🎭 Mockito: Real API mode forced ON');
  }

  /// 테스트용 환경 리셋
  static void resetForTesting() {
    MockConfig.reset();
    // REMOVED_SECURITY_RISK: print('🎭 Mockito: Environment reset for testing');
  }
}
