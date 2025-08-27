import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/onboarding_data.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  const OnboardingPageWidget({
    super.key,
    required this.page,
    required this.isLastPage,
    required this.onNext,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortest = size.shortestSide;
    final isTablet = shortest >= 600; // common Flutter breakpoint

    // Resolve per-device alignment & card height factor with fallbacks
    final Alignment bgAlignment = isTablet
        ? const Alignment(0, 0.35)
        : const Alignment(0, 0.35);

    final double cardFactor = isTablet ? 0.40 : 0.43;

    final double cardHeight = (size.height * cardFactor).clamp(320.0, 520.0);

    return Stack(
      children: [
        // Background image full-bleed
        Positioned.fill(
          child: Image.asset(
            page.imagePath,
            fit: BoxFit.cover, // Changed: full-bleed background
            alignment: bgAlignment, // Changed: responsive focal point
            filterQuality: FilterQuality.high,
          ),
        ),
        // Foreground bottom card
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _OnboardingCard(
              page: page,
              isLastPage: isLastPage,
              onNext: onNext,
              onComplete: onComplete,
              cardHeight: cardHeight,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final OnboardingPage page;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onComplete;
  final double cardHeight;

  const _OnboardingCard({
    required this.page,
    required this.isLastPage,
    required this.onNext,
    required this.onComplete,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return WhiteCard.elevated(
      child: SizedBox(
        width: double.infinity,
        height: cardHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // (Optional) page icon section — keep space for indicator/icon area
              const SizedBox(height: AppSpacing.sm),

              // Title
              Text(
                page.title,
                style: AppFonts.headlineMedium.copyWith(
                  color: AppColors.pointDark,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                page.subtitle,
                style: AppFonts.titleMedium.copyWith(
                  color: AppColors.pointBrown,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              // Description
              Text(
                page.description,
                style: AppFonts.bodyMedium.copyWith(color: AppColors.pointGray),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Button
              PointButton.large(
                label: isLastPage ? '始める' : '次へ',
                onPressed: isLastPage ? onComplete : onNext,
                textStyle: AppFonts.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                trailing: Icon(
                  isLastPage ? Icons.arrow_forward : Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
