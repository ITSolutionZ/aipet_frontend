import 'package:aipet_frontend/shared/shared.dart';
import 'package:flutter/material.dart';

class CaretakerCard extends StatelessWidget {
  final String ownerId;
  final String email;
  final String? name;

  const CaretakerCard({super.key, required this.ownerId, required this.email, this.name});

  @override
  Widget build(BuildContext context) {
    final displayName = name ?? ownerId;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.pointBrown.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.pointBrown, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppFonts.bodyMedium.copyWith(
                    color: AppColors.pointDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  email,
                  style: AppFonts.bodySmall.copyWith(
                    color: AppColors.pointDark.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
