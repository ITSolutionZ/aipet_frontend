import 'package:flutter/material.dart';

import '../../mock_config.dart';
import 'providers/mockito_environment_helper.dart';

/// 🧪 Mockito 통합 테스트 도우미
///
/// ⚠️ 이 파일은 Mockito 전용입니다!
/// 프로덕션 배포 시 mockito/ 폴더와 함께 삭제됩니다.
class MockitoIntegrationTester {
  /// 환경별 Mock 동작 테스트
  static void testEnvironmentSwitching() {
    debugPrint('🧪 === Mockito Environment Switching Test ===');

    // 1. Development 환경 테스트
    debugPrint('\n📱 Testing Development Environment:');
    MockConfig.setEnvironment(MockEnvironment.development);
    MockitoEnvironmentHelper.logEnvironmentInfo();

    // 2. Testing 환경 테스트
    debugPrint('\n🧪 Testing Testing Environment:');
    MockConfig.setEnvironment(MockEnvironment.testing);
    MockitoEnvironmentHelper.logEnvironmentInfo();

    // 3. Production 환경 테스트
    debugPrint('\n🚀 Testing Production Environment:');
    MockConfig.setEnvironment(MockEnvironment.production);
    MockitoEnvironmentHelper.logEnvironmentInfo();

    // 4. 환경 리셋
    debugPrint('\n🔄 Resetting Environment:');
    MockitoEnvironmentHelper.resetForTesting();
    MockitoEnvironmentHelper.logEnvironmentInfo();

    debugPrint('\n✅ Environment switching test completed!');
  }

  /// Provider Mock/Real 전환 시뮬레이션
  static void testProviderSwitching() {
    debugPrint('\n🔄 === Provider Mock/Real Switching Test ===');

    // Mock 모드 테스트
    debugPrint('\n🎭 Testing Mock Mode:');
    MockitoEnvironmentHelper.forceMockMode();
    _simulateProviderUsage();

    // Real API 모드 테스트
    debugPrint('\n🌐 Testing Real API Mode:');
    MockitoEnvironmentHelper.forceRealMode();
    _simulateProviderUsage();

    // 환경 리셋
    MockitoEnvironmentHelper.resetForTesting();
    debugPrint('\n✅ Provider switching test completed!');
  }

  /// Provider 사용 시뮬레이션
  static void _simulateProviderUsage() {
    final shouldUseMock = MockConfig.shouldUseMock;

    debugPrint(
      '   📦 AI Repository: ${shouldUseMock ? "MockitoImpl" : "RealImpl"}',
    );
    debugPrint(
      '   🔐 Auth Repository: ${shouldUseMock ? "MockitoImpl" : "RealImpl"}',
    );
    debugPrint(
      '   🏠 Home Repository: ${shouldUseMock ? "MockitoImpl" : "RealImpl"}',
    );
    debugPrint(
      '   🐕 Pet Repository: ${shouldUseMock ? "MockitoImpl" : "RealImpl"}',
    );
  }

  /// 전체 통합 테스트 실행
  static void runAllTests() {
    debugPrint('🎭 ======= Mockito Integration Tests =======');
    testEnvironmentSwitching();
    testProviderSwitching();
    debugPrint('\n🎉 All Mockito integration tests completed!');
    debugPrint(
      '🎯 Ready for production deployment: rm -rf lib/shared/testing/mock_data/mockito/',
    );
  }
}
