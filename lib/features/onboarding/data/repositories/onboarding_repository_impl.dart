import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/onboarding_data.dart';
import '../../domain/onboarding_state.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// 온보딩 관리 리포지토리 구현체
///
/// OnboardingRepository 인터페이스의 구체적인 구현을 제공합니다.
/// SharedPreferences를 사용하여 온보딩 상태를 영구 저장합니다.
class OnboardingRepositoryImpl implements OnboardingRepository {
  // SharedPreferences 키 상수
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyOnboardingProgress = 'onboarding_progress';
  static const String _keyOnboardingCurrentPage = 'onboarding_current_page';

  // 캐시용 메모리 변수들
  OnboardingState? _currentState;
  int _currentProgress = 0;
  bool _isCompleted = false;

  @override
  Future<List<OnboardingPage>> loadOnboardingData() async {
    // 로컬 정적 데이터 반환
    return OnboardingData.pages;
  }

  @override
  Future<void> saveOnboardingState(OnboardingState state) async {
    _currentState = state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyOnboardingCurrentPage, state.currentPage);
    await prefs.setBool(_keyOnboardingCompleted, state.isCompleted);
  }

  @override
  Future<OnboardingState> loadOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final currentPage = prefs.getInt(_keyOnboardingCurrentPage) ?? 0;
    final isCompleted = prefs.getBool(_keyOnboardingCompleted) ?? false;

    _currentState = OnboardingState(
      currentPage: currentPage,
      isCompleted: isCompleted,
    );
    _currentProgress = currentPage;
    _isCompleted = isCompleted;

    return _currentState!;
  }

  @override
  Future<void> completeOnboarding() async {
    _isCompleted = true;
    _currentState = const OnboardingState(isCompleted: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
    await prefs.setInt(_keyOnboardingCurrentPage, 0); // 완료시 페이지 리셋
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    _isCompleted = prefs.getBool(_keyOnboardingCompleted) ?? false;
    return _isCompleted;
  }

  @override
  Future<void> restartOnboarding() async {
    _isCompleted = false;
    _currentState = const OnboardingState();
    _currentProgress = 0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, false);
    await prefs.setInt(_keyOnboardingCurrentPage, 0);
    await prefs.setInt(_keyOnboardingProgress, 0);
  }

  @override
  Future<void> saveOnboardingProgress(int currentPage) async {
    _currentProgress = currentPage;
    _currentState = OnboardingState(currentPage: currentPage);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyOnboardingProgress, currentPage);
    await prefs.setInt(_keyOnboardingCurrentPage, currentPage);
  }

  @override
  Future<int> loadOnboardingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _currentProgress = prefs.getInt(_keyOnboardingProgress) ?? 0;
    return _currentProgress;
  }
}
