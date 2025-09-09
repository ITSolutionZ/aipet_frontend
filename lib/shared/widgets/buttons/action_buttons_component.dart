import 'package:flutter/material.dart';
import '../../shared.dart';

/// 순수 UI 전용 액션 버튼들 위젯
class ActionButtonsComponent extends StatelessWidget {
  final String primaryButtonText;
  final IconData primaryButtonIcon;
  final VoidCallback onPrimaryPressed;
  final String secondaryButtonText;
  final IconData secondaryButtonIcon;
  final VoidCallback onSecondaryPressed;

  const ActionButtonsComponent({
    super.key,
    required this.primaryButtonText,
    required this.primaryButtonIcon,
    required this.onPrimaryPressed,
    required this.secondaryButtonText,
    required this.secondaryButtonIcon,
    required this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ショットカット',
                style: AppFonts.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.pointDark,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPrimaryPressed,
                  icon: Icon(primaryButtonIcon),
                  label: Text(primaryButtonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pointBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onSecondaryPressed,
                  icon: Icon(secondaryButtonIcon),
                  label: Text(secondaryButtonText),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.pointPink,
                    side: const BorderSide(
                      color: AppColors.pointPink,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}