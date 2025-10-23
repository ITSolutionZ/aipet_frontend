import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

import '../../domain/domain.dart';
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

              // 로고 이미지 (첫 번째 페이지에서만 표시) - Welcome 위로 이동
              if (onboardingState.currentPage == 0)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/icons/logos/aipet_black.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        LoggerService.debug('❌ 로고 로드 실패: aipet_black.png');
                        // Fallback: 텍스트 로고
                        return const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pets,
                              size: 30,
                              color: AppColors.pointBrown,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'AIPET',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.pointBrown,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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
