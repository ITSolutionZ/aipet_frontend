import 'package:aipet_frontend/features/onboarding/domain/domain.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import 'page_indicator.dart';

/// 온보딩 Bottom Sheet 위젯
class OnboardingBottomSheet extends StatelessWidget {
  final OnboardingPage currentPage;
  final OnboardingState onboardingState;
  final VoidCallback onNext;

  const OnboardingBottomSheet({
    super.key,
    required this.currentPage,
    required this.onboardingState,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: OnboardingConstants.bottomSheetShadowOpacity,
            ),
            blurRadius: OnboardingConstants.bottomSheetShadowBlurRadius,
            offset: OnboardingConstants.bottomSheetShadowOffset,
            spreadRadius: 0,
          ),
        ],
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
                LogoWidget(
                  imagePath: 'assets/icons/logo_notinclude_text.png',
                  width: OnboardingConstants.logoWidth,
                  height: OnboardingConstants.logoHeight,
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
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
              ),

              // 설명
              Text(
                currentPage.description,
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.pointGray,
                  height: OnboardingConstants.descriptionLineHeight,
                ),
                textAlign: TextAlign.center,
                maxLines: OnboardingConstants.descriptionMaxLines,
              ),

              // Next 버튼
              SizedBox(
                width: double.infinity,
                child: ActionButton.primary(
                  isEnabled: true,
                  text:
                      onboardingState.currentPage ==
                          OnboardingData.pages.length - 1
                      ? OnboardingConstants.startButtonText
                      : OnboardingConstants.nextButtonText,
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
