import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/domain.dart';

/// 온보딩 관리 리포지토리 구현체
///
/// OnboardingRepository 인터페이스의 구체적인 구현을 제공합니다.
/// SharedPreferences를 사용하여 온보딩 상태를 영구 저장합니다.
class OnboardingRepositoryImpl implements OnboardingRepository {
  // SharedPreferences 키 상수
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyOnboardingCurrentPage = 'onboarding_current_page';

  // 캐시용 메모리 변수 (필요한 것만 유지)
  OnboardingState? _currentState;

  @override
  Future<List<OnboardingPage>> loadOnboardingData() async {
    // 로컬 정적 데이터 반환
    return OnboardingData.pages;
  }

  @override
  Future<void> saveOnboardingState(OnboardingState state) async {
    try {
      _currentState = state;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyOnboardingCurrentPage, state.currentPage);
      await prefs.setBool(_keyOnboardingCompleted, state.isCompleted);
    } catch (e) {
      debugPrint('❌ 온보딩 상태 저장 실패: $e');
      // 메모리 캐시는 유지
      _currentState = state;
      rethrow;
    }
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

    return _currentState!;
  }

  @override
  Future<void> completeOnboarding() async {
    _currentState = const OnboardingState(isCompleted: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
    await prefs.setInt(_keyOnboardingCurrentPage, 0); // 완료시 페이지 리셋
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  @override
  Future<void> restartOnboarding() async {
    _currentState = const OnboardingState();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, false);
    await prefs.setInt(_keyOnboardingCurrentPage, 0);
  }

  @override
  Future<void> saveOnboardingProgress(int currentPage) async {
    // saveOnboardingState를 호출하여 중복 로직 제거
    final newState = OnboardingState(currentPage: currentPage);
    await saveOnboardingState(newState);
  }

  @override
  Future<int> loadOnboardingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyOnboardingCurrentPage) ?? 0;
  }
}
