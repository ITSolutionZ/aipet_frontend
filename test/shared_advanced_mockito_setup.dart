import 'package:aipet_frontend/shared/testing/centralized_mock_manager.dart';
import 'package:aipet_frontend/shared/testing/mock_config.dart';
import 'package:mockito/mockito.dart';

// 기존 shared_mockito_mocks.dart에서 생성된 Mock 클래스들을 import
import 'shared_mockito_mocks.mocks.dart';

/// 향상된 Mockito 설정 관리자
///
/// 시나리오별 Mock 설정을 체계적으로 관리하고,
/// 테스트 환경에서 다양한 상황을 시뮬레이션합니다.
class AdvancedMockitoSetup {
  /// 전체 성공 시나리오 설정
  static void setupAllSuccessScenarios({
    MockAiRepository? aiRepo,
    MockAuthRepository? authRepo,
    MockHomeRepository? homeRepo,
  }) {
    if (aiRepo != null) AiRepositoryMockSetup.setupSuccessScenario(aiRepo);
    if (authRepo != null) {
      AuthRepositoryMockSetup.setupSuccessScenario(authRepo);
    }
    if (homeRepo != null) {
      HomeRepositoryMockSetup.setupSuccessScenario(homeRepo);
    }
  }

  /// 전체 에러 시나리오 설정
  static void setupAllErrorScenarios({
    MockAiRepository? aiRepo,
    MockAuthRepository? authRepo,
    MockHomeRepository? homeRepo,
  }) {
    if (aiRepo != null) AiRepositoryMockSetup.setupErrorScenario(aiRepo);
    if (authRepo != null) {
      AuthRepositoryMockSetup.setupAuthFailureScenario(authRepo);
    }
    if (homeRepo != null) HomeRepositoryMockSetup.setupErrorScenario(homeRepo);
  }

  /// 혼합 시나리오 설정 (일부 성공, 일부 실패)
  static void setupMixedScenarios({
    MockAiRepository? aiRepo,
    MockAuthRepository? authRepo,
    MockHomeRepository? homeRepo,
  }) {
    if (aiRepo != null) AiRepositoryMockSetup.setupSlowResponseScenario(aiRepo);
    if (authRepo != null) {
      AuthRepositoryMockSetup.setupSuccessScenario(authRepo);
    }
    if (homeRepo != null) {
      HomeRepositoryMockSetup.setupSuccessScenario(homeRepo);
    }
  }

  /// 모든 Mock 초기화
  static void resetAllMocks({
    MockAiRepository? aiRepo,
    MockAuthRepository? authRepo,
    MockHomeRepository? homeRepo,
  }) {
    if (aiRepo != null) reset(aiRepo);
    if (authRepo != null) reset(authRepo);
    if (homeRepo != null) reset(homeRepo);
  }

  /// 개발 환경 기본 설정
  static void setupDevelopmentDefaults({
    MockAiRepository? aiRepo,
    MockAuthRepository? authRepo,
    MockHomeRepository? homeRepo,
  }) {
    if (MockConfig.currentEnvironment == MockEnvironment.development) {
      setupAllSuccessScenarios(
        aiRepo: aiRepo,
        authRepo: authRepo,
        homeRepo: homeRepo,
      );
    }
  }

  /// 테스트 환경 기본 설정
  static void setupTestingDefaults({
    MockAiRepository? aiRepo,
    MockAuthRepository? authRepo,
    MockHomeRepository? homeRepo,
  }) {
    if (MockConfig.currentEnvironment == MockEnvironment.testing) {
      // 테스트에서는 빠른 응답과 예측 가능한 결과
      CentralizedMockManager.clearAllScenarioOverrides();
      setupAllSuccessScenarios(
        aiRepo: aiRepo,
        authRepo: authRepo,
        homeRepo: homeRepo,
      );
    }
  }
}

/// AI Repository Mock 설정
class AiRepositoryMockSetup {
  /// 성공 시나리오 설정
  static void setupSuccessScenario(MockAiRepository mockRepo) {
    // AI 메시지 전송 성공 - 실제 Result<AiMessageEntity> 타입에 맞춰 조정 필요
    // when(mockRepo.sendMessage(any)).thenAnswer((invocation) async {
    //   // 실제 AiMessageEntity를 반환하는 Result 객체 반환
    //   return Result.success(MockAiMessageEntity());
    // });

    // 채팅 히스토리 조회 성공 - 실제 List<AiMessageEntity> 타입에 맞춰 조정 필요
    // when(mockRepo.getChatHistory()).thenAnswer((_) async {
    //   return [MockAiMessageEntity()]; // 실제 AiMessageEntity 리스트 반환
    // });
  }

  /// 에러 시나리오 설정
  static void setupErrorScenario(MockAiRepository mockRepo) {
    when(mockRepo.sendMessage(any)).thenThrow(Exception('AI 서비스 응답 실패'));
    when(mockRepo.getChatHistory()).thenThrow(Exception('채팅 히스토리 로드 실패'));
  }

  /// AI 응답 지연 시나리오 설정
  static void setupSlowResponseScenario(MockAiRepository mockRepo) {
    // when(mockRepo.sendMessage(any)).thenAnswer((invocation) async {
    //   await Future.delayed(const Duration(seconds: 5)); // 긴 지연
    //   return Result.success(MockAiMessageEntity());
    // });
  }
}

