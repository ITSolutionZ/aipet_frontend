import 'package:aipet_frontend/features/pet_registor/presentation/constants/pet_registration_texts.dart';
import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

/// 다음 버튼 위젯
///
/// const 생성자를 활용하여 성능을 최적화하고 재사용성을 높입니다.
class NextButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;
  final String? text;

  const NextButton({
    super.key,
    required this.isEnabled,
    this.onPressed,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.pointBrown
              : AppColors.pointPink.withValues(alpha: 0.3),
          foregroundColor: AppColors.pureWhite,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          elevation: isEnabled ? 2 : 0,
          shadowColor: isEnabled
              ? AppColors.pointBrown.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
        child: Text(
          text ?? PetRegistrationTexts.next,
          style: AppFonts.titleMedium.copyWith(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
