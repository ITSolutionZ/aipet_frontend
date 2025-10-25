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
    // 미디어쿼리로 화면 크기 가져오기
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700; // iPhone SE, iPhone 8 등

    // 화면 크기에 따른 동적 크기 계산
    final logoSize = isSmallScreen ? 70.0 : 100.0;
    final titleFontSize = isSmallScreen ? AppFonts.xl : AppFonts.h1;
    final verticalSpacing = isSmallScreen ? AppSpacing.sm : AppSpacing.md;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 페이지 인디케이터
                PageIndicator(
                  currentPage: onboardingState.currentPage,
                  totalPages: OnboardingData.pages.length,
                ),

                SizedBox(height: verticalSpacing),

                // 로고 이미지 (첫 번째 페이지에서만 표시) - Welcome 위로 이동
                if (onboardingState.currentPage == 0)
                  Container(
                    width: logoSize,
                    height: logoSize,
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
                      padding: EdgeInsets.all(isSmallScreen ? 14.0 : 20.0),
                      child: Image.asset(
                        'assets/icons/logos/aipet_black.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          LoggerService.debug('❌ 로고 로드 실패: aipet_black.png');
                          // Fallback: 텍스트 로고
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pets,
                                size: isSmallScreen ? 24.0 : 30.0,
                                color: AppColors.pointBrown,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'AIPET',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10.0 : 12.0,
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

                if (onboardingState.currentPage == 0)
                  SizedBox(height: verticalSpacing),

                // 제목
                Text(
                  currentPage.title,
                  style: AppFonts.fredoka(
                    fontSize: titleFontSize,
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: verticalSpacing),

                // 부제목
                Text(
                  currentPage.subtitle,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                    fontSize: isSmallScreen ? AppFonts.sm : AppFonts.baseSize,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: verticalSpacing),

                // 설명
                Text(
                  currentPage.description,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointGray,
                    height: OnboardingConstants.descriptionLineHeight,
                    fontSize: isSmallScreen ? AppFonts.sm : AppFonts.baseSize,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: OnboardingConstants.descriptionMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: verticalSpacing),

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
      ),
    );
  }
}
