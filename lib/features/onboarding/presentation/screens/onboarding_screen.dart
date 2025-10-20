import 'dart:async';

import 'package:aipet_frontend/app/router/app_router.dart';
import 'package:aipet_frontend/features/onboarding/data/data.dart';
import 'package:aipet_frontend/features/onboarding/domain/domain.dart';
import 'package:aipet_frontend/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:aipet_frontend/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  late final OnboardingController _controller;
  Timer? _autoNextTimer;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController(ref);

    // 온보딩 시작 시 시청 횟수 증가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).startOnboarding();
      // 첫 페이지에서 3초 후 자동 넘김
      _startAutoNextTimer();
    });
  }

  @override
  void dispose() {
    _autoNextTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoNextTimer() {
    _autoNextTimer?.cancel();
    _autoNextTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _nextPage();
      }
    });
  }

  void _onPageChanged(int page) {
    _controller.goToPage(page);
    // 페이지 변경 시 새로운 타이머 시작
    _startAutoNextTimer();
  }

  void _nextPage() {
    // PageController에서 직접 현재 페이지 가져오기 (ref.read 사용 안함)
    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage < OnboardingData.pages.length - 1) {
      _pageController.nextPage(
        duration: OnboardingConstants.pageTransitionDuration,
        curve: OnboardingConstants.pageTransitionCurve,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final result = await _controller.finishOnboarding();
    if (result.isSuccess && mounted) {
      // 로그인 화면으로 이동
      context.go(AppRouter.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final currentPage = OnboardingData.pages[onboardingState.currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // 메인 컨텐츠
          Column(
            children: [
              // 이미지 부분 (화면의 55%)
              Expanded(
                flex: OnboardingConstants.imageSectionFlex,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: OnboardingData.pages.length,
                      itemBuilder: (context, index) {
                        final page = OnboardingData.pages[index];
                        return OnboardingBackgroundImage(
                          page: page,
                          screenHeight: MediaQuery.of(context).size.height,
                          screenWidth: MediaQuery.of(context).size.width,
                        );
                      },
                    ),

                    // Skip 버튼 (1회 이상 온보딩을 본 사용자에게만 표시, 마지막 페이지가 아닐 때)
                    if (onboardingState.hasSeenOnboardingBefore &&
                        onboardingState.currentPage <
                            OnboardingData.pages.length - 1)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + AppSpacing.md,
                        right: AppSpacing.md,
                        child: ActionButton.secondary(
                          isEnabled: true,
                          text: OnboardingConstants.skipButtonText,
                          onPressed: _completeOnboarding,
                        ),
                      ),
                  ],
                ),
              ),

              // 바텀 시트 부분 (화면의 45%)
              Expanded(
                flex: OnboardingConstants.bottomSheetFlex,
                child: OnboardingBottomSheet(
                  currentPage: currentPage,
                  onboardingState: onboardingState,
                  onNext: _nextPage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
