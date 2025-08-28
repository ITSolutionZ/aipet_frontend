import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/domain.dart';
import 'repositories/onboarding_repository_impl.dart';

part 'onboarding_providers.g.dart';

@riverpod
class OnboardingStateNotifier extends _$OnboardingStateNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void nextPage() {
    if (state.currentPage < OnboardingData.pages.length - 1) {
      final newPage = state.currentPage + 1;
      state = state.copyWith(currentPage: newPage);
      _saveProgress(newPage);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      final newPage = state.currentPage - 1;
      state = state.copyWith(currentPage: newPage);
      _saveProgress(newPage);
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < OnboardingData.pages.length) {
      state = state.copyWith(currentPage: page);
      _saveProgress(page);
    }
  }

  /// 온보딩 시청 횟수 증가
  void incrementViewCount() {
    state = state.copyWith(viewCount: state.viewCount + 1);
    _saveState();
  }

  /// 온보딩 완료
  void completeOnboarding() {
    state = state.copyWith(isCompleted: true);
    _saveState();
  }

  /// 온보딩 시작 시 호출 (시청 횟수 증가)
  void startOnboarding() {
    incrementViewCount();
  }

  /// 페이지 진행 상태 저장
  void _saveProgress(int currentPage) {
    ref.read(onboardingRepositoryProvider).saveOnboardingProgress(currentPage);
  }

  /// 온보딩 상태 저장
  void _saveState() {
    ref.read(onboardingRepositoryProvider).saveOnboardingState(state);
  }
}

@riverpod
OnboardingRepository onboardingRepository(Ref ref) {
  return OnboardingRepositoryImpl();
}
