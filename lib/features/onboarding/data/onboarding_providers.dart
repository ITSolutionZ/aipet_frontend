import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/onboarding_data.dart';
import '../domain/onboarding_state.dart';
import '../domain/repositories/onboarding_repository.dart';
import 'repositories/onboarding_repository_impl.dart';

part 'onboarding_providers.g.dart';

@riverpod
class OnboardingStateNotifier extends _$OnboardingStateNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void nextPage() {
    if (state.currentPage < OnboardingData.pages.length - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < OnboardingData.pages.length) {
      state = state.copyWith(currentPage: page);
    }
  }

  /// 온보딩 시청 횟수 증가
  void incrementViewCount() {
    state = state.copyWith(viewCount: state.viewCount + 1);
  }

  /// 온보딩 완료
  void completeOnboarding() {
    state = state.copyWith(isCompleted: true);
  }

  /// 온보딩 시작 시 호출 (시청 횟수 증가)
  void startOnboarding() {
    incrementViewCount();
  }
}

@riverpod
OnboardingRepository onboardingRepository(Ref ref) {
  return OnboardingRepositoryImpl();
}
