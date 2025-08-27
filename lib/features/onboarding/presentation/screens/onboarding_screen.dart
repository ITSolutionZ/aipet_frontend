import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/shared.dart';
import '../../data/onboarding_providers.dart';
import '../../domain/onboarding_data.dart';
import '../widgets/page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // 온보딩 시작 시 시청 횟수 증가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingStateNotifierProvider.notifier).startOnboarding();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    ref.read(onboardingStateNotifierProvider.notifier).goToPage(page);
  }

  void _nextPage() {
    final currentPage = ref.read(onboardingStateNotifierProvider).currentPage;
    if (currentPage < OnboardingData.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    ref.read(onboardingStateNotifierProvider.notifier).completeOnboarding();
    // 로그인 화면으로 이동
    context.go(AppRouter.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingStateNotifierProvider);
    final currentPage = OnboardingData.pages[onboardingState.currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: OnboardingData.pages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(OnboardingData.pages[index].imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // Skip 버튼 (1회 이상 온보딩을 본 사용자에게만 표시, 마지막 페이지가 아닐 때)
          if (onboardingState.hasSeenOnboardingBefore &&
              onboardingState.currentPage < OnboardingData.pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: _completeOnboarding,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: AppFonts.aldrich(
                    fontSize: AppFonts.lg,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // 하단 시트
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45, // 화면 높이의 45%
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.large),
                  topRight: Radius.circular(AppRadius.large),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 페이지 인디케이터
                      PageIndicator(
                        currentPage: onboardingState.currentPage,
                        totalPages: OnboardingData.pages.length,
                      ),

                      // 로고 이미지 (첫 번째 페이지에서만 표시)
                      if (onboardingState.currentPage == 0)
                        SizedBox(
                          width: 100,
                          height: 70,
                          child: Image.asset(
                            'assets/icons/logo_notinclude_text.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                      // 제목
                      Text(
                        currentPage.title,
                        style: AppFonts.fredoka(
                          fontSize: AppFonts.h1,
                          color: AppColors.pointDark,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // 부제목
                      Text(
                        currentPage.subtitle,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointGray,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // 설명
                      Text(
                        currentPage.description,
                        style: AppFonts.bodyMedium.copyWith(
                          color: AppColors.pointGray,
                          height: 1.4, // 줄 간격 조정
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4, // 최대 4줄까지 표시
                      ),

                      // Next 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.pointBrown.withValues(
                              alpha: 0.8,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.medium,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                onboardingState.currentPage ==
                                        OnboardingData.pages.length - 1
                                    ? '始める'
                                    : '次へ',
                                style: AppFonts.aldrich(
                                  fontSize: AppFonts.lg,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
