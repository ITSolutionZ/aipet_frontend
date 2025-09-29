import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class PetInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Widget? badge;
  final VoidCallback? onTap;

  const PetInfoCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const const const EdgeInsets.all(AppSpacing.lg),
        margin: const const const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: AppColors.pointGray.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.pointPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: AppColors.pointBrown, size: 24),
              ),
              const const const SizedBox(width: AppSpacing.lg),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.titleSmall.copyWith(
                      color: AppColors.pointDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const const const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.pointDark,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              badge!,
              const const const SizedBox(width: AppSpacing.sm),
            ],
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.pointGray,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
