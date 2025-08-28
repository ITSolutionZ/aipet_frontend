import '../domain.dart';

/// 온보딩 관리 리포지토리 인터페이스
///
/// 온보딩 관련 데이터 접근을 위한 추상 인터페이스입니다.
/// Clean Architecture의 Domain Layer에서 Data Layer의 구체적인 구현을 숨기는 역할을 합니다.
abstract class OnboardingRepository {
  /// 온보딩 데이터 로드
  Future<List<OnboardingPage>> loadOnboardingData();

  /// 온보딩 상태 저장
  Future<void> saveOnboardingState(OnboardingState state);

  /// 온보딩 상태 로드
  Future<OnboardingState> loadOnboardingState();

  /// 온보딩 완료 처리
  Future<void> completeOnboarding();

  /// 온보딩 완료 여부 확인
  Future<bool> isOnboardingCompleted();

  /// 온보딩 재시작
  Future<void> restartOnboarding();

  /// 온보딩 진행률 저장
  Future<void> saveOnboardingProgress(int currentPage);

  /// 온보딩 진행률 로드
  Future<int> loadOnboardingProgress();
}
