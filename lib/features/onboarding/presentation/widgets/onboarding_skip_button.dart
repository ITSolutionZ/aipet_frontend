import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../domain/domain.dart';

/// 온보딩 Skip 버튼 위젯
class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingSkipButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '온보딩 건너뛰기',
      button: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.black.withValues(
            alpha: OnboardingConstants.skipButtonOpacity,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
        child: Text(
          OnboardingConstants.skipButtonText,
          style: AppFonts.aldrich(
            fontSize: AppFonts.lg,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
