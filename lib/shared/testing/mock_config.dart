import 'dart:io';

import 'package:flutter/foundation.dart';

/// 목업 데이터 사용 환경 정의
enum MockEnvironment {
  /// 개발 환경 - Mock 데이터 기본 사용
  development,

  /// 테스트 환경 - 항상 Mock 데이터 사용
  testing,

  /// 프로덕션 환경 - 실제 API 사용
  production,

  /// 스테이징 환경 - 설정에 따라 선택
  staging,
}

/// 목업 데이터 설정 관리
///
/// 환경별로 Mock/Real API 사용을 제어하고,
/// 실제 API 연동 시 깨끗한 마이그레이션을 지원합니다.
class MockConfig {
  static MockEnvironment? _overrideEnvironment;
  static bool? _overrideUseMock;

  /// 현재 실행 환경 감지
  static MockEnvironment get currentEnvironment {
    if (_overrideEnvironment != null) {
      return _overrideEnvironment!;
    }

    // 테스트 환경 확인
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return MockEnvironment.testing;
    }

    // 환경 변수로 환경 지정
    final envVar = Platform.environment['FLUTTER_ENV'];
    switch (envVar?.toLowerCase()) {
      case 'production':
      case 'prod':
        return MockEnvironment.production;
      case 'staging':
      case 'stage':
        return MockEnvironment.staging;
      case 'development':
      case 'dev':
      default:
        return kDebugMode ? MockEnvironment.development : MockEnvironment.production;
    }
  }

  /// Mock 데이터 사용 여부 결정
  static bool get shouldUseMock {
    if (_overrideUseMock != null) {
      return _overrideUseMock!;
    }

    // 환경 변수로 직접 제어
    final useMockEnv = Platform.environment['USE_MOCK_DATA'];
    if (useMockEnv != null) {
      return useMockEnv.toLowerCase() == 'true';
    }

    // 환경별 기본 설정
    switch (currentEnvironment) {
      case MockEnvironment.development:
        return true; // 개발 중에는 Mock 사용
      case MockEnvironment.testing:
        return true; // 테스트에서는 항상 Mock
      case MockEnvironment.staging:
        return false; // 스테이징에서는 실제 API 테스트
      case MockEnvironment.production:
        return false; // 프로덕션에서는 Real API
    }
  }

  /// 네트워크 지연 시뮬레이션 여부
  static bool get shouldSimulateNetworkDelay {
    switch (currentEnvironment) {
      case MockEnvironment.development:
        return true; // 개발 시 실제 네트워크 환경 시뮬레이션
      case MockEnvironment.testing:
        return false; // 테스트는 빠르게 실행
      case MockEnvironment.staging:
      case MockEnvironment.production:
        return false; // 실제 API 사용 시 시뮬레이션 불필요
    }
  }

  /// 에러 시나리오 시뮬레이션 여부
  static bool get shouldSimulateErrors {
    switch (currentEnvironment) {
      case MockEnvironment.development:
        return true; // 개발 시 에러 처리 테스트
      case MockEnvironment.testing:
        return true; // 테스트에서 에러 케이스 검증
      case MockEnvironment.staging:
      case MockEnvironment.production:
        return false; // 실제 환경에서는 시뮬레이션하지 않음
    }
  }

  /// Mock 상세 로깅 여부
  static bool get enableMockLogging {
    return currentEnvironment == MockEnvironment.development ||
        currentEnvironment == MockEnvironment.testing;
  }

  /// 환경 강제 설정 (테스트용)
  static void setEnvironment(MockEnvironment environment) {
    _overrideEnvironment = environment;
  }

  /// Mock 사용 강제 설정 (테스트용)
  static void setUseMock(bool useMock) {
    _overrideUseMock = useMock;
  }

  /// 설정 초기화 (테스트 후 정리용)
  static void reset() {
    _overrideEnvironment = null;
    _overrideUseMock = null;
  }

  /// 현재 설정 정보 출력 (디버깅용)
  static Map<String, dynamic> get debugInfo => {
    'environment': currentEnvironment.name,
    'shouldUseMock': shouldUseMock,
    'shouldSimulateNetworkDelay': shouldSimulateNetworkDelay,
    'shouldSimulateErrors': shouldSimulateErrors,
    'enableMockLogging': enableMockLogging,
    'overrides': {'environment': _overrideEnvironment?.name, 'useMock': _overrideUseMock},
    'environmentVariables': {
      'FLUTTER_ENV': Platform.environment['FLUTTER_ENV'],
      'USE_MOCK_DATA': Platform.environment['USE_MOCK_DATA'],
      'FLUTTER_TEST': Platform.environment['FLUTTER_TEST'],
    },
  };
}