/// Auth Repository Mock 설정
class AuthRepositoryMockSetup {
  /// 성공 시나리오 설정
  static void setupSuccessScenario(MockAuthRepository mockRepo) {
    // 이메일/비밀번호 로그인 성공
    // when(mockRepo.signInWithEmailAndPassword(any, any)).thenAnswer((_) async {
    //   return AuthResult.success('로그인 성공', user: MockAuthUser());
    // });

    // 현재 사용자 조회 성공
    // when(mockRepo.getCurrentUser()).thenAnswer((_) async {
    //   return MockAuthUser();
    // });
  }

  /// 인증 실패 시나리오 설정
  static void setupAuthFailureScenario(MockAuthRepository mockRepo) {
    when(
      mockRepo.signInWithEmailAndPassword(any, any),
    ).thenThrow(Exception('이메일 또는 비밀번호가 올바르지 않습니다'));
    when(mockRepo.getCurrentUser()).thenThrow(Exception('사용자가 로그인되어 있지 않습니다'));
  }

  /// 로그아웃 시나리오 설정
  static void setupSignOutScenario(MockAuthRepository mockRepo) {
    when(mockRepo.signOut()).thenAnswer((_) async {});
    when(mockRepo.getCurrentUser()).thenAnswer((_) async => null);
  }

  /// 네트워크 에러 시나리오 설정
  static void setupNetworkErrorScenario(MockAuthRepository mockRepo) {
    when(
      mockRepo.signInWithEmailAndPassword(any, any),
    ).thenThrow(Exception('네트워크 연결을 확인해주세요'));
    when(mockRepo.getCurrentUser()).thenThrow(Exception('서버에 연결할 수 없습니다'));
  }
}

/// Home Repository Mock 설정
class HomeRepositoryMockSetup {
  /// 성공 시나리오 설정
  static void setupSuccessScenario(MockHomeRepository mockRepo) {
    // 대시보드 데이터 조회 성공
    // when(mockRepo.getDashboardData()).thenAnswer((_) async {
    //   return MockHomeDashboardEntity(); // 적절한 Mock 객체 반환
    // });

    // 날씨 정보 조회 성공
    // when(mockRepo.getCurrentWeather()).thenAnswer((_) async {
    //   return MockWeatherEntity(); // 적절한 Mock 객체 반환
    // });
  }

  /// 에러 시나리오 설정
  static void setupErrorScenario(MockHomeRepository mockRepo) {
    when(mockRepo.getDashboardData()).thenThrow(Exception('대시보드 정보 로드 실패'));
    when(mockRepo.getCurrentWeather()).thenThrow(Exception('날씨 정보 서비스 연결 실패'));
  }

  /// 부분 로딩 시나리오 설정
  static void setupPartialLoadingScenario(MockHomeRepository mockRepo) {
    // 대시보드는 성공, 날씨는 실패
    // when(mockRepo.getDashboardData()).thenAnswer((_) async {
    //   return MockHomeDashboardEntity(); // 적절한 Mock 객체 반환
    // });

    when(mockRepo.getCurrentWeather()).thenThrow(Exception('날씨 서비스 일시 중단'));
  }
}

/// Mock 설정 유틸리티
class MockUtilities {
  /// Mock 호출 검증
  static void verifyMockCalls({
    MockAiRepository? aiRepo,
    MockAuthRepository? authRepo,
    MockHomeRepository? homeRepo,
  }) {
    if (aiRepo != null) {
      verify(aiRepo.getChatHistory()).called(1);
    }
    if (authRepo != null) {
      verify(authRepo.getCurrentUser()).called(1);
    }
    if (homeRepo != null) {
      verify(homeRepo.getDashboardData()).called(1);
    }
  }

  /// 특정 시나리오에 맞는 Mock 설정
  static void setupScenario(
    MockScenario scenario, {
    MockAiRepository? aiRepo,
    MockAuthRepository? authRepo,
    MockHomeRepository? homeRepo,
  }) {
    switch (scenario) {
      case MockScenario.success:
        AdvancedMockitoSetup.setupAllSuccessScenarios(
          aiRepo: aiRepo,
          authRepo: authRepo,
          homeRepo: homeRepo,
        );
        break;
      case MockScenario.error:
        AdvancedMockitoSetup.setupAllErrorScenarios(
          aiRepo: aiRepo,
          authRepo: authRepo,
          homeRepo: homeRepo,
        );
        break;
      case MockScenario.delay:
        if (aiRepo != null) {
          AiRepositoryMockSetup.setupSlowResponseScenario(aiRepo);
        }
        if (authRepo != null) {
          AuthRepositoryMockSetup.setupSuccessScenario(authRepo);
        }
        if (homeRepo != null) {
          HomeRepositoryMockSetup.setupSuccessScenario(homeRepo);
        }
        break;
      case MockScenario.partialSuccess:
        if (aiRepo != null) AiRepositoryMockSetup.setupSuccessScenario(aiRepo);
        if (authRepo != null) {
          AuthRepositoryMockSetup.setupSignOutScenario(authRepo);
        }
        if (homeRepo != null) {
          HomeRepositoryMockSetup.setupPartialLoadingScenario(homeRepo);
        }
        break;
      case MockScenario.empty:
        // 빈 데이터 시나리오는 각 Repository에서 개별 구현
        break;
      case MockScenario.loading:
        // 로딩 시나리오는 UI 레벨에서 처리
        break;
    }
  }
}
